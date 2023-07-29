//
//  MeshGradientView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/26/23.
//

import SwiftUI

struct MeshGradientView: View {
    
    @State var gradientAngle: Double = 0
    private var  shouldAnimate: Bool = false
    private var colors: [Color]
    
    init(gradientAngle: Double = 0,
         shouldAnimate: Bool = false,
         colors: [Color]) {
        
        self.gradientAngle = gradientAngle
        self.shouldAnimate = shouldAnimate
        self.colors = colors
        
    }
    
    var body: some View {
        
        GeometryReader { proxy in
            
            ZStack {
                
                Rectangle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: colors),
                        center: .center, angle: .degrees(gradientAngle)
                    ))
                .brightness(0.2)
                .saturation(0.7)
                .blur(radius: 10)
                .edgesIgnoringSafeArea(.all)
                
            }
//            .frame(width: proxy.size.width + 55, height: proxy.size.height + 55)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                
                withAnimation(Animation.linear(duration: 12).repeatForever(autoreverses: false)) {
                    
                    self.gradientAngle = 360
                    
                }
                
            }
            
        }
        
    }
    
}

#Preview {
    
    MeshGradientView(gradientAngle: 0,
                     shouldAnimate: true,
                     colors: [
                        .pink,
                        .red,
                        .orange,
                        .yellow,
                        .green,
                        .blue,
                        .purple,
                        .pink
                     ])
    
}
