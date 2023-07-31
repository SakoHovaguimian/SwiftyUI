//
//  AppShadow.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/31/23.
//

import SwiftUI

struct AppShadow: ViewModifier {
    
    func body(content: Content) -> some View {
        
        content
            .shadow(
                color: Color.black.opacity(0.5),
                radius: 10,
                x: 0,
                y: 0
            )
        
    }
    
}

extension View {
    
    @ViewBuilder
    func appShadow() -> some View {
        self.modifier(AppShadow())
    }
    
}
