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
        case .shakeLeft: -30
        case .shakeRight: 30
        }
    }
    
    var animation: Animation {
        switch self {
        case .initial: .spring(bounce: 0.5)
        case .lift: .spring(bounce: 0.5)
        case .shakeLeft: .easeInOut(duration: 0.15)
        case .shakeRight: .easeInOut(duration: 0.15)
        }
    }
    
}

struct UpShakeEffect<T: Equatable>: ViewModifier {
    
    var trigger: T
    
    var phases: [UpShakePhaseAnimation] = [
        .initial,
        .lift,
        .shakeLeft,
        .shakeRight,
        .shakeLeft,
        .shakeRight,
        .lift
    ]

    func body(content: Content) -> some View {
        
        content
            .phaseAnimator(self.phases,
                           trigger: trigger ) { view, phase in
                
                view
                    .scaleEffect(phase.scale)
                    .offset(y: phase.offsetY)
                    .rotationEffect(.degrees(phase.rotationDegrees), anchor: .top)
                
            } animation: { phase in
                phase.animation
            }
        
    }
    
}

extension View {
    
    func upShakeEffect<T: Equatable>(trigger: T) -> some View {
        self.modifier(UpShakeEffect(trigger: trigger))
    }
    
}

struct PhaseAnimationTest: View {
    
    @State private var increment = 0

    var body: some View {
        
        VStack {
            
            HStack {
                
                Image(systemName: "bell.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.indigo)
                    .frame(width: 128, height: 128)
                    .upShakeEffect(trigger: increment)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.indigo)
                    .frame(width: 128, height: 128)
                    .upShakeEffect(trigger: increment)
                
            }

            AppButton(title: "Trigger", titleColor: .white, backgroundColor: .indigo) {
                increment += 1
            }
            .padding(.top, 32)
            .padding(.horizontal, 32)
            
        }
        
    }
    
}

#Preview {
    PhaseAnimationTest()
}
