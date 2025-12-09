//
//  ShineOnChangeModifier.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/9/25.
//

import SwiftUI

extension View {
    
    /// Adds a configurable one-shot shine effect when `value` changes.
    ///
    /// - Parameters:
    ///   - value: The value to observe for changes.
    ///   - colors: The gradient colors of the shine bar. Defaults to a white gloss.
    ///   - duration: How long the animation takes.
    ///   - widthRatio: How wide the shine is relative to the view (0.0 to 1.0+).
    ///   - angle: The rotation angle of the shine bar.
    ///   - rightToLeft: If true, the shine moves from Right to Left.
    @MainActor
    func shineOnChange<Value: Equatable>(of value: Value,
                                         colors: [Color] = [.clear, .white.opacity(0.8), .clear],
                                         duration: Double = 0.5,
                                         widthRatio: CGFloat = 0.3,
                                         angle: Angle = .degrees(20),
                                         rightToLeft: Bool = false) -> some View {
        
        self.keyframeAnimator(
            initialValue: 0.0,
            trigger: value
        ) { content, progress in
            
            content
                .overlay {
                    GeometryReader { proxy in
                        
                        let size = proxy.size
                        let barWidth = size.width * widthRatio
                        
                        // Calculate total distance the bar needs to travel to clear the view
                        let totalTravel = size.width + barWidth * 2
                        
                        // Determine start and end based on direction
                        let startX = rightToLeft ? size.width + barWidth : -barWidth
                        let directionMultiplier: CGFloat = rightToLeft ? -1 : 1
                        
                        let offsetX = startX + (totalTravel * progress * directionMultiplier)
                        
                        ShineLayer(
                            colors: colors,
                            barWidth: barWidth,
                            angle: angle,
                            size: size,
                            offsetX: offsetX
                        )
                        
                    }
                    
                }
                .mask(content)
            
        } keyframes: { _ in
            
            KeyframeTrack {
                CubicKeyframe(1.0, duration: duration)
            }
            
        }
        
    }
    
}

fileprivate struct ShineLayer: View {
    
    let colors: [Color]
    let barWidth: CGFloat
    let angle: Angle
    
    let size: CGSize
    let offsetX: CGFloat
    
    var body: some View {
        
        Rectangle()
            .fill(
                LinearGradient(
                    colors: self.colors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(
                width: self.barWidth,
                height: self.size.height
            )
            .rotationEffect(self.angle)
            .offset(x: self.offsetX)
            .blendMode(.screen)
            .allowsHitTesting(false)
        
    }
    
}

fileprivate struct ConfigurableScoreView: View {
    
    @State private var score: Int = 100
    @State private var health: Int = 100
    
    var body: some View {
        
        VStack(spacing: 40) {
            
            VStack {
                
                Text("Score")
                    .textCase(.uppercase)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("\(self.score)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .shineOnChange(
                        of: self.score,
                        colors: [.clear, .white.opacity(0.60), .clear],
                        duration: 0.80,
                        widthRatio: 0.30,
                        angle: .degrees(20)
                    )
                
                Button("Level Up") { self.score += 100 }
                    .buttonStyle(.bordered)
                
            }
            
            Divider()

            VStack {
                
                Text("Health")
                    .textCase(.uppercase)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    
                    Image(systemName: "heart.fill")
                    
                    Text("\(self.health)%")
                        .contentTransition(.numericText(value: Double(self.health)))
                        .animation(.bouncy, value: self.health)
                    
                }
                .font(.title.bold())
                .foregroundStyle(.red)
                .padding()
                .background(.red.opacity(0.3), in: Capsule())
                .shineOnChange(
                    of: self.health,
                    colors: [.clear, .red, .clear],
                    duration: 0.60,
                    widthRatio: 1,
                    angle: .degrees(-10),
                    rightToLeft: true
                )
                
                Button("Take Damage") { health -= 10 }
                    .buttonStyle(.bordered)
                
            }
            
        }
        .padding()
        
    }
    
}

#Preview {
    ConfigurableScoreView()
}
