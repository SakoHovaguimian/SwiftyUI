//
//  PhaseAnimationTest.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/31/25.
//

import SwiftUI

enum UpShakePhaseAnimation {
    
    case initial
    case lift
    case shakeLeft
    case shakeRight
    
    var scale: CGFloat {
        switch self {
        case .initial: 1
        case .lift: 1.2
        case .shakeLeft: 1.2
        case .shakeRight: 1.2
        }
    }
    
    var offsetY: CGFloat {
        switch self {
        case .initial: 0
        case .lift: -150
        case .shakeLeft: -150
        case .shakeRight: -150
        }
    }
    
    var rotationDegrees: CGFloat {
        switch self {
        case .initial: 0
        case .lift: 0
        case .shakeLeft: -15
        case .shakeRight: 15
        }
    }
    
    var animation: Animation {
        switch self {
        case .initial: .spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)
        case .lift: .spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)
        case .shakeLeft: .easeInOut
        case .shakeRight: .easeInOut
        }
    }
    
}

struct PhaseAnimationTest: View {
    
    @State private var increment: Int = 0
    
    var body: some View {
        
        Image(systemName: "bell.fill")
            .resizable()
            .foregroundStyle(.indigo)
            .frame(
                width: 120,
                height: 120
            )
            .phaseAnimator([
                UpShakePhaseAnimation.initial,
                UpShakePhaseAnimation.lift,
                UpShakePhaseAnimation.shakeLeft,
                UpShakePhaseAnimation.shakeRight,
                UpShakePhaseAnimation.shakeLeft,
                UpShakePhaseAnimation.shakeRight,
                UpShakePhaseAnimation.lift,
            ], trigger: self.increment) { view, phase in
                
                view
                    .scaleEffect(phase.scale)
                    .offset(y: phase.offsetY)
                    .rotationEffect(.degrees(phase.rotationDegrees))
                
            } animation: { phase in
                return phase.animation
            }
        
        
        AppButton(title: "Increment",
                  titleColor: .white,
                  backgroundColor: .indigo) {
            
            self.increment += 1
            
        }
        .padding(.top, 32)
        .padding(.horizontal, 32)
        
    }
    
}

#Preview {
    PhaseAnimationTest()
}
