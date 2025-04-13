//
//  SplashView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/3/24.
//

import SwiftUI

struct SplashView: View {
    @State private var innerGap = true
    let streamBlue = Color(#colorLiteral(red: 0, green: 0.3725490196, blue: 1, alpha: 1))
    
    var body: some View {
        ZStack {
            ForEach(0..<8) {
                Circle()
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.green, .red],
                            startPoint: .bottom,
                            endPoint: .leading
                        )
                    )
                    .frame(width: 3, height: 3)
                    .offset(x: innerGap ? 24 : 0)
                    .rotationEffect(.degrees(Double($0) * 45))
                    .hueRotation(.degrees(300))
            }
            
            ForEach(0..<8) {
                Circle()
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.green, streamBlue],
                            startPoint: .bottom,
                            endPoint: .leading
                        )
                    )
                    .frame(width: 4, height: 4)
                    .offset(x: innerGap ? 26 : 0)
                    .rotationEffect(.degrees(Double($0) * 45))
                    .hueRotation(.degrees(60))
                
            }
            .rotationEffect(.degrees(12))
        }
    }
}

#Preview {
    SplashView()
}


struct SplashViewDemo: View {
    
    @State private var triggerCount: Int = 0
    @State private var isLiked: Bool = false
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .strokeBorder(lineWidth: isLiked ? 0 : 4)
                .animation(.easeInOut(duration: 0.5).delay(0.1),value: isLiked)
                .frame(width: 70, height: 70)
                .foregroundColor(Color(.systemPink))
                .hueRotation(.degrees(isLiked ? 300 : 200))
                .scaleEffect(isLiked ? 1.15 : 0)
                .animation(.easeInOut(duration: 0.5), value: isLiked)
            
            SplashView()
                .opacity(isLiked ? 0 : 1)
                .animation(.easeInOut(duration: 0.5).delay(0.25), value: isLiked)
                .scaleEffect(isLiked ? 1.25 : 0)
                .animation(.easeInOut(duration: 0.5), value: isLiked)
            
            SplashView()
                .rotationEffect(.degrees(90))
                .opacity(isLiked ? 0 : 1)
                .offset(y: isLiked ? 6 : -6)
                .animation(.easeInOut(duration: 0.5).delay(0.2), value: isLiked)
                .scaleEffect(isLiked ? 1.25 : 0)
                .animation(.easeOut(duration: 0.5), value: isLiked)
            Image(systemName: "person.fill")
                .phaseAnimator([false, true], trigger: isLiked) { icon, scaleRotate in
                    icon
                        .rotationEffect(.degrees(scaleRotate ? -45 : 0), anchor: .bottomLeading)
                        .scaleEffect(scaleRotate ? 1.5 : 1)
                } animation: { scaleRotate in
                        .bouncy(duration: 0.4, extraBounce: 0.4)
                }
        }
        .onTapGesture {
            
            self.isLiked.toggle()
            self.triggerCount += 1
            
        }
        
    }
    
}

#Preview {
    SplashViewDemo()
}
