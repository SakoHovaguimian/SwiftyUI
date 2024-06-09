//
//  ButtonStyles.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/17/24.
//

import SwiftUI

struct ButtonStylesView: View {
    
    var body: some View {
        
        VStack(spacing: 64) {
            
            Button(action: {}) {
                Text("Click Me")
            }
            .buttonStyle(FunViewButtonStyle())
            .padding(.horizontal, 48)
            
            Button(action: {}) {
                Text("Sako's Hovaguimian")
            }
            .buttonStyle(FunViewButtonStyle())
            .padding(.horizontal, 64)
            
            Button(action: {}) {
                Text("Button 4")
            }
            .buttonStyle(FunViewButtonStyle())
            .padding(.horizontal, 24)
            
        }
        
    }
    
}

#Preview {
    ButtonStylesView()
}

struct FunViewButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
        
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(.black)
            .foregroundStyle(.white)
            .clipShape(.capsule)
            .font(.callout)
            .fontWeight(.semibold)
            .shadow(color: .black.opacity(0.6), radius: 11)
        
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
        
    }
    
}
