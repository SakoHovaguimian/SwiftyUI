//
//  PlinkoView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/7/26.
//

// TODO:
/// set gravity style
/// elimination style
/// randomly set names

import SwiftUI
import SpriteKit

// MARK: - Configuration Models

public enum PlinkoDropMode {
    
    /// The ball spawns at a random X position within the top bounds
    case random
    
    /// An indicator moves left/right automatically. Tapping drops the ball at that exact spot.
    case oscillating(speed: Double)
    
}

public enum PlinkoPegMode {
    
    /// Automatically calculates columns to fit width, ensuring minSpacing is respected.
    /// It will expand spacing to hit the edges.
    case autoFill(minSpacing: CGFloat)
    
}

public struct PlinkoTheme {
    
    public let backgroundColor: Color
    
    // Peg Styling
    public let pegColor: Color
    public let pegBorderColor: Color
    public let pegBorderWidth: CGFloat
    
    // Ball Styling
    public let ballColor: Color
    public let ballBorderColor: Color
    public let ballBorderWidth: CGFloat
    
    // Slot Styling
    public let slotDividerColor: Color
    public let slotTextColor: Color
    
    public init(backgroundColor: Color = .black,
                pegColor: Color = .white,
                pegBorderColor: Color = .clear,
                pegBorderWidth: CGFloat = 0.0,
                ballColor: Color = .yellow,
                ballBorderColor: Color = .white,
                ballBorderWidth: CGFloat = 1.0,
                slotDividerColor: Color = .gray,
                slotTextColor: Color = .white) {
        
        self.backgroundColor = backgroundColor
        
        self.pegColor = pegColor
        self.pegBorderColor = pegBorderColor
        self.pegBorderWidth = pegBorderWidth
        
        self.ballColor = ballColor
        self.ballBorderColor = ballBorderColor
        self.ballBorderWidth = ballBorderWidth
        
        self.slotDividerColor = slotDividerColor
        self.slotTextColor = slotTextColor
        
    }
    
}

public struct PlinkoSlot: Identifiable, Equatable {
    
    public let id = UUID()
    public let multiplier: Double
    public let text: String
    public let color: Color
    
    public init(multiplier: Double,
                text: String,
                color: Color) {
        
        self.multiplier = multiplier
        self.text = text
        self.color = color
        
    }
    
}

// MARK: - SpriteKit Scene

private struct PhysicsCategory {
    
    static let none: UInt32 = 0
    static let ball: UInt32 = 0x1 << 0
    static let peg: UInt32 = 0x1 << 1
    static let floor: UInt32 = 0x1 << 2
    static let wall: UInt32 = 0x1 << 3
    static let slotSensor: UInt32 = 0x1 << 4
    
}

