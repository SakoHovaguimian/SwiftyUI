//
//  Dungeon.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/4/26.
//

import Foundation

// MARK: - TileType

enum TileType: Int, Codable, Hashable {
    case none = 0
    case start
    case empty
    case hall
    case puzzle
    case treasure
    case secret
    case boss
    case escape

    var typeString: String {
        switch self {
        case .start: return "start"
        case .empty: return "empty"
        case .hall: return "hall"
        case .puzzle: return "puzzle"
        case .treasure: return "treasure"
        case .secret: return "secret"
        case .boss: return "boss"
        case .escape: return "escape"
        default: return "none"
        }
    }
}

// MARK: - Cell

struct Cell: Hashable, Codable {
    var x: Int
    var y: Int
}

// MARK: - DungeonGraph Export (matches your JSON shape)

struct DungeonGraph: Codable {
    struct Targets: Codable {
        var tilesMin: Int
        var tilesMax: Int
        var mainPathMinLen: Int
        var startBossMinManhattan: Int
    }

    struct Specials: Codable {
        var start: [Int]
        var boss: [Int]
        var escape: [Int]
        var puzzles: [[Int]]
    }

    struct Tile: Codable {
        var pos: [Int]          // [x,y]
        var type: String        // "hall", "puzzle", etc.
        var variantId: String
        var doorMask: Int       // N=1,E=2,S=4,W=8
        var rotationY: Double
        var decorSeed: Int
    }

    struct Edge: Codable {
        var a: [Int]
        var b: [Int]
    }

    struct ProgressionVisual: Codable {
        var keyPos: [Double]
        var gatePos: [Double]
        var color: [Double]
    }

    var version: Int
    var seed: Int
    var gridSize: [Int]
    var targets: Targets
    var specials: Specials
    var tiles: [Tile]
    var edges: [Edge]
    var mainPath: [[Int]]
    var progressionVisuals: [ProgressionVisual]
}

// MARK: - RNG (seeded)

struct SeededRNG {
    private var state: UInt64

    init(seed: Int) {
        self.state = UInt64(bitPattern: Int64(seed))
        if self.state == 0 { self.state = 0xDEADBEEF }
    }

    mutating func nextUInt64() -> UInt64 {
        // SplitMix64
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }

    mutating func nextInt(_ upperBound: Int) -> Int {
        precondition(upperBound > 0)
        return Int(nextUInt64() % UInt64(upperBound))
    }

    mutating func int(in range: ClosedRange<Int>) -> Int {
        let span = range.upperBound - range.lowerBound + 1
        return range.lowerBound + nextInt(span)
    }

    mutating func double01() -> Double {
        let v = nextUInt64() >> 11
        return Double(v) / Double(1 << 53)
    }
}

// MARK: - DungeonGenerator (Swift port)

final class DungeonGenerator {

    // ---------------------------
    // Configuration (matches your script)
    // ---------------------------
    static let gridW = 10
    static let gridH = 10

    static let requiredPuzzles = 4
    static let treasureMin = 2
    static let treasureMax = 5
    static let secretMin = 1
    static let secretMax = 3

    static let targetTilesMin = 35
    static let targetTilesMax = 55

    static let minStartBossManhattan = 7
    static let minMainPathLen = 12

    static let maxBranchDepth = 4
    static let deadEndsMin = 4
    static let deadEndsMax = 8

    static let maxAttempts = 50

    // ---------------------------
    // Variants (IDs only)
    // ---------------------------
    static let roomVariants: [String: [String]] = [
        "start": ["start_a","start_b","start_c"],
        "empty": ["empty_a","empty_b","empty_c","empty_d","empty_e"],
        "puzzle": ["puzzle_a","puzzle_b","puzzle_c","puzzle_d","puzzle_e"],
        "treasure": ["treasure_a","treasure_b","treasure_c"],
        "secret": ["secret_a","secret_b","secret_c"],
        "boss": ["boss_a","boss_b"],
        "escape": ["escape_a","escape_b"]
    ]

    static let hallVariants: [String: [String]] = [
        "dead_end": ["hall_dead_a","hall_dead_b","hall_dead_c"],
        "straight": ["hall_straight_a","hall_straight_b","hall_straight_c"],
        "corner": ["hall_corner_a","hall_corner_b","hall_corner_c"],
        "tee": ["hall_tee_a","hall_tee_b"],
        "cross": ["hall_cross_a","hall_cross_b"]
    ]

