//
//  ThemeManager.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import SwiftUI

enum ThemeChoice: String, CaseIterable {
    
    case light
    
    var theme: Theme {
        switch self {
        case .light: return Theme.WHITE
        }
    }
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        }
    }
    
}

struct Theme: Equatable {
    
    static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.accentColor == rhs.accentColor
    }
    
    enum Background {
        
        case primary
        case secondary
        case tertiary
        case quad
        
        func color(theme: Theme) -> Color {
            
            switch theme {
            case .WHITE:
                
                switch self {
                case .primary: return Color(.systemBackground)
                case .secondary: return Color(.secondarySystemBackground)
                case .tertiary: return Color(.tertiarySystemBackground)
                case .quad: return Color(.quaternarySystemFill)
                }
                
            default: return .blue
            }
            
        }
        
    }
    
    func gradient() -> LinearGradient {
        
        let primaryBackgroundColor = Color.white
        
        switch self {
        case .WHITE: return LinearGradient(colors: [primaryBackgroundColor], startPoint: .topLeading, endPoint: .bottomTrailing)
        default: return LinearGradient(colors: [primaryBackgroundColor], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        
    }
    
    func background(_ backgroundColor: Background) -> Color {
        return backgroundColor.color(theme: self)
    }
    
    
    let accentColor: Color
    let accentColorSecondary: Color
    
    var accentColorGradient: [Color] {
        return [self.accentColor, self.accentColorSecondary]
    }
    
    static let WHITE = Theme(
        accentColor: .pink,
        accentColorSecondary: .blue
    )
    
}

@Observable
class ThemeManager {
    
    static let shared = ThemeManager()
    
    private(set) var theme: Theme = Theme.WHITE
    
    func updateTheme(_ theme: Theme) {
        self.theme = theme
    }
    
    func accentColor() -> Color {
        return self.theme.accentColor
    }
    
    func background(_ backgroundColor: Theme.Background) -> Color {
        return self.theme.background(backgroundColor)
    }
    
    func backgroundGradient() -> LinearGradient {
        return self.theme.gradient()
    }
    
}

