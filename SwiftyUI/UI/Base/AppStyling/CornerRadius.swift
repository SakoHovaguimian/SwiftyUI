//
//  CornerRadius.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 8/2/23.
//

import SwiftUI

enum CornerRadius: CGFloat {
    
    /// 0
    case none = 0
    
    /// 4
    case extraSmall = 4
    
    /// 8
    case small = 8
    
    /// 12
    case small2 = 12
    
    /// 16
    case medium = 16
    
    /// 24
    case large = 24
    
    /// 32
    case extraLarge = 32
    
    var value: CGFloat {
        return self.rawValue
    }
    
}

extension View {
    
    func cornerRadius(_ cornerRadius: CornerRadius) -> some View {
        
        self
            .clipShape(RoundedRectangle(
                cornerRadius: cornerRadius.rawValue,
                style: .continuous
            ))
        
    }
    
}