    // ---------------------------
    // State
    // ---------------------------
    private var rng: SeededRNG

    // Grid state
    private var tileType: [Cell: TileType] = [:]
    // adjacency list: cell -> Set<Cell>
    private var connections: [Cell: Set<Cell>] = [:]

    // Specials
    private var start: Cell = .init(x: 0, y: 0)
    private var boss: Cell = .init(x: 0, y: 0)
    private var escape: Cell = .init(x: 0, y: 0)
    private var mainPath: [Cell] = []

    // Progression visuals kept for export (positions are “world” in Godot, but here just keep placeholders)
    private var progressionData: [[String: Any]] = []

    init(seed: Int) {
        self.rng = SeededRNG(seed: seed)
    }

    // MARK: - Public API

    struct Result {
        let seed: Int
        let tileType: [Cell: TileType]
        let connections: [Cell: Set<Cell>]
        let start: Cell
        let boss: Cell
        let escape: Cell
        let mainPath: [Cell]
        let export: DungeonGraph
    }

    func generate() -> Result? {
        var seedValue = currentSeed()

        for attempt in 0..<Self.maxAttempts {
            clear()

            if tryGenerate() {
                let export = buildDungeonGraph(seed: seedValue)
                return .init(
                    seed: seedValue,
                    tileType: tileType,
                    connections: connections,
                    start: start,
                    boss: boss,
                    escape: escape,
                    mainPath: mainPath,
                    export: export
                )
            }

            // increment seed and try again (like your script)
            seedValue += 1
            rng = SeededRNG(seed: seedValue)
            _ = attempt
        }

        return nil
    }

    // MARK: - Phases

    private func tryGenerate() -> Bool {
        if !placeStartAndBoss() { return false }
        if !carveMainPath() { return false }
        if !placePuzzlesOnMainPath() { return false }
        if !placeEscape() { return false }
        if !placeOptionalBranches() { return false }
        if !fillToDensity() { return false }
        return validateRules()
    }

    // Phase 1
    private func placeStartAndBoss() -> Bool {
        start = randCell()
        setTile(start, .start)

        var candidates: [Cell] = []
        for x in 0..<Self.gridW {
            for y in 0..<Self.gridH {
                let c = Cell(x: x, y: y)
                if c == start { continue }
                if manhattan(start, c) >= Self.minStartBossManhattan {
                    candidates.append(c)
                }
            }
        }

        guard !candidates.isEmpty else { return false }

        boss = candidates[rng.nextInt(candidates.count)]
        // boss tile is set after main path carve
        return true
    }

    // Phase 2
    private func carveMainPath() -> Bool {
        var visited: Set<Cell> = []
        var path: [Cell] = [start]
        visited.insert(start)

        var cur = start
        let maxSteps = 60

        for _ in 0..<maxSteps {
            if cur == boss, path.count >= Self.minMainPathLen {
                break
            }

            var options = neighbors4(cur).filter { n in
                inBounds(n) && !visited.contains(n)
            }

            if options.isEmpty { return false }

            options.sort { a, b in
                let da = manhattan(a, boss)
                let db = manhattan(b, boss)

                if path.count < Self.minMainPathLen {
                    return da > db   // detour early
                } else {
                    return da < db   // converge late
                }
            }

            let pickPool = min(3, options.count)
            let next = options[rng.nextInt(pickPool)]

            visited.insert(next)
            connect(cur, next)
            path.append(next)
            cur = next
        }

        guard cur == boss else { return false }
        guard path.count >= Self.minMainPathLen else { return false }

        mainPath = path

        // Label main path tiles
        for i in 1..<mainPath.count {
            setTile(mainPath[i], .hall)
        }

        setTile(boss, .boss)
        return true
    }

    // Phase 3
    private func placePuzzlesOnMainPath() -> Bool {
        guard mainPath.count >= (Self.requiredPuzzles + 3) else { return false }

        let startI = 2
        let endI = mainPath.count - 3
        guard endI - startI + 1 >= Self.requiredPuzzles else { return false }

        let span = Double(endI - startI)
        var indices: [Int] = []
        for p in 0..<Self.requiredPuzzles {
            let t = Double(p + 1) / Double(Self.requiredPuzzles + 1)
            let idx = startI + Int(round(t * span))
            indices.append(idx)
        }

        indices = uniqueIntsWithin(indices, minV: startI, maxV: endI, desired: Self.requiredPuzzles)
        guard indices.count == Self.requiredPuzzles else { return false }

        for idx in indices {
            let cell = mainPath[idx]
            if isAdjacentSpecial(cell) { return false }
            setTile(cell, .puzzle)
        }

        buildProgressionVisuals(puzzleIndices: indices)
        return true
    }

