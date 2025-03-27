//
//  CustomStaggeredTransition.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/26/25.
//

import SwiftUI

struct CustomStaggeredTransition: Transition {
    
    var index: Int
    var config: StaggeredConfig
    
    func body(content: Content, phase: TransitionPhase) -> some View {
        
        let isIdentity: Bool = (phase == .identity)
        let didDisappear: Bool = (phase == .didDisappear)
        
        let x: CGFloat = config.offset.width
        let y: CGFloat = config.offset.height
        
        let reverseX: CGFloat = config.disappearInSameDirection ? x : -x
        let disableX: CGFloat = config.noDisappearAnimation ? 0 : reverseX
        
        let reverseY: CGFloat = config.disappearInSameDirection ? y : -y
        let disableY: CGFloat = config.noDisappearAnimation ? 0 : reverseY
        
        let offsetX = isIdentity ? 0 : (didDisappear ? disableX : x)
        let offsetY = isIdentity ? 0 : (didDisappear ? disableY : y)
        
        return content
            .opacity(isIdentity ? 1 : 0)
            .blur(radius: isIdentity ? 0 : config.blurRadius)
            .compositingGroup()
            .scaleEffect(
                isIdentity ? 1 : config.scale,
                anchor: config.scaleAnchor
            )
            .offset(x: offsetX, y: offsetY)
            .animation(
                config.animation.delay(Double(index) * config.delay),
                value: phase
            )
        
    }
    
}