final class PlinkoScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    
    public var theme: PlinkoTheme = PlinkoTheme()
    public var slots: [PlinkoSlot] = []
    public var pegMode: PlinkoPegMode = .autoFill(minSpacing: 30)
    public var dropMode: PlinkoDropMode = .random
    public var ballRadius: CGFloat = 8
    public var pegEndY: CGFloat = 100 // Configurable bottom limit for pegs
    
    // Callbacks
    
    public var onGameStart: (() -> Void)?
    public var onGameEnd: ((PlinkoSlot) -> Void)?
    
    // State
    
    private var isBallActive = false
    private var spawnerNode: SKShapeNode?
    private var spawnerDirection: CGFloat = 1.0
    
    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = UIColor.clear
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -4.8)
        self.physicsWorld.contactDelegate = self
        self.scaleMode = .resizeFill
        
        setupScene()
        
    }
    
    public func setupScene() {
        
        removeAllChildren()
        createWalls()
        createSlots()
        createPegs()
        
        if case .oscillating = self.dropMode {
            createSpawner()
        }
        
    }
    
    // MARK: - Scene Construction
    
    private func createWalls() {
        
        let wallThickness: CGFloat = 100
        let height = self.size.height * 2
        
        // Left Wall
        let leftWall = SKNode()
        leftWall.position = CGPoint(x: -wallThickness / 2, y: self.size.height / 2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: height))
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        leftWall.physicsBody?.friction = 0.0
        
        addChild(leftWall)
        
        // Right Wall
        let rightWall = SKNode()
        rightWall.position = CGPoint(x: self.size.width + wallThickness / 2, y: self.size.height / 2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: height))
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        rightWall.physicsBody?.friction = 0.0
        
        addChild(rightWall)
        
    }
    
    private func createSlots() {
        
        guard !self.slots.isEmpty else { return }
        
        let slotWidth = self.size.width / CGFloat(self.slots.count)
        let slotHeight: CGFloat = 60
        
        // Floor
        let floor = SKNode()
        floor.position = CGPoint(x: self.size.width / 2, y: 0)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: 10))
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = PhysicsCategory.floor
        
        addChild(floor)
        
        for (index, slot) in self.slots.enumerated() {
            
            let xPos = (CGFloat(index) * slotWidth) + (slotWidth / 2)
            let yPos: CGFloat = slotHeight / 2
            
            // 1. Physical Divider (Wall)
            if index > 0 {
                
                let dividerX = CGFloat(index) * slotWidth
                let divider = SKShapeNode(rectOf: CGSize(width: 2, height: slotHeight))
                
                divider.fillColor = UIColor(self.theme.slotDividerColor)
                divider.strokeColor = .clear
                divider.position = CGPoint(x: dividerX, y: yPos)
                divider.zPosition = 1
                
                divider.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2, height: slotHeight))
                divider.physicsBody?.isDynamic = false
                divider.physicsBody?.categoryBitMask = PhysicsCategory.wall
                divider.physicsBody?.friction = 0.0
                
                addChild(divider)
                
            }
            
            // 2. Sensor
            let sensor = SKNode()
            sensor.position = CGPoint(x: xPos, y: yPos)
            sensor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: slotWidth - 10, height: 10))
            sensor.physicsBody?.isDynamic = false
            sensor.physicsBody?.categoryBitMask = PhysicsCategory.slotSensor
            sensor.physicsBody?.contactTestBitMask = PhysicsCategory.ball
            sensor.name = "SLOT_\(index)"
            
            addChild(sensor)
            
            // 3. Text
            let label = SKLabelNode(text: slot.text)
            label.fontSize = 14
            label.fontName = "ArialRoundedMTBold"
            label.fontColor = UIColor(self.theme.slotTextColor)
            label.position = CGPoint(x: xPos, y: 15)
            label.zPosition = 2
            
            addChild(label)
            
            // 4. Background
            let bg = SKShapeNode(rectOf: CGSize(width: slotWidth, height: slotHeight))
            bg.fillColor = UIColor(slot.color).withAlphaComponent(0.3)
            bg.strokeColor = .clear
            bg.position = CGPoint(x: xPos, y: yPos)
            bg.zPosition = 0
            
            addChild(bg)
            
        }
        
    }
    
    private func createPegs() {
        
        let pegRadius: CGFloat = 4
        let startY = self.size.height - 100
        
        // Use the configured bottom limit
        let endY: CGFloat = self.pegEndY
        
        let startX = pegRadius
        let endX = self.size.width - pegRadius
        let availableWidth = endX - startX
        
        var rows: Int = 0
        var cols: Int = 0
        var spacing: CGFloat = 0
        
        if case .autoFill(let minSpacing) = self.pegMode {
            
            let ballDiameter = self.ballRadius * 2
            let requiredGap = ballDiameter + 2
            let absoluteMinSpacing = (requiredGap + pegRadius) * 2
            let effectiveMinSpacing = max(minSpacing, absoluteMinSpacing)
            
            cols = Int(availableWidth / effectiveMinSpacing) + 1
            cols = max(cols, 3)
            
            if cols > 1 {
                spacing = availableWidth / CGFloat(cols - 1)
            } else {
                spacing = effectiveMinSpacing
            }
            
            rows = Int((startY - endY) / effectiveMinSpacing)
            
        }
        
        for row in 0..<rows {
            
            let isStaggered = row % 2 != 0
            let y = startY - (CGFloat(row) * spacing)
            
            if isStaggered {
                
                let colsInRow = cols - 1
                
                for col in 0..<colsInRow {
                    
                    let x = startX + (CGFloat(col) * spacing) + (spacing / 2)
                    createPeg(at: CGPoint(x: x, y: y), radius: pegRadius)
                    
                }
                
            } else {
                
                for col in 0..<cols {
                    
                    let x = startX + (CGFloat(col) * spacing)
                    createPeg(at: CGPoint(x: x, y: y), radius: pegRadius)
                    
                }
                
            }
            
        }
        
    }
    
    private func createPeg(at position: CGPoint, radius: CGFloat) {
        
        let peg = SKShapeNode(circleOfRadius: radius)
        
        peg.fillColor = UIColor(self.theme.pegColor)
        peg.strokeColor = UIColor(self.theme.pegBorderColor)
        peg.lineWidth = self.theme.pegBorderWidth
        peg.position = position
        
        peg.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        peg.physicsBody?.isDynamic = false
        peg.physicsBody?.categoryBitMask = PhysicsCategory.peg
        peg.physicsBody?.restitution = 0.5
        peg.physicsBody?.friction = 0.0
        
        addChild(peg)
        
    }
    
    private func createSpawner() {
        
        let spawner = SKShapeNode(circleOfRadius: self.ballRadius)
        
        spawner.fillColor = UIColor(self.theme.ballColor).withAlphaComponent(0.5)
        spawner.strokeColor = UIColor(self.theme.ballBorderColor)
        spawner.lineWidth = self.theme.ballBorderWidth
        spawner.position = CGPoint(x: self.size.width / 2, y: self.size.height - 40)
        
        self.spawnerNode = spawner
        
        addChild(spawner)
        
    }
    
    // MARK: - Game Logic
    
    public func dropBall() {
        
        guard !self.isBallActive else { return }
        
        self.onGameStart?()
        self.isBallActive = true
        self.spawnerNode?.isHidden = true
        
        let startX: CGFloat
        let safeMargin = (self.ballRadius * 2) + 2
        
        switch self.dropMode {
        case .random:
            startX = CGFloat.random(in: safeMargin...(self.size.width - safeMargin))
            
        case .oscillating:
            startX = self.spawnerNode?.position.x ?? self.size.width / 2
        }
        
        let ball = SKShapeNode(circleOfRadius: self.ballRadius)
        ball.fillColor = UIColor(self.theme.ballColor)
        ball.strokeColor = UIColor(self.theme.ballBorderColor)
        ball.lineWidth = self.theme.ballBorderWidth
        ball.position = CGPoint(x: startX, y: self.size.height - 40)
        ball.name = "ball"
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: self.ballRadius)
        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.slotSensor
        ball.physicsBody?.collisionBitMask = PhysicsCategory.peg | PhysicsCategory.wall | PhysicsCategory.floor
        
        ball.physicsBody?.restitution = 0.4
        ball.physicsBody?.friction = 0.2
        ball.physicsBody?.linearDamping = 0.1
        ball.physicsBody?.mass = 0.02
        
        addChild(ball)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if case .oscillating(let speed) = self.dropMode,
           !self.isBallActive,
           let spawner = self.spawnerNode {
            
            var newX = spawner.position.x + (self.spawnerDirection * CGFloat(speed))
            
            let limit = (self.ballRadius * 2) + 2
            
            if newX > self.size.width - limit {
                
                newX = self.size.width - limit
                self.spawnerDirection = -1
                
            } else if newX < limit {
                
                newX = limit
                self.spawnerDirection = 1
                
            }
            
            spawner.position.x = newX
            
        }
        
        self.children
            .filter { $0.name == "ball" && $0.position.y < -50 }
            .forEach {
                
                $0.removeFromParent()
                self.resetRound()
                
            }
        
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        
        guard self.isBallActive else { return }
        
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if mask == (PhysicsCategory.ball | PhysicsCategory.slotSensor) {
            
            let sensorNode = (contact.bodyA.categoryBitMask == PhysicsCategory.slotSensor)
                ? contact.bodyA.node
                : contact.bodyB.node
            
            if let name = sensorNode?.name,
               let indexStr = name.split(separator: "_").last,
               let index = Int(indexStr) {
                
                if index >= 0 && index < self.slots.count {
                    completeGame(with: self.slots[index])
                }
                
            }
            
        }
        
    }
    
    private func completeGame(with slot: PlinkoSlot) {
        
        if let ball = childNode(withName: "ball") {
            
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.3, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ])
            ball.run(pulse)
            
            let remove = SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ])
            ball.run(remove)
            
        }
        
        self.onGameEnd?(slot)
        resetRound()
        
    }
    
    private func resetRound() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            
            guard let self else { return }
            
            self.isBallActive = false
            
            if case .oscillating = self.dropMode {
                self.spawnerNode?.isHidden = false
            }
            
        }
        
    }
    
}

