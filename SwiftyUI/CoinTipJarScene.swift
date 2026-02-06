// TipJarWithGoal.swift
// SpriteKit-backed tip jar in SwiftUI with goal & overflow callbacks.

import SwiftUI
import SpriteKit
import Combine

// MARK: - SpriteKit Scene

final class CoinTipJarScene: SKScene, ObservableObject {

    // Published so SwiftUI can react
    @Published private(set) var totalTips: Int = 0

    // Callbacks
    var onGoalReached: ((Int) -> Void)?
    var onOverflow: ((Int) -> Void)?

    // Thresholds
    var goalAmount: Int?
    var overflowAmount: Int?

    private let coinValue = 1
    private var hasConfiguredPhysics = false

    // Internal guard so callbacks only fire once until reset
    private var goalReachedFired = false
    private var overflowFired = false

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        setupIfNeeded()
    }

    private func setupIfNeeded() {
        guard !hasConfiguredPhysics else { return }
        hasConfiguredPhysics = true
        setupJar()
        setupFloor()
    }

    private func setupJar() {
        let jarWidth: CGFloat = size.width * 0.5
        let jarHeight: CGFloat = size.height * 0.5
        let wallThickness: CGFloat = 10

        let base = SKNode()
        base.position = CGPoint(x: size.width / 2, y: jarHeight * 0.5)
        base.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: jarWidth, height: wallThickness))
        base.physicsBody?.isDynamic = false
        addChild(base)

        let left = SKNode()
        left.position = CGPoint(x: size.width / 2 - jarWidth / 2 + wallThickness / 2,
                                y: jarHeight)
        left.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: jarHeight))
        left.physicsBody?.isDynamic = false
        addChild(left)

        let right = SKNode()
        right.position = CGPoint(x: size.width / 2 + jarWidth / 2 - wallThickness / 2,
                                 y: jarHeight)
        right.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: jarHeight))
        right.physicsBody?.isDynamic = false
        addChild(right)

        let rim = SKShapeNode(rectOf: CGSize(width: jarWidth, height: jarHeight))
        rim.strokeColor = .white
        rim.lineWidth = 4
        rim.position = CGPoint(x: size.width / 2, y: jarHeight)
        rim.zPosition = 1
        addChild(rim)
        rim.name = "jar"
    }

    private func setupFloor() {
        let floor = SKNode()
        floor.position = CGPoint(x: size.width / 2, y: 0)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 10))
        floor.physicsBody?.isDynamic = false
        addChild(floor)
    }

    func dropCoin() {
        let coinRadius: CGFloat = 15
        let coin = SKShapeNode(circleOfRadius: coinRadius)
        coin.fillColor = .yellow
        coin.strokeColor = .orange
        coin.lineWidth = 2
        coin.position = CGPoint(x: size.width * 0.5 + CGFloat.random(in: -30...30),
                                y: size.height - coinRadius - 10)
        coin.zPosition = 2
        coin.name = "coin"

        coin.physicsBody = SKPhysicsBody(circleOfRadius: coinRadius)
        coin.physicsBody?.restitution = 0.3
        coin.physicsBody?.friction = 0.5
        coin.physicsBody?.mass = 0.1
        coin.physicsBody?.linearDamping = 0.3

        addChild(coin)
    }

    override func update(_ currentTime: TimeInterval) {
        children.filter { node in
            node.name == "coin" && node.position.y < -100
        }.forEach { $0.removeFromParent() }
    }

    override func didSimulatePhysics() {
        let jarWidth: CGFloat = size.width * 0.5
        let jarHeight: CGFloat = size.height * 0.5
        let leftBound = size.width / 2 - jarWidth / 2
        let rightBound = size.width / 2 + jarWidth / 2
        let bottomY = jarHeight * 0.5
        let topY = jarHeight + 5

        for node in children where node.name == "coin" {
            if node.userData?["counted"] as? Bool == true { continue }
            let pos = node.position
            if pos.x >= leftBound + 10 && pos.x <= rightBound - 10 &&
                pos.y >= bottomY && pos.y <= topY {
                incrementTotal()
                node.userData = ["counted": true]
                let pop = SKAction.sequence([
                    SKAction.scale(to: 1.2, duration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.1)
                ])
                node.run(pop)
            }
        }

        evaluateThresholds()
    }

    private func incrementTotal() {
        totalTips += coinValue
    }

    private func evaluateThresholds() {
        if let goal = goalAmount, totalTips >= goal, !goalReachedFired {
            goalReachedFired = true
            onGoalReached?(totalTips)
        }
        if let overflow = overflowAmount, totalTips >= overflow, !overflowFired {
            overflowFired = true
            onOverflow?(totalTips)
        }
    }

    // External resets
    func resetGoal() {
        goalReachedFired = false
    }

    func resetOverflow() {
        overflowFired = false
    }

    func setGoal(_ amount: Int?) {
        goalAmount = amount
        goalReachedFired = false
    }

    func setOverflow(_ amount: Int?) {
        overflowAmount = amount
        overflowFired = false
    }
}

