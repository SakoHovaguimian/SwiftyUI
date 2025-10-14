//
//  SpriteKitGravity.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 10/14/25.
//

////
////  SpriteKit.swift
////  Rune
////
////  Created by Sako Hovaguimian on 10/14/25.
////
//
//import SwiftUI
//import SpriteKit
//
//// ******************************************
//// MARK: - MODEL
//// ******************************************
//
//public struct Chip: Identifiable {
//    
//    public let id: UUID = UUID()
//    public let title: String
//    public let systemImage: String
//    public let color: Color
//    
//    public init(
//        title: String,
//        systemImage: String,
//        color: Color
//    ) {
//        self.title = title
//        self.systemImage = systemImage
//        self.color = color
//    }
//    
//}
//
//// ******************************************
//// MARK: - SWIFTUI WRAPPER
//// ******************************************
//
//public struct PhysicsChipsView: View {
//    
//    // Inputs
//    public let chips: [Chip]
//    public var onSelectionChange: ([Chip]) -> Void = { _ in }
//    
//    // Config
//    public var displayScale: CGFloat = UIScreen.main.scale
//    public var backgroundColor: SKColor = .clear
//    public var gravityY: CGFloat = -9.8
//    public var restitution: CGFloat = 0.35
//    public var startDelay: TimeInterval = 0.15
//    
//    public init(
//        chips: [Chip],
//        displayScale: CGFloat = UIScreen.main.scale,
//        backgroundColor: SKColor = .clear,
//        gravityY: CGFloat = -9.8,
//        restitution: CGFloat = 0.35,
//        startDelay: TimeInterval = 0.15,
//        onSelectionChange: @escaping ([Chip]) -> Void = { _ in }
//    ) {
//        self.chips = chips
//        self.displayScale = displayScale
//        self.backgroundColor = backgroundColor
//        self.gravityY = gravityY
//        self.restitution = restitution
//        self.startDelay = startDelay
//        self.onSelectionChange = onSelectionChange
//    }
//    
//    public var body: some View {
//        SpriteView(
//            scene: FocusScene(
//                size: .init(width: 800, height: 800), // SpriteView will resize at runtime
//                chips: chips,
//                displayScale: displayScale,
//                backgroundColor: backgroundColor,
//                gravityY: gravityY,
//                bounceFactor: restitution,
//                startDelay: startDelay,
//                onSelectionChange: onSelectionChange
//            ),
//            options: [.allowsTransparency]
//        )
//        .ignoresSafeArea()
//    }
//    
//}
//
//// ******************************************
//// MARK: - SCENE
//// ******************************************
//
//final class FocusScene: SKScene {
//    
//    // Data
//    private let chips: [Chip]
//    private let onSelectionChange: ([Chip]) -> Void
//    
//    // Config
//    private let displayScale: CGFloat
//    private let backgroundColorConfig: SKColor
//    private let gravityY: CGFloat
//    private let restitution: CGFloat
//    private let startDelay: TimeInterval
//    
//    // Nodes
//    private var chipNodes: [(node: SKSpriteNode, chip: Chip)] = []
//    private var selectedChipIDs: Set<UUID> = []
//    
//    init(
//        size: CGSize,
//        chips: [Chip],
//        displayScale: CGFloat,
//        backgroundColor: SKColor,
//        gravityY: CGFloat,
//        bounceFactor: CGFloat,
//        startDelay: TimeInterval,
//        onSelectionChange: @escaping ([Chip]) -> Void
//    ) {
//        self.chips = chips
//        self.displayScale = displayScale
//        self.backgroundColorConfig = backgroundColor
//        self.gravityY = gravityY
//        self.restitution = bounceFactor
//        self.startDelay = startDelay
//        self.onSelectionChange = onSelectionChange
//        super.init(size: size)
//        self.scaleMode = .resizeFill
//    }
//    
//    required init?(coder: NSCoder) { nil }
//    
//    override func didMove(to view: SKView) {
//        
//        backgroundColor = backgroundColorConfig
//        
//        // Extend the frame downward to keep bodies in-bounds longer
//        let extendedFrame = CGRect(
//            x: frame.minX,
//            y: frame.minY,
//            width: frame.width,
//            height: frame.height + 1000
//        )
//        
//        physicsBody = SKPhysicsBody(edgeLoopFrom: extendedFrame)
//        physicsWorld.gravity = CGVector(dx: 0, dy: gravityY)
//        
//        // Gentle radial attractor to keep things near the top-center
//        let attractor = SKFieldNode.radialGravityField()
//        attractor.categoryBitMask = 0x40
//        attractor.strength = 0.0
//        attractor.falloff = 0.0
//        attractor.minimumRadius = 100
//        attractor.position = CGPoint(x: frame.midX, y: frame.height * 0.2)
//        addChild(attractor)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
//            self.spawn(y: self.frame.height + 200)
//        }
//        
//    }
//    
//}
//
//// ******************************************
//// MARK: - SPAWN + TOUCHES
//// ******************************************
//
//private extension FocusScene {
//    
//    func spawn(y: CGFloat) {
//        
//        for (i, chip) in chips.enumerated() {
//            
//            let view = RenderedChipView(chip: chip, selected: false)
//            let image = render(view: view)
//            let texture = SKTexture(image: image)
//            
//            let node = SKSpriteNode(texture: texture)
//            node.size = image.size
//            node.name = chip.id.uuidString
//            
//            // Rounded-capsule collision
//            let corner = node.size.height / 2
//            let bodyRect = CGRect(
//                x: -node.size.width / 2,
//                y: -node.size.height / 2,
//                width: node.size.width,
//                height: node.size.height
//            )
//            
//            let path = CGPath(
//                roundedRect: bodyRect,
//                cornerWidth: corner,
//                cornerHeight: corner,
//                transform: nil
//            )
//            
//            node.physicsBody = SKPhysicsBody(polygonFrom: path)
//            node.physicsBody?.restitution = restitution
//            node.physicsBody?.usesPreciseCollisionDetection = true
//            
//            let w = frame.width
//            let x = CGFloat.random(in: (w * 0.2)...(w * 0.8))
//            node.position = CGPoint(x: x, y: y + CGFloat.random(in: 0...80))
//            node.alpha = 0
//            
//            node.run(.sequence([
//                .wait(forDuration: 0.01 * Double(i)),
//                .fadeIn(withDuration: 0.0)
//            ]))
//            
//            addChild(node)
//            chipNodes.append((node: node, chip: chip))
//        }
//        
//    }
//    
//    // SwiftUI → UIImage
//    func render<V: View>(view: V) -> UIImage {
//        let renderer = ImageRenderer(content: view)
//        renderer.scale = displayScale
//        renderer.isOpaque = false
//        return renderer.uiImage ?? UIImage()
//    }
//    
//    // Toggle selection on touch, update texture, and callback
//    func toggleSelection(for match: (node: SKSpriteNode, chip: Chip)) {
//        
//        let isSelected = selectedChipIDs.contains(match.chip.id)
//        
//        if isSelected {
//            selectedChipIDs.remove(match.chip.id)
//        } else {
//            selectedChipIDs.insert(match.chip.id)
//        }
//        
//        // Re-render with selected state
//        let newImage = render(view: RenderedChipView(chip: match.chip, selected: !isSelected))
//        match.node.texture = SKTexture(image: newImage)
//        match.node.size = newImage.size
//        
//        // Emit selected chips
//        let selected = chipNodes
//            .filter { selectedChipIDs.contains($0.chip.id) }
//            .map { $0.chip }
//        
//        onSelectionChange(selected)
//    }
//    
//    // Touch handling
//    internal override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        guard
//            let touch = touches.first,
//            let touchedNode = nodes(at: touch.location(in: self)).compactMap({ $0 as? SKSpriteNode }).first,
//            let match = chipNodes.first(where: { $0.node == touchedNode })
//        else {
//            return
//        }
//        
//        toggleSelection(for: match)
//    }
//    
//}
//
//// ******************************************
//// MARK: - CHIP VIEW (SwiftUI → Texture)
//// ******************************************
//
//private struct RenderedChipView: View {
//    
//    let chip: Chip
//    let selected: Bool
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            
//            Image(systemName: chip.systemImage)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 20, height: 20)
//                .foregroundStyle(chip.color)
//            
//            Text(chip.title)
//                .font(.system(size: 17))
//                .bold()
//                .foregroundStyle(.black)
//        }
//        .padding(.horizontal, 18)
//        .padding(.vertical, 12)
//        .background(
//            chip.color.opacity(selected ? 0.22 : 0.10),
//            in: Capsule()
//        )
//        .overlay(
//            Capsule()
//                .strokeBorder(selected ? chip.color : .black, lineWidth: selected ? 2 : 1)
//        )
//    }
//    
//}
//
//// ******************************************
//// MARK: - EXAMPLE PREVIEW
//// ******************************************
//
//#Preview {
//    
//    @Previewable @State var selected: [Chip] = []
//    
//    return VStack(spacing: 0) {
//        
//        PhysicsChipsView(
//            chips: sampleChips,
//            backgroundColor: .clear,
//            gravityY: -9.8,
//            restitution: 0.28,
//            startDelay: 0.2
//        ) { chips in
//            selected = chips
//        }
//        
//        Text("Selected: \(selected.count)")
//            .font(.system(size: 14))
//            .padding(.top, 12)
//        
//        CommonButton(title: "Continue") { /* act on `selected` */ }
//            .padding(.horizontal, 32)
//            .padding(.top, 8)
//    }
//    
//}
//
//
//let sampleChips: [Chip] = [
//
//    .init(title: "Design", systemImage: "paintbrush.fill", color: .purple),
//    .init(title: "Build", systemImage: "hammer.fill", color: .orange),
//    .init(title: "Ship", systemImage: "paperplane.fill", color: .mint),
//    .init(title: "Learn", systemImage: "book.fill", color: .blue),
//    .init(title: "Think", systemImage: "brain.head.profile", color: .pink),
//    .init(title: "Create", systemImage: "sparkles", color: .indigo),
//    .init(title: "Explore", systemImage: "globe.americas.fill", color: .cyan),
//    .init(title: "Dream", systemImage: "cloud.moon.fill", color: .teal),
//    .init(title: "Play", systemImage: "gamecontroller.fill", color: .yellow),
//    .init(title: "Grow", systemImage: "leaf.fill", color: .green),
//    .init(title: "Focus", systemImage: "target", color: .red),
//    .init(title: "Inspire", systemImage: "lightbulb.fill", color: .orange),
//    .init(title: "Evolve", systemImage: "circle.hexagongrid.fill", color: .purple),
//    .init(title: "Refine", systemImage: "slider.horizontal.3", color: .gray),
//    .init(title: "Write", systemImage: "pencil.and.outline", color: .blue),
//    .init(title: "Capture", systemImage: "camera.fill", color: .pink),
//    .init(title: "Analyze", systemImage: "chart.bar.fill", color: .green),
//    .init(title: "Collaborate", systemImage: "person.2.fill", color: .cyan),
//    .init(title: "Imagine", systemImage: "sparkle.magnifyingglass", color: .mint),
//    .init(title: "Refactor", systemImage: "chevron.left.slash.chevron.right", color: .teal),
//    .init(title: "Test", systemImage: "checkmark.seal.fill", color: .orange),
//    .init(title: "Deploy", systemImage: "server.rack", color: .purple),
//    .init(title: "Debug", systemImage: "ant.fill", color: .red),
//    .init(title: "Optimize", systemImage: "gauge.medium", color: .blue),
//    .init(title: "Maintain", systemImage: "wrench.and.screwdriver.fill", color: .gray),
//    .init(title: "Secure", systemImage: "lock.shield.fill", color: .indigo),
//    .init(title: "Automate", systemImage: "gearshape.fill", color: .green),
//    .init(title: "Connect", systemImage: "link.circle.fill", color: .pink),
//    .init(title: "Share", systemImage: "square.and.arrow.up.fill", color: .orange),
//    .init(title: "Reflect", systemImage: "mirror.side.right", color: .purple)
//]
