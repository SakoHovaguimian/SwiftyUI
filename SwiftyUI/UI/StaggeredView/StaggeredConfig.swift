//
//  StaggeredConfig.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/26/25.
//

import SwiftUI

struct StaggeredConfig {
    
    var delay: Double = 0.05
    var maxDelay: Double = 0.4
    var blurRadius: CGFloat = 6
    var offset: CGSize = .init(width: 0, height: 0)
    var scale: CGFloat = 0.95
    var scaleAnchor: UnitPoint = .center
    var animation: Animation = .smooth(duration: 0.3, extraBounce: 0)
    var disappearInSameDirection: Bool = true
    var noDisappearAnimation: Bool = false
    
    // MARK: - Static Presets
    
    static func opacity(delay: Double = 0.05) -> StaggeredConfig {
        
        StaggeredConfig(
            delay: delay,
            blurRadius: 0,
            offset: .zero,
            scale: 1
        )
        
    }
    
    static func slide(from edge: Edge,
                      distance: CGFloat = 100,
                      delay: Double = 0.05) -> StaggeredConfig {
        
        switch edge {
        case .leading: return StaggeredConfig(delay: delay, offset: .init(width: -distance, height: 0))
        case .trailing: return StaggeredConfig(delay: delay, offset: .init(width: distance, height: 0))
        case .top: return StaggeredConfig(delay: delay, offset: .init(width: 0, height: -distance))
        case .bottom: return StaggeredConfig(delay: delay, offset: .init(width: 0, height: distance))
        }
        
    }
    
    static func scale(initialValue: CGFloat = 0.8,
                      delay: Double = 0.05) -> StaggeredConfig {
        
        StaggeredConfig(
            delay: delay,
            offset: .zero,
            scale: initialValue
        )
        
    }
    
    static func popIn(from edge: Edge,
                      scale: CGFloat = 0.8,
                      distance: CGFloat = 50,
                      delay: Double = 0.05) -> StaggeredConfig {
        
        var config = slide(
            from: edge,
            distance: distance,
            delay: delay
        )
        config.scale = scale
        
        return config
        
    }
    
    static func fadeAndSlideUp(distance: CGFloat = 50,
                               delay: Double = 0.05) -> StaggeredConfig {
        
        StaggeredConfig(
            delay: delay,
            blurRadius: 3,
            offset: .init(
                width: 0,
                height: distance
            )
        )
        
    }
    
    static func subtleZoom(delay: Double = 0.05) -> StaggeredConfig {
        
        StaggeredConfig(
            delay: delay,
            blurRadius: 0,
            offset: .zero,
            scale: 0.9
        )
        
    }
    
    static func blurFade(distance: CGFloat = 30,
                         blurRadius: CGFloat = 10,
                         delay: Double = 0.05) -> StaggeredConfig {
        
        StaggeredConfig(
            delay: delay,
            blurRadius: blurRadius,
            offset: .init(
                width: 0,
                height: distance
            )
        )
        
    }
    
    static func softSlideLeft(distance: CGFloat = 30,
                              delay: Double = 0.05) -> StaggeredConfig {
        
        StaggeredConfig(
            delay: delay,
            blurRadius: 5,
            offset: .init(
                width: distance,
                height: 0
            )
        )
        
    }
    
}