// MARK: - SwiftUI View Wrapper

public struct PlinkoView<HeaderContent: View>: View {
    
    private let slots: [PlinkoSlot]
    private let pegMode: PlinkoPegMode
    private let dropMode: PlinkoDropMode
    private let theme: PlinkoTheme
    private let ballRadius: CGFloat
    private let pegEndY: CGFloat
    private let headerContent: () -> HeaderContent
    
    private let onGameStart: (() -> Void)?
    private let onGameEnd: ((PlinkoSlot) -> Void)?
    
    @StateObject private var sceneWrapper = SceneWrapper()
    @State private var isGameActive = false
    
    public init(slots: [PlinkoSlot],
                pegMode: PlinkoPegMode = .autoFill(minSpacing: 40),
                dropMode: PlinkoDropMode = .random,
                theme: PlinkoTheme = PlinkoTheme(),
                ballRadius: CGFloat = 10,
                pegEndY: CGFloat = 100,
                onGameStart: (() -> Void)? = nil,
                onGameEnd: ((PlinkoSlot) -> Void)? = nil,
                @ViewBuilder header: @escaping () -> HeaderContent) {
        
        self.slots = slots
        self.pegMode = pegMode
        self.dropMode = dropMode
        self.theme = theme
        self.ballRadius = ballRadius
        self.pegEndY = pegEndY
        self.onGameStart = onGameStart
        self.onGameEnd = onGameEnd
        self.headerContent = header
        
    }
    
