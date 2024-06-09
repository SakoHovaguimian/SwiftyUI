//
//  Ext+Color.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import UIKit
import SwiftUI

extension UIColor {
    
    convenience init(light lightModeColor: @escaping @autoclosure () -> UIColor,
                     dark darkModeColor: @escaping @autoclosure () -> UIColor) {
        
        self.init { traitCollection in
            
            switch traitCollection.userInterfaceStyle {
            case .light:
                return lightModeColor()
            case .dark:
                return darkModeColor()
            case .unspecified:
                return lightModeColor()
            @unknown default:
                return lightModeColor()
            }
            
        }
        
    }
    
    static func random() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
}

extension ShapeStyle where Self == Color {
    
    /// We use this to recognize tap gestures without adding color
    static var backgroundTappable: Color {
        return Color.minimumOpacity
    }
    
    static var blackedGray: Color {
        return Color.black.opacity(0.3)
    }
    
}

extension Color {
    
    /// We use this to recognize tap gestures without adding color
    static var minimumOpacity: Color {
        return .white.opacity(0.0000001)
    }
    
    init(light lightModeColor: @escaping @autoclosure () -> Color,
         dark darkModeColor: @escaping @autoclosure () -> Color) {
        
        self.init(UIColor(
            light: UIColor(lightModeColor()),
            dark: UIColor(darkModeColor())
        ))
        
    }
    
    init(hex: String) {
        
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func hexStringFromColor() -> String {
        
        let color = UIColor(self)
        
        let components = color.cgColor.components
        
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
        
        return hexString
        
     }
    
    func updateTintingForColor(saturation: CGFloat, brightness: CGFloat) -> Self {
        
        var hue: CGFloat = 0
        var _saturation: CGFloat = 0
        var _brightness: CGFloat = 0
        var alpha: CGFloat = 0

        UIColor(self).getHue(&hue, saturation: &_saturation, brightness: &_brightness, alpha: &alpha)
        return Color(hue: hue, saturation: saturation, brightness: brightness)
        
    }
    
}
