//
//  CloudWithDotsView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 10/1/24.
//


import SwiftUI

struct DotsAnimationView: View {
    
    var shouldAnimate: Bool = true

    var body: some View {
        
        GeometryReader { geometry in
            
            HStack(spacing: 10) {
                
                ForEach(0..<3) { index in
                    
                    Circle()
                        .fill(Color.darkPurple)
                        .frame(width: 15, height: 15)
                        .offset(y: self.shouldAnimate ? -50 : 0)
                        .animation(
                            self.shouldAnimate ?
                            Animation.easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2) :
                            Animation.easeInOut(duration: 0.5),
                            value: self.shouldAnimate
                        )
                    
                }
                
            }
            .position(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2
            )
        }
        
    }
    
}

#Preview {
    
    @Previewable @State var shouldAnimate: Bool = false
    
    DotsAnimationView(shouldAnimate: shouldAnimate)
        .onTapGesture {
            shouldAnimate.toggle()
        }
    
}
