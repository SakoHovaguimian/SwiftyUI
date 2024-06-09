//
//  AppFont.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/12/23.
//

import Foundation
import SwiftUI

enum AppFont {
    
    enum Header {
        
        /// 36
        case h1
        
        /// 28
        case h5
        
        /// 22
        case h6
        
        /// 20
        case h10
        
    }
        
    enum Title {
        
        /// 12 Medium
        case t1
        
        /// 12 Bold
        case t2
        
        /// 14 Bold
        case t4
        
        /// 16 Bold
        case t5
        
        /// 18 SemiBold
        case t6
        
        /// 24 Heavy
        case t10
        
    }
    
    enum Body {
        
        /// 12
        case b1
        
        /// 14
        case b4
        
        /// 16
        case b5
        
        /// 18
        case b10
        
    }
    
    case header(Header)
    case title(Title)
    case body(Body)
    
    var font: UIFont {
        
        switch self {
        case .header(let style):
            
            switch style {
            case .h1: return .systemFont(ofSize: 36, weight: .heavy)
            case .h5: return .systemFont(ofSize: 28, weight: .heavy)
            case .h6: return .systemFont(ofSize: 22, weight: .heavy)
            case .h10: return .systemFont(ofSize: 20, weight: .heavy)
            }
            
        case .title(let style):
            
            switch style {
            case .t1: return .systemFont(ofSize: 12, weight: .medium)
            case .t2: return .systemFont(ofSize: 12, weight: .bold)
            case .t4: return .systemFont(ofSize: 14, weight: .bold)
            case .t5: return .systemFont(ofSize: 16, weight: .bold)
            case .t6: return .systemFont(ofSize: 18, weight: .semibold)
            case .t10: return .systemFont(ofSize: 24, weight: .heavy)
            }
            
        case .body(let style):
            
            switch style {
            case .b1: return .systemFont(ofSize: 12, weight: .regular)
            case .b4: return .systemFont(ofSize: 14, weight: .regular)
            case .b5: return .systemFont(ofSize: 16, weight: .regular)
            case .b10: return .systemFont(ofSize: 18, weight: .regular)
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

extension UIFont {
    
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
        
    }
    
    class func serif(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.serif) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
        
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