    public var body: some View {
        
        ZStack {
            
            self.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                self.headerContent()
                    .padding(.bottom, 20)
                
                GeometryReader { proxy in
                    
                    SpriteView(scene: self.sceneWrapper.scene, options: [.allowsTransparency])
                        .onAppear {
                            
                            self.sceneWrapper.scene.size = proxy.size
                            self.sceneWrapper.updateConfig(
                                slots: self.slots,
                                pegMode: self.pegMode,
                                dropMode: self.dropMode,
                                theme: self.theme,
                                ballRadius: self.ballRadius,
                                pegEndY: self.pegEndY
                            )
                            
                            self.sceneWrapper.scene.onGameStart = {
                                
                                self.isGameActive = true
                                self.onGameStart?()
                                
                            }
                            
                            self.sceneWrapper.scene.onGameEnd = { slot in
                                
                                self.isGameActive = false
                                self.onGameEnd?(slot)
                                
                            }
                            
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay {
                            
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            
                        }
                    
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                
            }
            
        }
        .onTapGesture {
            self.sceneWrapper.scene.dropBall()
        }
        
    }
    
}

final class SceneWrapper: ObservableObject {
    
    public let scene = PlinkoScene()
    
    public func updateConfig(slots: [PlinkoSlot],
                             pegMode: PlinkoPegMode,
                             dropMode: PlinkoDropMode,
                             theme: PlinkoTheme,
                             ballRadius: CGFloat,
                             pegEndY: CGFloat) {
        
        self.scene.slots = slots
        self.scene.pegMode = pegMode
        self.scene.dropMode = dropMode
        self.scene.theme = theme
        self.scene.ballRadius = ballRadius
        self.scene.pegEndY = pegEndY
        self.scene.setupScene()
        
    }
    
}

// MARK: - Showcase Previews

struct PlinkoShowcaseView: View {
    
    var body: some View {
        
        TabView {
            
            PlinkoDemoView()
                .tabItem { Label("Original", systemImage: "star.fill") }
            
            JumboCoinTossPreview()
                .tabItem { Label("Jumbo", systemImage: "circle.circle.fill") }
            
            BinaryOraclePreview()
                .tabItem { Label("Oracle", systemImage: "eye.fill") }
            
            NeonCyberpunkPreview()
                .tabItem { Label("Neon", systemImage: "bolt.fill") }
            
            CottonCandyPreview()
                .tabItem { Label("Candy", systemImage: "heart.fill") }
            
            HighStakesPreview()
                .tabItem { Label("Vegas", systemImage: "suit.diamond.fill") }
            
        }
        .preferredColorScheme(.dark)
        
    }
    
}

// MARK: - 1. The Original (Standard Demo)

struct PlinkoDemoView: View {
    
    @State private var lastWinner: PlinkoSlot?
    @State private var gameStatus: String = "Tap to Drop"
    
