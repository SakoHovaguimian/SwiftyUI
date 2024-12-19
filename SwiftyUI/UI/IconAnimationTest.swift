//
//  IconAnimationTest.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/19/24.
//

import SwiftUI

struct IconAnimationTest: View {
    
    @State private var isPlaying: Bool = false
    @State private var animation: CGFloat = 0
    
    private var icon: String {
        return self.isPlaying ? "pause.fill" : "play.fill"
    }
    
    var body: some View {
        
        ZStack {
            
            Color(uiColor: .systemGray2)
                .ignoresSafeArea()
            
            Image(systemName: self.icon)
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundStyle(.white)
                .contentTransition(.symbolEffect(.replace))
                .padding(32)
                .modifier(IconAnimationTestModifier(color: .brandGreen, size: 72))
//                .overlay {
//                    
//                    Circle()
//                        .trim(from: 0, to: 0.5)
//                        .stroke(.white.opacity(isPlaying ? 1 : 0), lineWidth: 2)
//                        .scaleEffect(self.isPlaying ? 1 : 0.8)
//                        .rotationEffect(.degrees(360 * Double(animation)))
//                        .animation(.bouncy, value: self.isPlaying)
//                    
//                }
//                .onChange(of: isPlaying) {
//                    
//                    withAnimation(.linear(duration: 3)
//                        .repeatForever(autoreverses: false)) {
//                            animation = 1
//                        }
//                    
//                }
//                .appOnTapGesture {
//                    
//                    withAnimation(.linear(duration: 0.3)) {
//                        isPlaying.toggle()
//                    }
//                    
//                }
            
        }
        
    }
    
}

#Preview {
    IconAnimationTest()
}

public struct IconAnimationTestModifier<T: ShapeStyle>: ViewModifier {
  private let speed = 0.3
  var color: T
  var size: Double
  @State private var circleSize = 0.00001
  @State private var strokeMultiplier = 1.0
  @State private var confettiIsHidden = true
  @State private var confettiMovement = 0.7
  @State private var confettiScale = 1.0
  @State private var contentScale = 0.00001
  public func body(content: Self.Content) -> some View {
    content
      .hidden()
      .padding(10)
      .overlay(
        ZStack {
          GeometryReader { proxy in
            Circle()
              .strokeBorder(color, lineWidth: proxy.size.width / 2 * strokeMultiplier)
              .scaleEffect(circleSize)
            ForEach(0..<15) { i in
              Circle()
                .fill(color)
                .frame(width: size + sin(Double(i)), height: size + sin(Double(i)))
                .scaleEffect(confettiScale)
                .offset(x: proxy.size.width / 2 * confettiMovement + (i.isMultiple(of: 2) ? size : 0))
                .rotationEffect(.degrees(24 * Double(i)))
                .offset(x: (proxy.size.width - size) / 2, y: (proxy.size.height - size) / 2)
                .opacity(confettiIsHidden ? 0 : 1)
            }
          }
          content
            .scaleEffect(contentScale)
        }
      )
      .padding(-10)
      .onAppear {
        withAnimation(.easeIn(duration: speed)) {
          circleSize = 1
        }
        withAnimation(.easeOut(duration: speed).delay(speed)) {
          strokeMultiplier = 0.00001
        }
        withAnimation(.interpolatingSpring(stiffness: 50, damping: 5).delay(speed)) {
          contentScale = 1
        }
        withAnimation(.easeOut(duration: speed).delay(speed * 1.25)) {
          confettiIsHidden = false
          confettiMovement = 1.2
        }
        withAnimation(.easeOut(duration: speed).delay(speed * 2)) {
          confettiScale = 0.00001
        }
      }
  }
}
