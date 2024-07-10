//
//  AppSpacing.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/31/23.
//

import SwiftUI

enum Spacing {
    
    /// 0
    case none
    
    /// 4
    case xSmall
    
    /// 8
    case small
    
    /// 16
    case medium
    
    /// 24
    case large
    
    /// 32
    case xLarge
    
    /// custom
    case custom(CGFloat)
    
    var value: CGFloat {
        switch self {
        case .none: return 0
        case .xSmall: return 4
        case .small: return 8
        case .medium: return 16
        case .large: return 24
        case .xLarge: return 32
        case .custom(let size): return size
        }
    }
    
}

extension View {
    
    func padding(_ edges: Edge.Set = .all,
                 _ length: Spacing) -> some View {
        
        return self.padding(edges, length.value)
        
    }
    
    func padding(_ length: Spacing) -> some View {
        
        return self.padding(.all, length.value)
        
    }
    
}

extension CGFloat {
    
    static func spacing(_ spacing: Spacing) -> CGFloat {
        return spacing.value
    }
    
    /// Represents a spacing of 0.
    static let appNone = Spacing.none.value
    
    /// Represents a spacing of 4.
    static let appXSmall = Spacing.xSmall.value
    
    /// Represents a spacing of 8.
    static let appSmall = Spacing.small.value
    
    /// Represents a spacing of 16.
    static let appMedium = Spacing.medium.value
    
    /// Represents a spacing of 24.
    static let appLarge = Spacing.large.value
    
    /// Represents a spacing of 32.
    static let appXLarge = Spacing.xLarge.value
    
}

extension EdgeInsets {
    
    init(top: Spacing = .none,
         left: Spacing = .none,
         bottom: Spacing = .none,
         right: Spacing = .none) {
        
        self.init(
            top: top.value,
            leading: left.value,
            bottom: bottom.value,
            trailing: right.value
        )
        
    }
    
    init(spacing: Spacing) {
        
        self.init(
            top: spacing.value,
            leading: spacing.value,
            bottom: spacing.value,
            trailing: spacing.value
        )
        
    }

    init(verticalSpacing spacing: Spacing) {
        
        self.init(
            top: spacing.value,
            leading: 0,
            bottom: spacing.value,
            trailing: 0
        )
        
    }

    init(horizontalSpacing spacing: Spacing) {
        
        self.init(
            top: 0,
            leading: spacing.value,
            bottom: 0,
            trailing: spacing.value
        )
        
    }
    
}