// MARK: - SwiftUI Wrapper

struct TipJarView: View {

    @StateObject private var sceneHolder = SceneHolder()

    // Configuration
    var goal: Int?
    var overflow: Int?
    var onGoalReached: ((Int) -> Void)?
    var onOverflow: ((Int) -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Text("Tip Jar")
                .font(.title.weight(.semibold))

            Text("Total Tips: \(sceneHolder.scene.totalTips)")
                .font(.headline)
                .accessibilityIdentifier("totalTipsLabel")

            if let goal {
                ProgressView(value: Double(min(sceneHolder.scene.totalTips, goal)), total: Double(goal)) {
                    Text("Goal: \(goal)")
                }
                .padding(.horizontal)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.black.opacity(0.05))
                    .frame(height: 300)
                    .shadow(radius: 6)

                SpriteView(scene: sceneHolder.scene,
                           options: [.allowsTransparency])
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(height: 300)
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                Button {
                    sceneHolder.scene.dropCoin()
                } label: {
                    Label("1", systemImage: "circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(.blue.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button {
                    for _ in 0..<5 {
                        sceneHolder.scene.dropCoin()
                    }
                } label: {
                    Label("5", systemImage: "star.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(.green.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button {
                    for _ in 0..<100 {
                        sceneHolder.scene.dropCoin()
                    }
                } label: {
                    Label("100", systemImage: "star.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(.green.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            sceneHolder.scene.setGoal(goal)
            sceneHolder.scene.setOverflow(overflow)
            sceneHolder.scene.onGoalReached = { total in
                onGoalReached?(total)
            }
            sceneHolder.scene.onOverflow = { total in
                onOverflow?(total)
            }
        }
        .onChange(of: goal) { new in
            sceneHolder.scene.setGoal(new)
        }
        .onChange(of: overflow) { new in
            sceneHolder.scene.setOverflow(new)
        }
        .onReceive(sceneHolder.scene.$totalTips) { _ in
            // trigger view update
        }
        .padding()
    }

    // Holder to keep scene alive
    final class SceneHolder: ObservableObject {
        let scene: CoinTipJarScene

        init() {
            let sceneSize = CGSize(width: 300, height: 400)
            scene = CoinTipJarScene(size: sceneSize)
            scene.scaleMode = .resizeFill
        }
    }
}

// MARK: - Preview / Example Usage

struct TipJarWithGoal_Previews: PreviewProvider {
    static var previews: some View {
        TipJarView(
            goal: 10,
            overflow: 15,
            onGoalReached: { total in
                print("🎉 Goal hit! Total tips: \(total)")
            },
            onOverflow: { total in
                print("⚠️ Overflow! Total tips: \(total)")
            }
        )
        .frame(width: 350, height: 650)
    }
}
