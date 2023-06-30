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
