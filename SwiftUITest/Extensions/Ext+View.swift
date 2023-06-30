//
//  Extension+View.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/19/23.
//

import SwiftUI

extension View {
    
    func hideKeyboard() -> some View {
        
        self
            .onTapGesture {
                
                UIApplication
                    .shared
                    .sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                
            }
        
    }
    
    func showKeyboard() -> some View {
        
        self
            .onTapGesture {
                
                UIApplication
                    .shared
                    .sendAction(
                        #selector(UIResponder.becomeFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                
            }
        
    }
    
    func dismissKeyboard() {
        
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        keyWindow?.endEditing(true)
        
    }
    
    @ViewBuilder func `if`<Content: View>(_ condition: Bool,
                                          transform: (Self) -> Content) -> some View {
        
        if condition {
            transform(self)
        } else {
            self
        }
        
    }
    
    func addGlowEffect(color1:Color,
                       color2:Color,
                       color3:Color) -> some View {
        
        self.foregroundColor(Color(hue: 0.5, saturation: 0.8, brightness: 1))
        
            .background {
                self.foregroundColor(color1).blur(radius: 0).brightness(0.8)
            }
            .background {
                self.foregroundColor(color2).blur(radius: 4).brightness(0.35)
            }
            .background {
                self.foregroundColor(color3).blur(radius: 2).brightness(0.35)
            }
            .background {
                self.foregroundColor(color3).blur(radius: 12).brightness(0.35)
            }
        
    }
    
}
