//
//  asButton.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/10/23.
//

import SwiftUI

struct ButtonStyleViewModifier: ButtonStyle {
    
    let scale: CGFloat
    let opacity: Double
    let brightness: Double
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? self.scale : 1)
            .animation(.interpolatingSpring(stiffness: 200, damping: 15), value: configuration.isPressed)
            .opacity(configuration.isPressed ? self.opacity : 1)
            .brightness(configuration.isPressed ? self.brightness : 0)
    }
    
}

extension View {
    
    func asButton(scale: CGFloat = 0.95,
                  opacity: Double = 1,
                  brightness: Double = 0,
                  action: @escaping () -> Void) -> some View {
        
        Button(action: {
            
            Haptics.shared.vibrate(option: .selection)
            action()
            
        }) {
            self
        }
        .buttonStyle(ButtonStyleViewModifier(scale: scale, opacity: opacity, brightness: brightness))
        
    }
    
    func appOnTapGesture(count: Int = 1,
                         hapticStyle: HapticOption = .selection,
                         perform action: @escaping () -> Void) -> some View {
        
        return self.gesture(
            TapGesture(count: count)
                .onEnded { _ in
                    
                    Haptics.shared.vibrate(option: hapticStyle)
                    action()
                    
                }
        )
        
    }
    
}
