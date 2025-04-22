//
//  Toast.swift
//  Rival
//
//  Created by Sako Hovaguimian on 1/29/24.
//

import Foundation
import SwiftUI

struct ToastItem: Identifiable {
    
    enum Style {
        
        case standard
        case custom
        
    }
    
    enum Direction {
        
        case top
        case bottom
        
    }
    
    let id: UUID = .init()
    
    /// Custom Properties
    
    var style: Style = .standard
    var title: String
    var titleColor: Color
    var message: String?
    var messageColor: Color
    var symbol: String?
    var icon: String?
    var tint: Color
    var isUserInteractionEnabled: Bool = true
    
    /// Timing
    
    var timing: ToastTime? = .medium
    var direction: Direction = .top
    
}

enum ToastTime: CGFloat {
    
    case short = 1.0
    case medium = 3.0
    case long = 5.0
    case extraLong = 10.0
    
}

