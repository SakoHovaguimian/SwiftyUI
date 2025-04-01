//
//  IconAnimation.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/3/24.
//

import SwiftUI

struct CommonLoadingView: View {
    
    let lineWidth: CGFloat
    let dashesArray: [CGFloat]
    let foregroundStyle: AppForegroundStyle
    
    @State private var rotation: Angle = .degrees(0)
    
    init(lineWidth: CGFloat = 12,
         dashesArray: [CGFloat] = [10, 15],
         foregroundStyle: AppForegroundStyle = .color(.indigo)) {
        
        self.lineWidth = lineWidth
        self.dashesArray = dashesArray
        self.foregroundStyle = foregroundStyle
        
    }
    
    var body: some View {
        
            Circle()
                .trim(from: 0, to: 1)
                .stroke(
                    style: StrokeStyle(
                        lineWidth: self.lineWidth,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: self.dashesArray
                    )
                )
                .foregroundStyle(self.foregroundStyle.foregroundStyle())
                .rotationEffect(self.rotation)
                .onAppear {
                    withAnimation(.linear(duration: 7.5).repeatForever(autoreverses: false)) {
                        self.rotation = .degrees(360)
                    }
                }
        }
    
}

#Preview {
    
    ZStack {
        
        Color(uiColor: .systemGray6)
            .ignoresSafeArea()
        
        CommonLoadingView(
            lineWidth: 4,
            foregroundStyle: .linearGradient(.linearGradient(
                colors: [.darkRed, .darkPurple, .darkGreen],
                startPoint: .top,
                endPoint: .bottom
            )))
            .frame(width: 128, height: 128)
        
    }
    .preferredColorScheme(.dark)
    
}
