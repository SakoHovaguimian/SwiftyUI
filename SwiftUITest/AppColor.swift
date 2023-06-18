//
//  DemoColor.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/17/23.
//

import SwiftUI

struct AppColor {
    
    enum BackgroundStyle {
        
        case primary
        case secondary
        
    }
    
    enum TextStyle {
        
        case title
        case body
        
    }
    
    /// #EBEBEB
    static var eggShell: Color {
        return Color("eggshell")
    }
    
    /// #4B5267
    static var charcoal: Color {
        return Color("charcoal")
    }
    
    static func background(_ backgroundStyle: BackgroundStyle) -> Color {
        
        switch backgroundStyle {
        case .primary: return Color(light: AppColor.eggShell, dark: AppColor.charcoal)
        case .secondary: return Color(light: AppColor.charcoal, dark: AppColor.eggShell)
        }
        
    }
    
    static func textStyle(_ textStyle: TextStyle) -> Color {

        switch textStyle {
        case .title: return Color(light: AppColor.charcoal, dark: AppColor.eggShell)
        case .body: return AppColor.charcoal // use gray when we have it
        }

    }
    
    
}

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
    
}

extension Color {
    
    init(light lightModeColor: @escaping @autoclosure () -> Color,
         dark darkModeColor: @escaping @autoclosure () -> Color) {
        
        self.init(UIColor(
            light: UIColor(lightModeColor()),
            dark: UIColor(darkModeColor())
        ))
        
    }
    
}