    private let demoSlots = [
        PlinkoSlot(multiplier: 10, text: "$10", color: .red),
        PlinkoSlot(multiplier: 5, text: "$5", color: .orange),
        PlinkoSlot(multiplier: 2, text: "$2", color: .yellow),
        PlinkoSlot(multiplier: 0, text: "$0", color: .gray),
        PlinkoSlot(multiplier: 2, text: "$2", color: .yellow),
        PlinkoSlot(multiplier: 5, text: "$5", color: .orange),
        PlinkoSlot(multiplier: 10, text: "$10", color: .red)
    ]
    
    var body: some View {
        
        PlinkoView(
            slots: self.demoSlots,
            pegMode: .autoFill(minSpacing: 32),
            dropMode: .oscillating(speed: 4.0),
            theme: PlinkoTheme(
                backgroundColor: Color(hex: "0d1b2a"),
                pegColor: .white,
                pegBorderColor: .white.opacity(0.5),
                pegBorderWidth: 1.0,
                ballColor: .cyan,
                ballBorderColor: .white,
                ballBorderWidth: 2.0,
                slotDividerColor: .white.opacity(0.3),
                slotTextColor: .white
            ),
            ballRadius: 8,
            pegEndY: 36, // Default Height
            onGameStart: {
                
                withAnimation {
                    self.gameStatus = "Ball Dropped!"
                    self.lastWinner = nil
                }
                
            },
            onGameEnd: { winner in
                
                withAnimation {
                    self.lastWinner = winner
                    self.gameStatus = "Won \(winner.text)!"
                }
                
            }
        ) {
            
            VStack(spacing: 12) {
                
                Text(self.gameStatus)
                    .font(.title2.bold())
                    .foregroundColor(self.lastWinner?.color ?? .white)
                
                if let winner = self.lastWinner {
                    
                    Text("Multiplier: \(String(format: "%.0fx", winner.multiplier))")
                        .font(.caption)
                        .padding(6)
                        .background(winner.color.opacity(0.2))
                        .cornerRadius(8)
                    
                }
                
                HStack {
                    
                    Image(systemName: "hand.tap")
                    Text("Tap screen to release")
                    
                }
                .font(.footnote)
                .foregroundColor(.gray)
                .opacity(self.lastWinner != nil ? 1 : 0.5)
                
            }
            .padding(.top, 40)
            
        }
        
    }
    
}

// MARK: - 2. Jumbo Coin Toss

private struct JumboCoinTossPreview: View {
    
    @State private var statusText: String = "HEADS OR TAILS?"
    
    private let slots: [PlinkoSlot] = [
        PlinkoSlot(multiplier: 1, text: "HEADS", color: Color(hex: "FFD700")), // Gold
        PlinkoSlot(multiplier: 1, text: "TAILS", color: Color(hex: "C0C0C0"))  // Silver
    ]
    
    var body: some View {
        
        PlinkoView(
            slots: self.slots,
            pegMode: .autoFill(minSpacing: 80),
            dropMode: .random,
            theme: PlinkoTheme(
                backgroundColor: Color(hex: "2C3E50"),
                pegColor: Color(hex: "34495E"),
                pegBorderColor: .white.opacity(0.2),
                pegBorderWidth: 2.0,
                ballColor: .white,
                ballBorderColor: .black.opacity(0.2),
                ballBorderWidth: 4.0,
                slotDividerColor: .white,
                slotTextColor: .black
            ),
            ballRadius: 25,
            pegEndY: 120, // Higher pegs
            onGameStart: {
                
                withAnimation {
                    self.statusText = "FLIPPING..."
                }
                
            },
            onGameEnd: { winner in
                
                withAnimation {
                    self.statusText = "\(winner.text) WINS!"
                }
                
            }
        ) {
            
            VStack(spacing: 8) {
                
                Text(self.statusText)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                Text("50 / 50")
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.1))
                    .clipShape(Capsule())
                
            }
            .padding(.top, 60)
            
        }
        
    }
    
}

// MARK: - 3. Binary Oracle

private struct BinaryOraclePreview: View {
    
    @State private var answer: String = "ASK THE ORACLE"
    
    private let slots: [PlinkoSlot] = [
        PlinkoSlot(multiplier: 0, text: "NO", color: .black),
        PlinkoSlot(multiplier: 1, text: "YES", color: .white)
    ]
    
