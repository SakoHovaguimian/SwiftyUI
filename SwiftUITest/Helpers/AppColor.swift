//
//  DemoColor.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/17/23.
//

import SwiftUI

struct AppColor {
    
    enum ButtonStyle {
        case primary
    }
    
    enum BackgroundStyle {
        
        case primary
        case secondary
        case tertiary
        case quad
        
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
    
    /// #95FE11
    static var brandGreen: Color {
        return Color("brand_green")
    }
    
    /// #FD659E
    static var brandPink: Color {
        return Color("brand_pink")
    }
    
    /// #15161A
    static var appGray: Color {
        return Color("background")
    }
    
    /// #1A1E23
    static var appGray2: Color {
        return Color("background_2")
    }
    
    /// #2E353f
    static var appGray3: Color {
        return Color("background_3")
    }
    
    static func background(_ backgroundStyle: BackgroundStyle) -> Color {
        
        switch backgroundStyle {
        case .primary: return Color(light: AppColor.appGray, dark: AppColor.appGray)
        case .secondary: return Color(light: AppColor.appGray2, dark: AppColor.appGray2)
        case .tertiary: return .black.opacity(0.5)
        case .quad: return self.appGray3
        }
        
    }
    
    static func textStyle(_ textStyle: TextStyle) -> Color {

        switch textStyle {
        case .title: return Color(light: AppColor.charcoal, dark: AppColor.eggShell)
        case .body: return AppColor.charcoal // use gray when we have it
        }

    }
    
    static func button(_ backgroundStyle: ButtonStyle) -> Color {
        
        switch backgroundStyle {
        case .primary: return Color(light: AppColor.brandGreen, dark: AppColor.brandPink)
        }
        
    }
    
}
