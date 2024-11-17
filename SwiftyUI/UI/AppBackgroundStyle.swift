//
//  AppBackgroundStyle.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 11/16/24.
//


import SwiftUI

enum AppBackgroundStyle {
    
    case color(Color)
    case material(Material)
    case linearGradient(LinearGradient)
    
    func backgroundStyle() -> AnyShapeStyle {
        
        switch self {
        case .color(let color): return AnyShapeStyle(color)
        case .material(let material): return AnyShapeStyle(material)
        case .linearGradient(let gradient): return AnyShapeStyle(gradient)
        }
        
    }
    
    func viewStyle() -> some View {
        
        switch self {
        case .color(let color): return AnyView(Rectangle().fill(color))
        case .material(let material): return AnyView(Rectangle().fill(material))
        case .linearGradient(let gradient): return AnyView(Rectangle().fill(gradient))
        }
        
    }
    
}

enum AppForegroundStyle {
    
    case color(Color)
    case material(Material)
    case linearGradient(LinearGradient)
    
    func foregroundStyle() -> AnyShapeStyle {
        
        switch self {
        case .color(let color): return AnyShapeStyle(color)
        case .material(let material): return AnyShapeStyle(material)
        case .linearGradient(let gradient): return AnyShapeStyle(gradient)
        }
        
    }
    
    func viewStyle() -> some View {
        
        switch self {
        case .color(let color): return AnyView(Rectangle().fill(color))
        case .material(let material): return AnyView(Rectangle().fill(material))
        case .linearGradient(let gradient): return AnyView(Rectangle().fill(gradient))
        }
        
    }
    
}