    private func buildProgressionVisuals(puzzleIndices: [Int]) {
        progressionData.removeAll()

        for idx in puzzleIndices {
            let puzzleCell = mainPath[idx]
            let nextCell = mainPath[min(idx + 1, mainPath.count - 1)]

            // Placeholder “world” positions
            let gate = [(Double(puzzleCell.x) + Double(nextCell.x)) / 2.0,
                        (Double(puzzleCell.y) + Double(nextCell.y)) / 2.0]
            let key = [Double(puzzleCell.x), Double(puzzleCell.y)]

            progressionData.append([
                "key_pos": key,
                "gate_pos": gate,
                "color": [0.1, 0.3, 0.9, 1.0] // placeholder
            ])
        }
    }

    // Phase 4
    private func placeEscape() -> Bool {
        let options = neighbors4(boss).filter { n in
            inBounds(n) && !isOnMainPath(n) && tileType[n] == nil
        }

        if options.isEmpty {
            escape = boss
            return true
        }

        escape = options[rng.nextInt(options.count)]
        setTile(escape, .escape)
        connect(boss, escape)
        return true
    }

    // Phase 5
    private func placeOptionalBranches() -> Bool {
        let treasureCount = rng.int(in: Self.treasureMin...Self.treasureMax)
        let secretCount = rng.int(in: Self.secretMin...Self.secretMax)

        guard
            let earlyAttach = pickBranchAttachRange(startIdx: 2, endIdx: Int(Double(mainPath.count) * 0.5)),
            let lateAttach = pickBranchAttachRange(startIdx: Int(Double(mainPath.count) * 0.5), endIdx: mainPath.count - 3)
        else { return false }

        if !carveBranchWithLeaf(attach: earlyAttach, leafType: .treasure, depth: rng.int(in: 1...Self.maxBranchDepth)) { return false }
        if !carveBranchWithLeaf(attach: lateAttach, leafType: .treasure, depth: rng.int(in: 1...Self.maxBranchDepth)) { return false }

        let remainingTreasure = max(0, treasureCount - 2)
        for _ in 0..<remainingTreasure {
            guard let attach = pickBranchAttachAny() else { return false }
            if !carveBranchWithLeaf(attach: attach, leafType: .treasure, depth: rng.int(in: 1...Self.maxBranchDepth)) { return false }
        }

        for _ in 0..<secretCount {
            guard let attach2 = pickBranchAttachAny() else { return false }
            if !carveBranchWithLeaf(attach: attach2, leafType: .secret, depth: rng.int(in: 1...Self.maxBranchDepth)) { return false }
        }

        return true
    }

    private func pickBranchAttachRange(startIdx: Int, endIdx: Int) -> Cell? {
        guard startIdx <= endIdx else { return nil }
        var idxs = Array(startIdx...endIdx)
        idxs.shuffle(using: &SystemRandomNumberGenerator()) // ok: just to permute candidates
        for idx in idxs {  613290
            let cell = mainPath[idx]
            if canAttachBranchHere(cell) { return cell }
        }
        return nil
    }

    private func pickBranchAttachAny() -> Cell? {
        guard mainPath.count >= 5 else { return nil }
        var idxs = Array(2...(mainPath.count - 2))
        idxs.shuffle(using: &SystemRandomNumberGenerator())
        for idx in idxs {
            let cell = mainPath[idx]
            if canAttachBranchHere(cell) { return cell }
        }
        return nil
    }

    private func canAttachBranchHere(_ cell: Cell) -> Bool {
        let t = tileType[cell] ?? .none
        if t == .boss || t == .escape { return false }
        if isAdjacentSpecial(cell) { return false }
        return true
    }

    private func carveBranchWithLeaf(attach: Cell, leafType: TileType, depth: Int) -> Bool {
        var cur = attach

        for _ in 0..<depth {
            let options = neighbors4(cur).filter { n in
                inBounds(n)
                && tileType[n] == nil
                && !isOnMainPath(n)
                && !isAdjacentSpecial(n)
            }

            if options.isEmpty { return false }

            let next = options[rng.nextInt(options.count)]
            connect(cur, next)
            setTile(next, .hall)
            cur = next
        }

        if isAdjacentSpecial(cur) { return false }

        setTile(cur, leafType)

        if leafType == .secret {
            if degree(cur) != 1 { return false }
        }

        return true
    }

