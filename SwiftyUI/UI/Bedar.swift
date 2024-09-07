//
//  Bedar.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/5/24.
//

import SwiftUI

public struct ActivationJourneyProgressView: View {
    @StateObject var viewModel: ActivationJourneyModel

    public var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 4
            let barSpacing = CGFloat(viewModel.totalStepCount - 1) * spacing
            let barSegmentWidth: CGFloat = (proxy.size.width - barSpacing) / CGFloat(viewModel.totalStepCount)
            
            ZStack {
                HStack(alignment: .center, spacing: spacing) {
                    ForEach(Array(viewModel.steps.enumerated()), id: \.element.id) { index, _ in
                        ZStack {
                            Rectangle()
                                .fill(Color(.gray))
                                .frame(width: barSegmentWidth)
                                .zIndex(1)
                            
                            if index < viewModel.completedStepCount {
                                Rectangle()
                                    .fill(Color(.blue))
                                    .frame(width: barSegmentWidth)
                                    .transition(.move(edge: .leading).animation(.easeInOut(duration: 2.0))
                                    )
                                    .zIndex(2)
                            }
                        }
                        .animation(.easeInOut(duration: 2.0), value: self.viewModel.completedStepCount)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 6)
        .onTapGesture {
            viewModel.toggleStepCompletion(self.viewModel.steps[4])
        }
    }
}

#Preview {
    ActivationJourneyProgressView(viewModel: ActivationJourneyModel())
}

public final class ActivationJourneyModel: ObservableObject {
    @Published public var steps: [ActivationJourneyStep]
    @Published public var remainingStepCount = 0
    @Published public var completedStepCount = 0
    @Published public var totalStepCount = 0
    
    public func toggleStepCompletion(_ step: ActivationJourneyStep) {
        if let index = steps.firstIndex(where: { $0.id == step.id }) {
            print("|| index: \(index)")
            withAnimation {
                steps[index].completed.toggle()
            }
        }
        updateState()
    }
    
    private func updateState() {
        totalStepCount = steps.count
        completedStepCount = steps.filter { $0.completed }.count
        remainingStepCount = totalStepCount - completedStepCount
    }
    
    public static let testData: [ActivationJourneyStep] = [
        ActivationJourneyStep(
            id: "A",
            label: "Take a Tour",
            description: "Try your new routine tonight by tapping your Restore at bedtime",
            ctaLabel: nil,
            action: .none,
            completed: true
        ),
        ActivationJourneyStep(
            id: "B",
            label: "Try it Out",
            description: "Learn even more tips to control your experience, phone-free",
            ctaLabel: "Tap to learn more",
            action: .none,
            completed: true
        ),
        ActivationJourneyStep(
            id: "C",
            label: "Play Favorites",
            description: "Save your favorite Unwinds to swap between, so you can always match your mood. Try a new one tonight",
            ctaLabel: "Set up now",
            action: .none,
            completed: true
        ),
        ActivationJourneyStep(
            id: "D",
            label: "Build Your Habit",
            description: "Use your routine another time this week to help build your new sleep habits",
            ctaLabel: nil,
            action: .none,
            completed: false
        ),
        ActivationJourneyStep(
            id: "E",
            label: "Stick To It",
            description: "Set up a reminder to keep your new habit on track",
            ctaLabel: "Let's go",
            action: .none,
            completed: false
        ),
        ActivationJourneyStep(
            id: "F",
            label: "Make Some Tweaks",
            description: "Editing your steps can help your routine feel just right. Tap : on any step to adjust it or find something new.",
            ctaLabel: nil,
            action: .none,
            completed: false
        )
    ]
    
    public init(steps: [ActivationJourneyStep] = ActivationJourneyModel.testData) {
        self.steps = steps
        updateState()
    }
}

public struct ActivationJourneyStep: Identifiable, Equatable, Codable {
    public var id: String
    public var label: String
    public var description: String
    public var ctaLabel: String?
    public var action: ActivationJourneyStepAction?
    public var completed: Bool
}

public enum ActivationJourneyStepAction: Equatable, Codable {
    case deeplink(String)
    case url(String)
}


//
//  SparkleView.swift
//
//  Created by Michael Bedar on 9/4/24.
//  Copyright hatch.co, 2024.
//

import SpriteKit
import SwiftUI

public struct SKSparkleView: View {
    @Binding var active: Bool
    private var duration: CGFloat = 3
    private var spreadSize: CGFloat
    
    public init(active: Binding<Bool>, duration: CGFloat = 3, spreadSize: CGFloat = 20) {
        self._active = active
        self.duration = duration
        self.spreadSize = spreadSize
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let scene = SparkleScene(
                active: $active,
                duration: duration,
                spreadSize: spreadSize,
                size: proxy.size,
                scaleMode: .aspectFill
            )
            
            SpriteView(scene: scene, options: [.allowsTransparency])
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }
}

class SparkleScene: SKScene {
    @Binding private var active: Bool
    private var isActive = false

    private var particleSystem = SKEmitterNode()
    private var duration: TimeInterval
    private var spreadSize: CGFloat
    
    private let waitAction: SKAction

    init(active: Binding<Bool>, duration: TimeInterval, spreadSize: CGFloat, size: CGSize, scaleMode: SKSceneScaleMode) {
        self._active = active
        self.duration = duration
        self.spreadSize = spreadSize
        self.waitAction = SKAction.wait(forDuration: duration)
        super.init(size: size)
        self.scaleMode = scaleMode
        self.backgroundColor = SKColor.clear
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateParticleSystemState() {
        if active {
            particleSystem.particleBirthRate = 20
            run(waitAction) { [weak self] in
                self?.particleSystem.particleBirthRate = 0
                self?.active = false
            }
        } else {
            particleSystem.particleBirthRate = 0
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        if active != isActive {
            updateParticleSystemState()
            isActive = active
        }
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        particleSystem.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        particleSystem.isPaused = false
        particleSystem.particleTexture = SKTexture(image: UIImage(resource: .prize))
        particleSystem.particleBlendMode = SKBlendMode.screen
        
        particleSystem.position = CGPoint(x: size.width / 2, y: size.height / 2)
        particleSystem.emissionAngleRange = CGFloat.pi * 2
        
        particleSystem.particleBirthRate = 0
        particleSystem.numParticlesToEmit = 0
        
        particleSystem.particleLifetime = 1.0
        particleSystem.particleLifetimeRange = 1.0
        
        particleSystem.particleSpeed = 20
        particleSystem.particleSpeedRange = 20
        
        particleSystem.fieldBitMask = 0x1
        
        particleSystem.particleAlphaSequence = SKKeyframeSequence(
            keyframeValues: [0.0, 1.0, 0.0],
            times: [0.0, 0.5, 1.0]
        )
        particleSystem.particleScaleSequence = SKKeyframeSequence(
            keyframeValues: [0.5, 1.0, 0.5],
            times: [0.0, 0.5, 1.0]
        )
        
        particleSystem.particlePosition = .zero
        particleSystem.particlePositionRange = .zero
        
        addChild(particleSystem)
    }
}

#Preview {
    SKSparkleView(active: .constant(true))
}
