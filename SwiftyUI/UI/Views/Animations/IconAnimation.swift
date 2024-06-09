//
//  IconAnimation.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/3/24.
//

import SwiftUI

struct IconAnimation: View {
    
    @State var measuring = false
    let streamBlue = Color(.purple)
    let streamRed = Color(.green)
    
    var body: some View {
        Circle()
            .phaseAnimator([false, true]) { openPart, moveAround in
                Circle()
                    .stroke(style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round,
                        lineJoin: .round,
                        miterLimit: 0, dash: [10, 15], dashPhase: moveAround ? -100 : 225))
                    .frame(width: 64, height: 64)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [self.streamBlue, self.streamRed],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(2)
            } animation: { moveAround in
                    .linear.speed(0.05).repeatForever(autoreverses: false)
            }
        
    }
}

#Preview {
    IconAnimation()
        .preferredColorScheme(.dark)
}
