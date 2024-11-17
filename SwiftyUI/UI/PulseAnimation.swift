//
//  PulseAnimation.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 11/13/24.
//


import SwiftUI

struct PulseAnimation: ViewModifier {
    
    @State private var animatePulse: Bool = false
    
    func body(content: Content) -> some View {
        
        content
            .opacity(animatePulse ? 0.3 : 1)
            .scaleEffect(animatePulse ? 0.8 : 1)
            .offset(x: animatePulse ? -50 : 0)
//            .offset(y: animatePulse ? -50 : 0)
            .rotationEffect(.degrees(animatePulse ? -32 : 0))
            .appOnTapGesture {
                
                withAnimation(.smooth(duration: 0.3).repeatForever(autoreverses: true)) {
                    animatePulse.toggle()
                }
                
            }
        
    }
    
}

extension View {
    
    func animatePulse() -> some View {
        modifier(PulseAnimation())
    }
    
}

#Preview {
    
    AppBaseView {
        
        Text("Pulse Animation")
            .appFont(with: .header(.h5))
            .padding(.large)
            .foregroundStyle(.white)
            .background(.blackedGray)
            .clipShape(.capsule)
            .animatePulse()
        
    }
    
}
