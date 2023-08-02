//
//  SafeAreaPadding.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 8/2/23.
//

import SwiftUI

struct CustomSafeAreaPadding: ViewModifier {
    
    enum Direction {
        
        case top
        case bottom
        
    }
    
    var padding: CGFloat = 8
    var direction: Direction = .bottom
    
    func body(content: Content) -> some View {
        
        let direction = self.direction == .bottom
        ? UIApplication.shared.keyWindow?.safeAreaInsets.bottom
        : UIApplication.shared.keyWindow?.safeAreaInsets.top
        
        if direction == 0 {
            content.padding(.bottom, self.padding)
        } else {
            content
        }
        
    }
    
}

extension View {
    
    func customSafeAreaPadding(padding: CGFloat = 8,
                               for direction: CustomSafeAreaPadding.Direction = .bottom) -> some View {
        
        modifier(CustomSafeAreaPadding(
            padding: padding,
            direction: direction
        ))
        
    }
    
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}