    var body: some View {
        
        PlinkoView(
            slots: self.slots,
            pegMode: .autoFill(minSpacing: 60),
            dropMode: .oscillating(speed: 8.0),
            theme: PlinkoTheme(
                backgroundColor: Color(hex: "4A4A4A"),
                pegColor: .black,
                pegBorderColor: .white,
                pegBorderWidth: 2.0,
                ballColor: .white,
                ballBorderColor: .black,
                ballBorderWidth: 6.0,
                slotDividerColor: .white,
                slotTextColor: .gray
            ),
            ballRadius: 18,
            pegEndY: 80, // Lower pegs
            onGameStart: {
                
                withAnimation {
                    self.answer = "Thinking..."
                }
                
            },
            onGameEnd: { winner in
                
                withAnimation {
                    self.answer = winner.text
                }
                
            }
        ) {
            
            VStack(spacing: 20) {
                
                Text(self.answer)
                    .font(.system(size: 40, weight: .black))
                    .foregroundColor(self.answer == "YES" ? .white : (self.answer == "NO" ? .black : .gray))
                    .padding()
                    .background(self.answer == "NO" ? .white : (self.answer == "YES" ? .black : .clear))
                    .cornerRadius(12)
                    .animation(.spring, value: self.answer)
                
            }
            .padding(.top, 50)
            
        }
        
    }
    
}

// MARK: - 4. Neon Cyberpunk Theme

private struct NeonCyberpunkPreview: View {
    
    @State private var gameStatus: String = "CYBER DROP"
    @State private var lastWinner: PlinkoSlot?
    
    private let slots: [PlinkoSlot] = [
        PlinkoSlot(multiplier: 100, text: "MAX", color: Color(hex: "FF0099")),
        PlinkoSlot(multiplier: 10, text: "HIGH", color: Color(hex: "9D00FF")),
        PlinkoSlot(multiplier: 2, text: "MID", color: Color(hex: "00D4FF")),
        PlinkoSlot(multiplier: 0, text: "MISS", color: Color(hex: "1A1A1A")),
        PlinkoSlot(multiplier: 2, text: "MID", color: Color(hex: "00D4FF")),
        PlinkoSlot(multiplier: 10, text: "HIGH", color: Color(hex: "9D00FF")),
        PlinkoSlot(multiplier: 100, text: "MAX", color: Color(hex: "FF0099"))
    ]
    
    var body: some View {
        
        PlinkoView(
            slots: self.slots,
            pegMode: .autoFill(minSpacing: 35),
            dropMode: .oscillating(speed: 6.0),
            theme: PlinkoTheme(
                backgroundColor: Color(hex: "050505"),
                pegColor: Color(hex: "111111"),
                pegBorderColor: Color(hex: "00D4FF"),
                pegBorderWidth: 2.0,
                ballColor: Color(hex: "FF0099"),
                ballBorderColor: .white,
                ballBorderWidth: 1.0,
                slotDividerColor: Color(hex: "333333"),
                slotTextColor: .white
            ),
            ballRadius: 6,
            pegEndY: 60, // Close to slots
            onGameStart: {
                
                withAnimation {
                    self.gameStatus = "DROPPING..."
                    self.lastWinner = nil
                }
                
            },
            onGameEnd: { winner in
                
                withAnimation {
                    self.lastWinner = winner
                    self.gameStatus = "\(winner.text) HIT!"
                }
                
            }
        ) {
            
            VStack(spacing: 8) {
                
                Text(self.gameStatus)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .foregroundColor(self.lastWinner?.color ?? .white)
                    .shadow(color: self.lastWinner?.color ?? .blue, radius: 10)
                
                Text("TAP TO RELEASE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .opacity(0.8)
                
            }
            .padding(.top, 40)
            
        }
        
    }
    
}

// MARK: - 5. Cotton Candy Theme

private struct CottonCandyPreview: View {
    
    @State private var gameStatus: String = "Sweet Drop"
    
    private let slots: [PlinkoSlot] = [
        PlinkoSlot(multiplier: 5, text: "🍭", color: Color(hex: "FFB7B2")),
        PlinkoSlot(multiplier: 2, text: "🧁", color: Color(hex: "FFDAC1")),
        PlinkoSlot(multiplier: 1, text: "🍦", color: Color(hex: "E2F0CB")),
        PlinkoSlot(multiplier: 1, text: "🍩", color: Color(hex: "B5EAD7")),
        PlinkoSlot(multiplier: 2, text: "🧁", color: Color(hex: "C7CEEA")),
        PlinkoSlot(multiplier: 5, text: "🍭", color: Color(hex: "FFB7B2"))
    ]
    
