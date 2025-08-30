//
//  ConfettiParticleView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/5/25.
//

import SwiftUI

struct ConfettiParticleView: View {
    
    @State private var phase: Double = 0
    
    private let particle: ConfettiParticle
    private let screenSize: CGSize
    
    init(particle: ConfettiParticle,
         screenSize: CGSize) {
        
        self.particle = particle
        self.screenSize = screenSize
        
    }
    
    private var finalY: CGFloat {
        self.screenSize.height + 100
    }
    
    private var fallDuration: Double {
        self.particle.settings.fallDurationBase + (1.0 / self.particle.mass) + (self.particle.dragCoefficient * 0.5)
    }
    
    private func calculateOpacity(progress: Double,
                                  fadeStart: Double,
                                  fadeDuration: Double) -> Double {
        
        if progress < fadeStart {
            return 1.0
        } else if fadeDuration > 0 {
            
            let fadeProgress = (progress - fadeStart) / fadeDuration
            return max(0, 1.0 - fadeProgress)
            
        } else {
            return 0
        }
        
    }
    
    private func createMetallicGradient(for baseColor: Color,
                                        brightness: Double,
                                        intensity: Double) -> LinearGradient {
        
        if intensity == 0 {
            
            return LinearGradient(
                colors: [baseColor.opacity(brightness)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        }
        
        let baseOpacity = brightness
        let lightOpacity = min(1.0, brightness * (1 + 0.2 * intensity))
        let darkOpacity = max(0.3, brightness * (1 - 0.3 * intensity))
        
        return LinearGradient(
            colors: [
                baseColor.opacity(lightOpacity),
                baseColor.opacity(baseOpacity),
                baseColor.opacity(darkOpacity)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
    }
    
    @ViewBuilder
    private func particleShape(gradient: LinearGradient) -> some View {
        
        switch self.particle.shape {
        case .circle:
            Circle()
                .fill(gradient)
                .frame(width: self.particle.size, height: self.particle.size)
        case .square:
            Rectangle()
                .fill(gradient)
                .frame(width: self.particle.size, height: self.particle.size)
        case .star:
            Star(corners: 5, smoothness: 0.45)
                .fill(gradient)
                .frame(width: self.particle.size, height: self.particle.size)
        case .heart:
            Heart()
                .fill(gradient)
                .frame(width: self.particle.size, height: self.particle.size)
        case .custom(let path):
            path
                .fill(gradient)
                .frame(width: self.particle.size, height: self.particle.size)
        }
        
    }
    
    var body: some View {
        
        SwiftUI.TimelineView(.animation(minimumInterval: 1/60)) { timeline in
            
            let elapsed = timeline.date.timeIntervalSinceReferenceDate - self.phase
            let progress = min(elapsed / self.fallDuration, 1.0)
            
            let t = progress * self.fallDuration
            
            let xDecel = 1.0 - progress * 0.9
            let wobbleDecayFactor = 1.0 - (progress * self.particle.wobbleDecay)
            let wobble = sin(t * self.particle.wobbleFrequency) * self.particle.wobbleAmplitude * wobbleDecayFactor
            let xPos = self.particle.x + (self.particle.vx * t * xDecel * 0.15) + wobble
            
            let gravity = self.particle.settings.gravity
            let yVel = self.particle.vy + gravity * t
            let yPos = self.particle.y + (self.particle.vy * t * 0.3) + (0.5 * gravity * t * t * self.particle.mass * 0.8)
            
            let rotationDecay = 1.0 - (progress * 0.3)
            let rotationX = self.particle.rotationSpeedX * t * rotationDecay
            let rotationY = self.particle.rotationSpeedY * t * rotationDecay
            let rotationZ = self.particle.rotationSpeedZ * t * rotationDecay
            
            let fadeStart = self.particle.settings.fadeStartPercent
            let fadeDuration = self.particle.settings.fadeDuration
            
            let opacity = calculateOpacity(
                progress: progress,
                fadeStart: fadeStart,
                fadeDuration: fadeDuration
            )
            
            let useMetallic = self.particle.settings.metallicEnabled
            
            let rotationFactor = useMetallic ? abs(cos(rotationY * .pi / 180)) * abs(cos(rotationX * .pi / 180)) : 1.0
            let brightness = useMetallic ? (0.7 + (rotationFactor * 0.3)) : 1.0
            
            let glintAngle = fmod(abs(rotationY), 360)
            let showGlint = useMetallic && ((glintAngle > 85 && glintAngle < 95) || (glintAngle > 265 && glintAngle < 275))
            
            let effectiveIntensity = useMetallic ? self.particle.settings.metallicIntensity : 0
            let gradient = createMetallicGradient(
                for: self.particle.color,
                brightness: brightness,
                intensity: effectiveIntensity
            )
            
            ZStack {
                
                particleShape(gradient: gradient)
                
                if showGlint && particle.settings.shimmerIntensity > 0 {
                    
                    particleShape(gradient: LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(particle.settings.shimmerIntensity * 0.6),
                            Color.white.opacity(0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .blur(radius: 1)
                    
                }
                
            }
            .rotation3DEffect(
                .degrees(rotationX),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.5
            )
            .rotation3DEffect(
                .degrees(rotationY),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .rotation3DEffect(
                .degrees(rotationZ),
                axis: (x: 0, y: 0, z: 1),
                perspective: 0.5
            )
            .shadow(
                color: .black.opacity(useMetallic ? (0.3 * (1 - rotationFactor)) : 0.2),
                radius: useMetallic ? (2 + (2 * (1 - rotationFactor))) : 1,
                x: useMetallic ? (sin(rotationY * .pi / 180) * 2) : 0,
                y: useMetallic ? (2 - cos(rotationX * .pi / 180) * 2) : 1
            )
            .position(x: xPos, y: min(yPos, self.screenSize.height + 100))
            .opacity(max(0, opacity))
        }
        .onAppear {
            self.phase = Date.timeIntervalSinceReferenceDate
        }
        
    }
    
}
