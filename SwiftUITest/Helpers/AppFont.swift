//
//  AppFont.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/12/23.
//

import Foundation
import SwiftUI

enum AppFont {
    
    static var fontName = "Helvetica Neue"
    
    enum Heading {
        
        case h1
        case h5
        case h10
        
    }
    
    enum Body {
        
        case b1
        case b5
        case b10
        
    }
    
    case heading(Heading)
    case body(Body)
    
    var font: UIFont {
        
        switch self {
        case .heading(let style):
            
            switch style {
            case .h1: return UIFont.systemFont(ofSize: 10, weight: .medium)
            case .h5: return UIFont.systemFont(ofSize: 20, weight: .heavy)
            case .h10: return UIFont.systemFont(ofSize: 45, weight: .black)
            }
            
        case .body(let style):
            
            switch style {
            case .b1: return UIFont.systemFont(ofSize: 10, weight: .heavy)
            case .b5: return UIFont.systemFont(ofSize: 10, weight: .medium)
            case .b10: return UIFont.systemFont(ofSize: 10, weight: .medium)
            }
        }
        
    }
    
}

extension Font {
    
    static func appFont(_ font: AppFont) -> Font {
        
        let uiFont = font.font
        return Font(uiFont)
        
    }
    
}

// Modifier

struct AppFontViewModifier: ViewModifier {
    
    var font: AppFont!
    
    func body(content: Content) -> some View {
        content
            .font(.appFont(font))
    }
    
}

// Short-hand View Modifier

extension View {
    
    func appFont(with font: AppFont) -> some View {
        modifier(AppFontViewModifier(font: font))
    }
    
}
