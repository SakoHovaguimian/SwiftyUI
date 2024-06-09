//
//  AppShadow.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/31/23.
//

import SwiftUI

enum Shadow {
    
    case card
    case neon(Color)
    
    var color: Color {
        switch self {
        case .card: return Color.black.opacity(0.3)
        case .neon(let color): return color
        }
    }
    
    var radius: CGFloat {
        switch self {
        case .card: return 5
        case .neon: return 11
        }
    }
    
    var yOffset: CGFloat {
        switch self {
        case .card: return 0
        case .neon: return 0
        }
    }
    
}

struct AppShadow: ViewModifier {
    
    var shadowStyle: Shadow = .card
    
    func body(content: Content) -> some View {
        
        content
            .shadow(
                color: self.shadowStyle.color,
                radius: self.shadowStyle.radius,
                x: 0,
                y: self.shadowStyle.yOffset
            )
        
    }
    
}

extension View {
    
    @ViewBuilder
    func appShadow(style: Shadow = .card) -> some View {
        self.modifier(AppShadow(shadowStyle: style))
    }
    
}