    // Phase 6
    private func fillToDensity() -> Bool {
        let target = rng.int(in: Self.targetTilesMin...Self.targetTilesMax)
        var safety = 500

        while tileType.count < target && safety > 0 {
            safety -= 1

            guard let frontier = pickFrontierCell() else { break }
            let options = neighbors4(frontier).filter { n in
                inBounds(n) && tileType[n] == nil
            }

            if options.isEmpty { continue }

            let next = options[rng.nextInt(options.count)]
            connect(frontier, next)

            let roll = rng.double01()
            setTile(next, roll < 0.65 ? .hall : .empty)
        }

        return tileType.count >= Self.targetTilesMin
    }

    private func pickFrontierCell() -> Cell? {
        let cells = Array(tileType.keys)
        // random-ish selection; determinism not critical here (connectivity+seed does the work)
        for cell in cells.shuffled(using: &SystemRandomNumberGenerator()) {
            let tt = tileType[cell] ?? .none
            if tt == .secret || tt == .treasure { continue }

            for n in neighbors4(cell) {
                if inBounds(n), tileType[n] == nil { return cell }
            }
        }
        return nil
    }

    // MARK: - Validation

    private func validateRules() -> Bool {
        if !allTilesReachable() { return false }
        if manhattan(start, boss) < Self.minStartBossManhattan { return false }
        if mainPath.count < Self.minMainPathLen { return false }
        if !validateSpecialAdjacency() { return false }

        let puzzleOnPath = mainPath.filter { tileType[$0] == .puzzle }.count
        if puzzleOnPath != Self.requiredPuzzles { return false }

        for cell in mainPath {
            let t = tileType[cell] ?? .none
            if t == .treasure || t == .secret { return false }
        }

        for (cell, t) in tileType where t == .secret {
            if degree(cell) != 1 { return false }
        }

        let deadEnds = countDeadEnds()
        if deadEnds < Self.deadEndsMin || deadEnds > Self.deadEndsMax { return false }

        if tileType.count < Self.targetTilesMin || tileType.count > Self.targetTilesMax { return false }

        if manhattan(start, boss) == 1 { return false }
        if escape != boss && manhattan(start, escape) == 1 { return false }

        return true
    }

    private func allTilesReachable() -> Bool {
        var visited: Set<Cell> = []
        var queue: [Cell] = [start]
        visited.insert(start)

        while !queue.isEmpty {
            let cur = queue.removeFirst()
            for n in connections[cur] ?? [] {
                if !visited.contains(n) {
                    visited.insert(n)
                    queue.append(n)
                }
            }
        }

        for cell in tileType.keys {
            if !visited.contains(cell) { return false }
        }

        return true
    }

    private func validateSpecialAdjacency() -> Bool {
        // Special rooms: Puzzle, Treasure, Secret, Boss, Escape (Start excluded)
        // Exception allowed: Boss adjacent to Escape ONLY for extraction connection (or merged).
        let special: Set<TileType> = [.puzzle, .treasure, .secret, .boss, .escape]

        for (cell, t) in tileType where special.contains(t) {
            for n in neighbors4(cell) where inBounds(n) {
                let nt = tileType[n] ?? .none
                if !special.contains(nt) { continue }

                if (cell == boss && n == escape) || (cell == escape && n == boss) {
                    continue
                }

                return false
            }
        }

        return true
    }

    private func countDeadEnds() -> Int {
        var count = 0
        for cell in tileType.keys {
            if cell == start { continue }
            if cell == boss, escape == boss { continue }
            if degree(cell) == 1 { count += 1 }
        }
        return count
    }

    // MARK: - Graph helpers

    private func setTile(_ cell: Cell, _ t: TileType) {
        tileType[cell] = t
        connections[cell, default: []] = connections[cell, default: []]
    }

    private func connect(_ a: Cell, _ b: Cell) {
        connections[a, default: []].insert(b)
        connections[b, default: []].insert(a)
    }

    private func degree(_ cell: Cell) -> Int {
        connections[cell]?.count ?? 0
    }

    private func neighbors4(_ c: Cell) -> [Cell] {
        [
            .init(x: c.x + 1, y: c.y),
            .init(x: c.x - 1, y: c.y),
            .init(x: c.x, y: c.y + 1),
            .init(x: c.x, y: c.y - 1)
        ]
    }

