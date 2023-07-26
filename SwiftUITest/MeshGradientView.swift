//
//  MeshGradientView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/26/23.
//

import SwiftUI

struct MeshGradientView: View {
    
    @State var gradientAngle: Double = 0
    
    let colors: [Color] = [
        .pink,
        .red,
        .orange,
        .yellow,
        .green,
        .blue,
        .purple,
        .pink
    ]
    
    var body: some View {
        
        ZStack {
            
            Rectangle()
            .fill(
                AngularGradient(
                    gradient: Gradient(colors: colors),
                    center: .center, angle: .degrees(gradientAngle)
                ))
            .frame(width: UIScreen.main.bounds.width + 50, height: UIScreen.main.bounds.height + 50)
            .brightness(0.2)
            .saturation(0.7)
            .blur(radius: 35)
            
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            
            withAnimation(Animation.linear(duration: 12).repeatForever(autoreverses: false)) {
                
                self.gradientAngle = 360
                
            }
            
        }
    }
    
}

#Preview {
    MeshGradientView(gradientAngle: 0)
}
