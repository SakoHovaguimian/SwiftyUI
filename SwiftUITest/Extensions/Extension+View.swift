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
    
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
}
