//
//  iOS18AnimatedMeshGradient.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/11/24.
//

import SwiftUI

struct iOS18AnimatedMeshGradient: View {
    
    @State private var t: Float = 0.0
    @State private var timer: Timer?
    
    var body: some View {
        
        ZStack {
            
            meshGradient()
                .ignoresSafeArea()
            
            
        }
        .onAppear {
            
            self.timer = Timer.scheduledTimer(
                withTimeInterval: 0.01,
                repeats: true,
                block: { timer in
                    
                t += 0.02
                    
            })
            
        }
        
    }
    
    @ViewBuilder
    private func meshGradient() -> some View {
        
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                
                // Section 1
                
                [0.0, 0.0],
                [0.5, 0.0],
                [1.0, 0.0],
                
                // Sections 2
                
                [sinInRange (-0.8...(-0.2), 0.439, 0.342, t), sinInRange (0.3...0.7, 3.42, 0.984, t)],
                [sinInRange (0.1...0.8, 0.239, 0.084, t), sinInRange (0.2...0.8, 5.21, 0.242, t)],
                [sinInRange (1.0...1.5, 0.939, 0.084, t), sinInRange (0.4...0.8, 0.25, 0.642, t)],
                
                // Section 3
                
                [sinInRange (-0.8...0.0, 1.439, 0.442, t), sinInRange (1.4...1.9, 3.42, 0.984, t)],
                [sinInRange (0.3...0.6, 0.339, 0.784, t), sinInRange (1.0...1.2, 1.22, 0.772, t)],
                [sinInRange (1.0...1.5, 0.939, 0.056, t), sinInRange (1.3...1.7, 0.47, 0.342, t)]
                
                
            ],
            colors: [
                .blackedGray, .blackedGray, .blackedGray,
                .blue, .blue, .blue,
                .green, .green, .green
            ],
            background: .darkYellow,
            smoothsColors: true
            
        )
        
    }
    
    func sinInRange(_ range: ClosedRange<Float>, _ offset: Float, _ timeScale: Float, _ t: Float) -> Float {
        
        let amplitude = (range.upperBound - range.lowerBound) / 2
        let midPoint = (range.upperBound + range.lowerBound) / 2
        return midPoint + amplitude * sin((timeScale) * t + offset)
        
    }
    
}

#Preview {
    iOS18AnimatedMeshGradient()
}
