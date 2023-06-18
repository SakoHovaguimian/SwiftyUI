//
//  CustomButton.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/15/23.
//

import SwiftUI

struct ButtonStyleViewModifier: ButtonStyle {
    
    let scale: CGFloat
    let opacity: Double
    let brightness: Double
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? opacity : 1)
            .brightness(configuration.isPressed ? brightness : 0)
    }
    
}

@available(iOS 14, *)
public extension View {
    
    /// Wrap a View in a Link and add a custom ButtonStyle.
    @ViewBuilder
    func asWebLink(scale: CGFloat = 0.95, opacity: Double = 1, brightness: Double = 0, url: @escaping () -> URL?) -> some View {
        if let url = url() {
            Link(destination: url) {
                self
            }
            .buttonStyle(ButtonStyleViewModifier(scale: scale, opacity: opacity, brightness: brightness))
        } else {
            self
        }
    }
    
    func asButton(scale: CGFloat = 0.95, opacity: Double = 1, brightness: Double = 0, action: @escaping @MainActor () -> Void) -> some View {
        Button(action: action) {
            self
        }
        .buttonStyle(ButtonStyleViewModifier(scale: scale, opacity: opacity, brightness: brightness))
    }
    
}

@available(iOS 14, *)
struct ButtonStyleViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack {
            
            Text("Hello")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .padding(.horizontal)
                .background(Color.red)
                .cornerRadiusIfNeeded(cornerRadius: 12)
                .asWebLink {
                    URL(string: "https://www.google.com")
                }
        }
        
    }
}
