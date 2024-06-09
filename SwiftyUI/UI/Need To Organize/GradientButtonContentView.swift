//
//  GradientButtonContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/29/23.
//

import SwiftUI

struct GradientButtonContentView: View {
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                
                GradientOutlineButton(colors: [
                    Color.green,
                    Color.blue,
                    Color.purple
                ])
                
                
                GradientOutlineButton(colors: [
                    Color(hex: "#f2709c"),
                    Color(hex: "#ff9472")
                ])
                
                
                GradientOutlineButton(colors: [
                    Color(hex: "#1CD8D2"),
                    Color(hex: "#93EDC7")
                ])
                
                GradientOutlineButton(colors: [
                    Color(hex: "#EB3349"),
                    Color(hex: "#F45C43")
                ])
                
                GradientOutlineButton(colors: [
                    Color(hex: "#1FA2FF"),
                    Color(hex: "#12D8FA"),
                    Color(hex: "#A6FFCB")
                ])
                
            }
            
        }
    }
    
}

#Preview {
    GradientButtonContentView()
}

struct GradientOutlineButton: View {
    
    let colors: [Color]
    
    var body: some View {
        Button {
            print("Tap me")
        } label: {
            
            Text ("Tap Me")
                .bold()
                .frame(width: UIScreen.main.bounds.width - 128, height: 50)
                .foregroundColor (.white)
                .overlay(
                    
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: self.colors,
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 5)
                    
                )
        }
    }
}