    private func inBounds(_ c: Cell) -> Bool {
        c.x >= 0 && c.x < Self.gridW && c.y >= 0 && c.y < Self.gridH
    }

    private func manhattan(_ a: Cell, _ b: Cell) -> Int {
        abs(a.x - b.x) + abs(a.y - b.y)
    }

    private func randCell() -> Cell {
        .init(x: rng.int(in: 0...(Self.gridW - 1)), y: rng.int(in: 0...(Self.gridH - 1)))
    }

    private func isOnMainPath(_ cell: Cell) -> Bool {
        mainPath.contains(cell)
    }

    private func isAdjacentSpecial(_ cell: Cell) -> Bool {
        let special: Set<TileType> = [.puzzle, .treasure, .secret, .boss, .escape]
        for n in neighbors4(cell) where inBounds(n) {
            let nt = tileType[n] ?? .none
            if special.contains(nt) { return true }
        }
        return false
    }

    private func uniqueIntsWithin(_ src: [Int], minV: Int, maxV: Int, desired: Int) -> [Int] {
        var used: Set<Int> = []
        var out: [Int] = []

        for v in src {
            let clamped = max(minV, min(maxV, v))
            if used.insert(clamped).inserted {
                out.append(clamped)
            }
        }

        var tries = 0
        while out.count < desired && tries < 200 {
            tries += 1
            let c = rng.int(in: minV...maxV)
            if used.insert(c).inserted {
                out.append(c)
            }
        }

        out.sort()
        return out
    }

    private func clear() {
        tileType.removeAll()
        connections.removeAll()
        progressionData.removeAll()
        mainPath.removeAll()
        start = .init(x: 0, y: 0)
        boss = .init(x: 0, y: 0)
        escape = .init(x: 0, y: 0)
    }

    private func currentSeed() -> Int {
        // Expose the current RNG seed in a stable way:
        // We keep it in the external call path; for now just return a random-ish constant if needed.
        // Prefer: you pass seed into init.
        return Int(Date().timeIntervalSince1970)
    }

    // MARK: - Deterministic Variant + Doors (port)

    // Stable hash (FNV-1a) for cross-machine determinism
    private func stableHash(_ s: String) -> Int {
        var h: UInt32 = 2166136261
        for scalar in s.unicodeScalars {
            h = h ^ UInt32(scalar.value)
            h = h &* 16777619
        }
        return Int(h & 0x7fffffff)
    }

    private func stableHashForTile(seed: Int, cell: Cell, typeStr: String, extra: String) -> Int {
        let s = "\(seed)|\(cell.x)|\(cell.y)|\(typeStr)|\(extra)"
        return stableHash(s)
    }

    func connectionMask(_ cell: Cell) -> Int {
        // Door mask: N=1, E=2, S=4, W=8
        guard let neigh = connections[cell] else { return 0 }
        var mask = 0

        let n = Cell(x: cell.x, y: cell.y - 1)
        let e = Cell(x: cell.x + 1, y: cell.y)
        let s = Cell(x: cell.x, y: cell.y + 1)
        let w = Cell(x: cell.x - 1, y: cell.y)

        if neigh.contains(n) { mask |= 1 }
        if neigh.contains(e) { mask |= 2 }
        if neigh.contains(s) { mask |= 4 }
        if neigh.contains(w) { mask |= 8 }

        return mask
    }

    func hallShape(for cell: Cell) -> String {
        let mask = connectionMask(cell)
        let deg = degree(cell)

        if deg <= 1 { return "dead_end" }
        if deg == 2 {
            let isNS = (mask & 1 != 0) && (mask & 4 != 0)
            let isEW = (mask & 2 != 0) && (mask & 8 != 0)
            return (isNS || isEW) ? "straight" : "corner"
        }
        if deg == 3 { return "tee" }
        return "cross"
    }

    func pickVariantId(seed: Int, cell: Cell) -> String {
        let typeStr = (tileType[cell] ?? .none).typeString
        if typeStr == "hall" {
            let shape = hallShape(for: cell)
            let list = Self.hallVariants[shape] ?? []
            let h = stableHashForTile(seed: seed, cell: cell, typeStr: typeStr, extra: shape)
            return pickFromList(list, hash: h)
        }

        let list = Self.roomVariants[typeStr] ?? []
        if list.isEmpty { return "\(typeStr)_missing" }
        let h = stableHashForTile(seed: seed, cell: cell, typeStr: typeStr, extra: "")
        return pickFromList(list, hash: h)
    }

