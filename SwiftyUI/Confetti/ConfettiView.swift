//
//  ConfettiView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/5/25.
//


import SwiftUI

public struct ConfettiView: View {
    
    @State private var particles: [ConfettiParticle] = []
    @Binding var trigger: Bool
    
    public var settings: ConfettiConfig
    public var colors: [Color]?
    
    public init(trigger: Binding<Bool>,
                settings: ConfettiConfig = .default(),
                colors: [Color]? = nil) {
        
        self._trigger = trigger
        self.settings = settings
        self.colors = colors
        
    }
    
    public init(trigger: Binding<Bool>,
                preset: SwiftettiPreset) {
        
        self._trigger = trigger
        self.settings = preset.settings
        self.colors = nil
        
    }
    
    public var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                
                ForEach(self.particles) { particle in
                    
                    ConfettiParticleView(
                        particle: particle,
                        screenSize: geometry.size
                    )
                    
                }
                
            }
            .onChange(of: self.trigger) { _, newValue in
                
                if newValue {
                    
                    addConfettiBurst(in: geometry.size)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.trigger = false
                    }
                    
                }
                
            }
            
        }
        .allowsHitTesting(false)
        
    }
    
    private func addConfettiBurst(in size: CGSize) {
        
        if self.particles.count + self.settings.particleCount > self.settings.maxTotalParticles {
            
            let toRemove = (self.particles.count + self.settings.particleCount) - self.settings.maxTotalParticles
            
            if toRemove > 0 && toRemove < particles.count {
                self.particles.removeFirst(toRemove)
            }
            
        }
        
        let burstX = size.width * self.settings.burstX
        let burstY = CGFloat(self.settings.burstY)
        
        let colorPalette = self.colors ?? self.settings.colorPalette
        
        for _ in 0..<settings.particleCount {
            
            let directionRad = self.settings.burstDirection * .pi / 180
            let coneAngleRad = self.settings.upwardBias * .pi / 180
            
            let angleWithinCone = Double.random(in: -coneAngleRad/2...coneAngleRad/2)
            let finalAngle = directionRad + angleWithinCone
            
            let minSpeed = min(self.settings.burstSpeedMin, self.settings.burstSpeedMax - 1)
            let maxSpeed = max(self.settings.burstSpeedMax, self.settings.burstSpeedMin + 1)
            let burstSpeed = Double.random(in: minSpeed...maxSpeed)
            
            let vx = cos(finalAngle) * burstSpeed
            let vy = sin(finalAngle) * burstSpeed
            
            let particle = ConfettiParticle(
                id: UUID(),
                x: burstX + CGFloat.random(in: -20...20),
                y: burstY,
                vx: vx,
                vy: vy,
                color: colorPalette.randomElement() ?? .white,
                size: CGFloat.random(in: min(settings.sizeMin, settings.sizeMax)...max(settings.sizeMin, settings.sizeMax)),
                shape: settings.shapes.randomElement() ?? .heart,
                mass: Double.random(in: min(settings.massMin, settings.massMax)...max(settings.massMin, settings.massMax)),
                dragCoefficient: Double.random(in: min(settings.dragMin, settings.dragMax)...max(settings.dragMin, settings.dragMax)),
                wobbleAmplitude: Double.random(in: min(settings.wobbleAmplitudeMin, settings.wobbleAmplitudeMax)...max(settings.wobbleAmplitudeMin, settings.wobbleAmplitudeMax)),
                wobbleFrequency: Double.random(in: min(settings.wobbleFrequencyMin, settings.wobbleFrequencyMax)...max(settings.wobbleFrequencyMin, settings.wobbleFrequencyMax)),
                wobbleDecay: settings.wobbleDecay,
                rotationSpeedX: Double.random(in: -360...360),
                rotationSpeedY: Double.random(in: -360...360),
                rotationSpeedZ: Double.random(in: -180...180),
                settings: self.settings
            )
            particles.append(particle)
            
        }
        
        let maxFallTime = self.settings.fallDurationBase + (1.0 / self.settings.massMin) + (self.settings.dragMax * 0.5) + 2.0
        let particlesToRemove = self.particles.suffix(settings.particleCount)
        let idsToRemove = particlesToRemove.map { $0.id }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + maxFallTime) {
            self.particles.removeAll { idsToRemove.contains($0.id) }
        }
        
    }
    
}

// MARK: - Presets

public enum SwiftettiPreset {
    
    case `default`
    case celebration
    case subtle
    case gold
    case rainbow
    
    var settings: ConfettiConfig {
        switch self {
        case .default:
            return .default()
        case .celebration:
            return .celebration()
        case .subtle:
            return .subtle()
        case .gold:
            return .gold()
        case .rainbow:
            return .rainbow()
        }
        
    }
    
}

#Preview {
    
    @Previewable @State var isOn = false
    
    ConfettiView(trigger: $isOn, settings: .rainbow())
        .safeAreaInset(edge: .bottom) {
            
            Button(action: {
                isOn.toggle()
            }) {
                Text("Toggle")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.indigo)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
            }
            
        }
    
}
