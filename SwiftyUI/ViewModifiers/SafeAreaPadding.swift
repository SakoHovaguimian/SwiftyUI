//
//  SafeAreaPadding.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 8/2/23.
//

import SwiftUI
import Combine

struct CustomSafeAreaPadding: ViewModifier {
    
    enum Direction {
        
        case top
        case bottom
        
    }
    
    @StateObject var keyboardManager = KeyboardManager()
    
    var padding: CGFloat = Spacing.medium.value
    var direction: Direction = .bottom
    var shouldSupportKeyboardOffset: Bool = false
    
    var isKeyboardActive: Bool {
        return shouldSupportKeyboardOffset && self.keyboardManager.keyboardHeight != 0
    }
    
    func body(content: Content) -> some View {
        
        let modernDeviceOffset = (self.direction == .bottom)
        ? UIApplication.shared.keyWindow?.safeAreaInsets.bottom
        : UIApplication.shared.keyWindow?.safeAreaInsets.top
        
        if modernDeviceOffset == 0 {
            content.padding((self.direction == .bottom) ? .bottom : .top, self.padding)
        } else {
            
            let isBottomDirection = (self.direction == .bottom)
            let bottomOffset = self.isKeyboardActive ? Spacing.medium.value : Spacing.none.value
            let finalOffset = isBottomDirection ? bottomOffset : 0
            
            content
                .padding(.bottom, finalOffset)
            
        }
        
    }
    
}

extension View {
    
    func customSafeAreaPadding(padding: CGFloat = Spacing.medium.value,
                               for direction: CustomSafeAreaPadding.Direction = .bottom,
                               shouldSupportKeyboardOffset: Bool = false) -> some View {
        
        modifier(CustomSafeAreaPadding(
            padding: padding,
            direction: direction,
            shouldSupportKeyboardOffset: shouldSupportKeyboardOffset
        ))
        
    }
    
}