    private func pickFromList(_ list: [String], hash: Int) -> String {
        guard !list.isEmpty else { return "missing" }
        let idx = abs(hash) % list.count
        return list[idx]
    }

    func rotationY(seed: Int, cell: Cell) -> Double {
        let typeStr = (tileType[cell] ?? .none).typeString
        guard typeStr == "hall" else { return 0.0 }
        return rotationYForHall(cell)
    }

    private func rotationYForHall(_ cell: Cell) -> Double {
        let mask = connectionMask(cell)
        let deg = degree(cell)

        if deg == 1 {
            if mask & 1 != 0 { return 180 }
            if mask & 2 != 0 { return -90 }
            if mask & 4 != 0 { return 0 }
            if mask & 8 != 0 { return 90 }
        }

        if deg == 2 {
            let isNS = (mask & 1 != 0) && (mask & 4 != 0)
            // straight
            if isNS { return 0 }
            let isEW = (mask & 2 != 0) && (mask & 8 != 0)
            if isEW { return 90 }

            // corner
            if (mask & 1 != 0) && (mask & 2 != 0) { return 180 }
            if (mask & 2 != 0) && (mask & 4 != 0) { return -90 }
            if (mask & 4 != 0) && (mask & 8 != 0) { return 0 }
            if (mask & 8 != 0) && (mask & 1 != 0) { return 90 }
        }

        if deg == 3 {
            if mask & 1 == 0 { return 0 }
            if mask & 2 == 0 { return 90 }
            if mask & 4 == 0 { return 180 }
            if mask & 8 == 0 { return -90 }
        }

        return 0
    }

    // MARK: - Export

    private func buildDungeonGraph(seed: Int) -> DungeonGraph {
        var tiles: [DungeonGraph.Tile] = []
        tiles.reserveCapacity(tileType.count)

        for (cell, t) in tileType {
            let typeStr = t.typeString
            let variantId = pickVariantId(seed: seed, cell: cell)
            let doorMask = connectionMask(cell)
            let rotY = rotationY(seed: seed, cell: cell)
            let decorSeed = stableHashForTile(seed: seed, cell: cell, typeStr: typeStr, extra: "decor")

            tiles.append(.init(
                pos: [cell.x, cell.y],
                type: typeStr,
                variantId: variantId,
                doorMask: doorMask,
                rotationY: rotY,
                decorSeed: decorSeed
            ))
        }

        var edges: [DungeonGraph.Edge] = []
        var seen: Set<String> = []

        for (a, neigh) in connections {
            for b in neigh {
                let key1 = "\(a.x),\(a.y)|\(b.x),\(b.y)"
                let key2 = "\(b.x),\(b.y)|\(a.x),\(a.y)"
                if seen.contains(key1) || seen.contains(key2) { continue }
                seen.insert(key1)
                edges.append(.init(a: [a.x, a.y], b: [b.x, b.y]))
            }
        }

        let mainPathOut = mainPath.map { [$0.x, $0.y] }

        let puzzlesInOrder = mainPath.compactMap { c -> [Int]? in
            guard tileType[c] == .puzzle else { return nil }
            return [c.x, c.y]
        }

        // progression visuals placeholder
        let progression: [DungeonGraph.ProgressionVisual] = progressionData.compactMap { dict in
            guard
                let keyPos = dict["key_pos"] as? [Double],
                let gatePos = dict["gate_pos"] as? [Double],
                let color = dict["color"] as? [Double]
            else { return nil }

            // match JSON shape (3D positions)
            let key3 = [keyPos[0], 1.0, keyPos[1]]
            let gate3 = [gatePos[0], 1.0, gatePos[1]]
            return .init(keyPos: key3, gatePos: gate3, color: color)
        }

        return .init(
            version: 1,
            seed: seed,
            gridSize: [Self.gridW, Self.gridH],
            targets: .init(
                tilesMin: Self.targetTilesMin,
                tilesMax: Self.targetTilesMax,
                mainPathMinLen: Self.minMainPathLen,
                startBossMinManhattan: Self.minStartBossManhattan
            ),
            specials: .init(
                start: [start.x, start.y],
                boss: [boss.x, boss.y],
                escape: [escape.x, escape.y],
                puzzles: puzzlesInOrder
            ),
            tiles: tiles.sorted { a, b in
                if a.pos[1] == b.pos[1] { return a.pos[0] < b.pos[0] }
                return a.pos[1] < b.pos[1]
            },
            edges: edges,
            mainPath: mainPathOut,
            progressionVisuals: progression
        )
    }
}