    var body: some View {
        
        PlinkoView(
            slots: self.slots,
            pegMode: .autoFill(minSpacing: 45),
            dropMode: .random,
            theme: PlinkoTheme(
                backgroundColor: Color(hex: "F9F9F9"),
                pegColor: Color(hex: "E0E0E0"),
                pegBorderColor: .clear,
                pegBorderWidth: 0,
                ballColor: Color(hex: "FF9AA2"),
                ballBorderColor: .white,
                ballBorderWidth: 3.0,
                slotDividerColor: .gray.opacity(0.1),
                slotTextColor: .gray
            ),
            ballRadius: 12,
            onGameStart: {
                
                withAnimation {
                    self.gameStatus = "Wheee!"
                }
                
            },
            onGameEnd: { winner in
                
                withAnimation {
                    self.gameStatus = "Yum! \(winner.text)"
                }
                
            }
        ) {
            
            VStack(spacing: 4) {
                
                Text(self.gameStatus)
                    .font(.system(.title, design: .rounded).weight(.heavy))
                    .foregroundColor(Color(hex: "FF9AA2"))
                
                Text("Tap anywhere for a treat")
                    .font(.caption)
                    .foregroundColor(.gray)
                
            }
            .padding(.top, 40)
            
        }
        .colorScheme(.light)
        
    }
    
}

// MARK: - 6. High Stakes (Vegas) Theme

private struct HighStakesPreview: View {
    
    @State private var chips: Int = 1000
    @State private var lastWinAmount: Int = 0
    
    private let slots: [PlinkoSlot] = [
        PlinkoSlot(multiplier: 50, text: "50x", color: Color(hex: "FFD700")),
        PlinkoSlot(multiplier: 10, text: "10x", color: Color(hex: "C0C0C0")),
        PlinkoSlot(multiplier: 0, text: "0x", color: Color(hex: "8B0000")),
        PlinkoSlot(multiplier: 0.5, text: "0.5x", color: Color(hex: "2E8B57")),
        PlinkoSlot(multiplier: 0, text: "0x", color: Color(hex: "8B0000")),
        PlinkoSlot(multiplier: 10, text: "10x", color: Color(hex: "C0C0C0")),
        PlinkoSlot(multiplier: 50, text: "50x", color: Color(hex: "FFD700"))
    ]
    
    var body: some View {
        
        PlinkoView(
            slots: self.slots,
            pegMode: .autoFill(minSpacing: 25),
            dropMode: .oscillating(speed: 2.0),
            theme: PlinkoTheme(
                backgroundColor: Color(hex: "0B3D25"),
                pegColor: Color(hex: "F0E68C"),
                pegBorderColor: Color(hex: "B8860B"),
                pegBorderWidth: 1.0,
                ballColor: .white,
                ballBorderColor: .gray,
                ballBorderWidth: 1.0,
                slotDividerColor: Color(hex: "F0E68C").opacity(0.3),
                slotTextColor: Color(hex: "F0E68C")
            ),
            ballRadius: 5,
            pegEndY: 40, // High risk, slots are immediate
            onGameStart: {
                
                self.chips -= 100
                self.lastWinAmount = 0
                
            },
            onGameEnd: { winner in
                
                let win = Int(100.0 * winner.multiplier)
                self.lastWinAmount = win
                self.chips += win
                
            }
        ) {
            
            HStack(spacing: 40) {
                
                VStack(spacing: 4) {
                    
                    Text("BALANCE")
                        .font(.caption2.bold())
                        .foregroundColor(Color(hex: "F0E68C").opacity(0.7))
                    
                    Text("$\(self.chips)")
                        .font(.title2.bold())
                        .foregroundColor(Color(hex: "F0E68C"))
                    
                }
                
                VStack(spacing: 4) {
                    
                    Text("LAST WIN")
                        .font(.caption2.bold())
                        .foregroundColor(Color(hex: "F0E68C").opacity(0.7))
                    
                    Text(self.lastWinAmount > 0 ? "+\(self.lastWinAmount)" : "-")
                        .font(.title2.bold())
                        .foregroundColor(self.lastWinAmount > 0 ? .green : .white)
                    
                }
                
            }
            .padding(.top, 40)
            
        }
        
    }
    
}

#Preview {
    PlinkoShowcaseView()
}
