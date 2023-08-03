//
//  CornerRadius.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 8/2/23.
//

import SwiftUI

enum CornerRadius: CGFloat {
    
    case extraSmall = 4
    case small = 8
    case medium = 16
    case large = 24
    case extraLarge = 32
    
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
