//
//  GradientCardView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/7/23.
//

import SwiftUI

struct GradientCardView: View {
    
    @State private var rotation: CGFloat = 0
    
    let colors: [Color] = [
        .red,
        .green,
        .blue,
        .purple,
        .pink
    ]
    
    var body: some View {
        
        let linearGradient = LinearGradient(
            colors: self.colors,
            startPoint: .top,
            endPoint: .bottom
        )
        
        ZStack {
        
            Color.black
            
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .frame(
                width: 440,
                height: 430
            )
            .foregroundStyle(linearGradient)
            .rotationEffect(.degrees(self.rotation))
            .mask {
                
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .stroke(lineWidth: 3)
                .frame(
                    width: 250,
                    height: 335
                )
                .blur(radius: 10)
                
            }
            
            // Card
            
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .frame(
                width: 260,
                height: 340
            )
            .foregroundStyle(.black)
            
            // Card
            
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .frame(
                width: 500,
                height: 440
            )
            .foregroundStyle(linearGradient)
            .rotationEffect(.degrees(self.rotation))
            .mask {
                
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .stroke(lineWidth: 3)
                .frame(
                    width: 260,
                    height: 340
                )
                .blur(radius: 0)
                
            }
            
            Text("Legendary")
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(.white)
            
        }
        .ignoresSafeArea()
        .onAppear {
            
            withAnimation(
                .linear(duration: 4)
                .repeatForever()) {
                    
                    self.rotation = 360
                    
                }
            
        }
        
    }
    
}

#Preview {
    GradientCardView()
}