import SwiftUI

struct DungeonRenderModel {
    let seed: Int
    let tileType: [Cell: TileType]
    let connections: [Cell: Set<Cell>]
    let mainPath: [Cell]
    let start: Cell
    let boss: Cell
    let escape: Cell

    func hasTile(_ c: Cell) -> Bool { tileType[c] != nil }

    func isConnected(_ a: Cell, _ b: Cell) -> Bool {
        connections[a]?.contains(b) == true
    }

    func doorMask(for c: Cell) -> Int {
        // N=1, E=2, S=4, W=8
        var mask = 0
        let n = Cell(x: c.x, y: c.y - 1)
        let e = Cell(x: c.x + 1, y: c.y)
        let s = Cell(x: c.x, y: c.y + 1)
        let w = Cell(x: c.x - 1, y: c.y)

        if isConnected(c, n) { mask |= 1 }
        if isConnected(c, e) { mask |= 2 }
        if isConnected(c, s) { mask |= 4 }
        if isConnected(c, w) { mask |= 8 }

        return mask
    }
}

struct DungeonGridView: View {

    let model: DungeonRenderModel

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let cellSize = min(size.width / 10.0, size.height / 10.0)
            let gridWidth = cellSize * 10.0
            let gridHeight = cellSize * 10.0
            let originX = (size.width - gridWidth) / 2.0
            let originY = (size.height - gridHeight) / 2.0

            ZStack(alignment: .topLeading) {

                // Background grid (optional)
                Rectangle()
                    .fill(.black.opacity(0.92))
                    .frame(width: gridWidth, height: gridHeight)
                    .position(x: originX + gridWidth / 2.0, y: originY + gridHeight / 2.0)

                // Tiles
                ForEach(0..<10, id: \.self) { y in
                    ForEach(0..<10, id: \.self) { x in
                        let c = Cell(x: x, y: y)
                        let rect = CGRect(
                            x: originX + Double(x) * cellSize,
                            y: originY + Double(y) * cellSize,
                            width: cellSize,
                            height: cellSize
                        )

                        TileCellView(
                            cell: c,
                            rect: rect,
                            tileType: model.tileType[c],
                            isOnMainPath: model.mainPath.contains(c),
                            seed: model.seed,
                            doorMask: model.hasTile(c) ? model.doorMask(for: c) : 0
                        )
                    }
                }

                // Walls (draw only for placed tiles; wall exists if NOT connected)
                Canvas { ctx, _ in
                    for (cell, _) in model.tileType {
                        let x = originX + Double(cell.x) * cellSize
                        let y = originY + Double(cell.y) * cellSize

                        let topLeft = CGPoint(x: x, y: y)
                        let topRight = CGPoint(x: x + cellSize, y: y)
                        let botLeft = CGPoint(x: x, y: y + cellSize)
                        let botRight = CGPoint(x: x + cellSize, y: y + cellSize)

                        // neighbors
                        let north = Cell(x: cell.x, y: cell.y - 1)
                        let east  = Cell(x: cell.x + 1, y: cell.y)
                        let south = Cell(x: cell.x, y: cell.y + 1)
                        let west  = Cell(x: cell.x - 1, y: cell.y)

                        // Place a wall if neighbor is missing OR not connected.
                        // Door is the absence of that wall.
                        if !model.hasTile(north) || !model.isConnected(cell, north) {
                            var p = Path()
                            p.move(to: topLeft); p.addLine(to: topRight)
                            ctx.stroke(p, with: .color(.white.opacity(0.85)), lineWidth: 2)
                        }
                        if !model.hasTile(south) || !model.isConnected(cell, south) {
                            var p = Path()
                            p.move(to: botLeft); p.addLine(to: botRight)
                            ctx.stroke(p, with: .color(.white.opacity(0.85)), lineWidth: 2)
                        }
                        if !model.hasTile(west) || !model.isConnected(cell, west) {
                            var p = Path()
                            p.move(to: topLeft); p.addLine(to: botLeft)
                            ctx.stroke(p, with: .color(.white.opacity(0.85)), lineWidth: 2)
                        }
                        if !model.hasTile(east) || !model.isConnected(cell, east) {
                            var p = Path()
                            p.move(to: topRight); p.addLine(to: botRight)
                            ctx.stroke(p, with: .color(.white.opacity(0.85)), lineWidth: 2)
                        }
                    }
                }
                .frame(width: gridWidth, height: gridHeight)
                .offset(x: originX, y: originY)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}

// MARK: - TileCellView

private struct TileCellView: View {

