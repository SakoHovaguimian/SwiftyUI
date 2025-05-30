//
//  SlideToConfirmView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 4/7/25.
//

import SwiftUI

struct SlideToConfirmView: View {
    
    @State private var shouldAnimateText: Bool = false
    @State private var offsetX: CGFloat = 0
    @State private var isCompleted: Bool = false
    
    let config: SlideConfig
    let onSwiped: () -> Void
    
    var body: some View {
        content()
    }
    
    private func content() -> some View {
        
        GeometryReader { geo in
            
            capsule(geo: geo)
            
        }
        .frame(height: self.isCompleted ? 50 : self.config.height)
        .containerRelativeFrame(.horizontal) { value, _ in
            
            let ratio: CGFloat = self.isCompleted ? 0.5 : 0.8
            return value * ratio
            
        }
        .frame(maxWidth: 300)
        .allowsHitTesting(!self.isCompleted)
        
    }
    
    private func capsule(geo: GeometryProxy) -> some View {
        
        let size = geo.size
        let knobSize = size.height
        let maxLimit = size.width - knobSize
        let progress: CGFloat = self.isCompleted ? 1 : (self.offsetX / maxLimit)
        
        return ZStack(alignment: .leading) {
            
            // Background
            
            Capsule()
                .fill(
                    .gray.opacity(0.25)
                    .shadow(.inner(color: .black.opacity(0.2), radius: 10))
                )
            
            // Foreground
            
            let extraCapsuleWidth = (size.width - knobSize) * progress
            
            Capsule()
                .fill(self.config.tint.gradient)
                .frame(width: knobSize + extraCapsuleWidth, height: knobSize)
            
            confirmationLeadingText(
                size: size,
                progress: progress
            )
            
            HStack {
                
                knobView(
                    size: size,
                    progress: progress,
                    maxLimit: maxLimit
                )
                .zIndex(1)
                
                shimmerText(
                    size: size,
                    progress: progress
                )
                
            }
            
        }
        
    }
    
    private func knobView(size: CGSize, progress: CGFloat, maxLimit: CGFloat) -> some View {
     
        Circle()
            .fill(.background)
            .padding(.custom(6))
            .frame(width: size.height, height: size.height)
            .overlay {
                
                ZStack {
                    
                    Image(systemName: "chevron.right")
                        .opacity(1 - progress)
                        .blur(radius: progress * 10)
                    
                    Image(systemName: "checkmark")
                        .opacity(progress)
                        .blur(radius: (1 - progress) * 10)
                    
                }
                .font(.title3)
                
            }
            .contentShape(.circle)
            .scaleEffect(self.isCompleted ? 0.6 : 1, anchor: .center)
            .offset(x: self.isCompleted ? maxLimit : self.offsetX)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        
                        self.offsetX = min(max(value.translation.width, 0), maxLimit)
                        
                    }
                    .onEnded { value in
                        
                        if self.offsetX == maxLimit {
                            
                            self.onSwiped()
                            self.shouldAnimateText = false
                            
                            withAnimation(.smooth) {
                                self.isCompleted = true
                            }
                            
                        } else {
                            
                            withAnimation(.smooth) {
                                self.offsetX = 0
                            }
                            
                        }
                        
                    }
            )
        
    }
    
    private func shimmerText(size: CGSize, progress: CGFloat) -> some View {
     
        Text(self.isCompleted ? self.config.confrimationText : self.config.idleText)
            .foregroundStyle(.gray.opacity(0.6))
            .overlay {
                
                // Shimmer Effect
                
                Rectangle()
                    .frame(height: 15)
                    .rotationEffect(.degrees(90))
                    .visualEffect { [shouldAnimateText] content, proxy in
                        
                        content
                            .offset(x: -proxy.size.width / 1.8)
                            .offset(x: shouldAnimateText ? proxy.size.width * 1.2 : 0)
                        
                    }
                    .mask(alignment: .leading) {
                        Text(self.config.idleText)
                    }
                    .blendMode(.softLight)
                
            }
            .fontWeight(.semibold)
            .mask {
                
                Rectangle()
                    .scale(x: 1 - (progress), anchor: .trailing)
                    .opacity(1 - progress)
                
            }
            .frame(maxWidth: .infinity)
            .padding(.trailing, size.height / 2)
            .frame(height: size.height)
            .task {
                
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    self.shouldAnimateText = true
                }
                
            }
        
    }
    
    private func confirmationLeadingText(size: CGSize, progress: CGFloat) -> some View {
     
        ZStack {
            
            Text(self.config.onSwipeText)
                .opacity(self.isCompleted ? 0 : 1)
                .blur(radius: self.isCompleted ? 10 : 0)
            
            Text(self.config.confrimationText)
                .opacity(self.isCompleted ? 1 : 0)
                .blur(radius: self.isCompleted ? 0 : 10)
            
        }
        .fontWeight(.semibold)
        .foregroundStyle(self.config.foregroundColor)
        .frame(maxWidth: .infinity)
//        .padding(.trailing, (size.height * (self.isCompleted ? 0.6 : 1)) / 2)
        .mask {
            
            Rectangle()
                .scale(x: progress, anchor: .leading)
            
        }
        
    }
    
}

struct SlideToConfirmTestView: View {
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                Spacer()
                
                let config: SlideConfig = .init(
                    idleText: "Swipe To Pay",
                    onSwipeText: "Confrims Payment",
                    confrimationText: "Success!",
                    tint: .green,
                    foregroundColor: .white
                )
                
                SlideToConfirmView(config: config) {
                    print("SWIPED")
                }
                
            }
            .padding(.medium)
            .navigationTitle("Slide To Confirm")
            
        }
        
    }
    
}

#Preview {
    
    SlideToConfirmTestView()
    
}