    let cell: Cell
    let rect: CGRect
    let tileType: TileType?
    let isOnMainPath: Bool
    let seed: Int
    let doorMask: Int

    var body: some View {
        let type = tileType ?? .none
        let color = tileColor(type)

        ZStack {
            Rectangle()
                .fill(color.opacity(tileType == nil ? 0.08 : 1.0))
                .overlay(
                    Rectangle()
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )

            if tileType != nil {
                VStack(spacing: 2) {
                    Text(type.typeString.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.9))

                    Text("(\(cell.x),\(cell.y))")
                        .font(.system(size: 8, weight: .regular, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))

                    Text("mask \(doorMask)")
                        .font(.system(size: 8, weight: .regular, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.55))

                    if isOnMainPath {
                        Text("MAIN")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(4)
            }
        }
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)
    }

    private func tileColor(_ t: TileType) -> Color {
        switch t {
        case .start: return .green.opacity(0.85)
        case .puzzle: return .blue.opacity(0.85)
        case .boss: return .red.opacity(0.85)
        case .escape: return Color.purple.opacity(0.85)
        case .treasure: return Color.yellow.opacity(0.75)
        case .secret: return Color.gray.opacity(0.55)
        case .empty: return Color(white: 0.2)
        case .hall: return Color(white: 0.08)
        default: return Color(white: 0.05)
        }
    }
}

import SwiftUI

enum VariantRegistry {

    static func allVariantIds() -> [String] {
        let room = DungeonGenerator.roomVariants.values.flatMap { $0 }
        let halls = DungeonGenerator.hallVariants.values.flatMap { $0 }
        return (room + halls).sorted()
    }

    @ViewBuilder
    static func view(for variantId: String) -> some View {
        // Placeholder. Replace per-variant later.
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(0.25), lineWidth: 1)
                )

            VStack(spacing: 6) {
                Text(variantId)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)

                Text("Placeholder Scene")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(10)
        }
    }
}


import SwiftUI

struct DoorMaskOverlay: View {
    let mask: Int // N=1,E=2,S=4,W=8

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let thick: CGFloat = 6

            ZStack {
                // If NOT open, draw blocker. If open, draw nothing.
                if (mask & 1) == 0 { Rectangle().frame(width: w, height: thick).position(x: w/2, y: thick/2) }
                if (mask & 2) == 0 { Rectangle().frame(width: thick, height: h).position(x: w - thick/2, y: h/2) }
                if (mask & 4) == 0 { Rectangle().frame(width: w, height: thick).position(x: w/2, y: h - thick/2) }
                if (mask & 8) == 0 { Rectangle().frame(width: thick, height: h).position(x: thick/2, y: h/2) }
            }
            .foregroundStyle(.white.opacity(0.35))
        }
    }
}


import SwiftUI

struct DungeonPrototypeScreen: View {

    @State private var seed: Int = Int(Date().timeIntervalSince1970)
    @State private var model: DungeonRenderModel?

    var body: some View {
        ZStack(alignment: .top) {
            if let model {
                DungeonGridView(model: model)
            } else {
                Color.black.ignoresSafeArea()
                Text("Generating…")
                    .foregroundStyle(.white.opacity(0.8))
            }

            // Debug HUD
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    Button("Regenerate") {
                        regenerate(seed: seed)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("New Seed") {
                        seed = Int.random(in: 1...Int.max/4)
                        regenerate(seed: seed)
                    }
                    .buttonStyle(.bordered)

                    Text("seed \(seed)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(.top, 12)
        }
        .onAppear {
            regenerate(seed: seed)
        }
    }

    private func regenerate(seed: Int) {
        let gen = DungeonGenerator(seed: seed)
        guard let result = gen.generate() else {
            model = nil
            return
        }

        model = .init(
            seed: result.seed,
            tileType: result.tileType,
            connections: result.connections,
            mainPath: result.mainPath,
            start: result.start,
            boss: result.boss,
            escape: result.escape
        )
    }
}

#Preview {
    DungeonPrototypeScreen()
}
