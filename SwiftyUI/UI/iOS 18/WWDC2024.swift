//
//  WWDC2024.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/14/24.
//

import SwiftUI

struct WWDC2024_ScrollViewPagination: View {
    
    @State private var colors: [Color] = [
        .darkRed,
        .darkBlue,
        .darkPurple,
        .darkYellow,
        .darkGreen
    ]
    
    var body: some View {
        
        ScrollView(.horizontal) {
            
            LazyHStack(spacing: 22) {
                
                ForEach(colors, id: \.self) { color in
                    
                    Rectangle()
                        .fill(color)
                        .containerRelativeFrame(.horizontal)
                        .scrollTransition(
                            axis: .horizontal
                        ) { content, phase in
                            content
                                .rotationEffect(.degrees(phase.value * 2.5))
                                .offset(y: phase.isIdentity ? 0 : 8)
                        }
                    
                }
                
            }
            .scrollTargetLayout()
            
        }
        .contentMargins(.horizontal, 44)
        .scrollTargetBehavior(.paging)
        
    }
    
}

struct WWDC2024_ScrollViewParallax: View {
    
    @State private var images: [String] = [
        "image_1",
        "image_2",
        "image_3",
        "image_4"
    ]
    
    var body: some View {
        
        ScrollView(.horizontal) {
            
            LazyHStack(spacing: 16) {
                
                ForEach(images, id: \.self) { image in
                    
                    VStack(spacing: 8) {
                        
                        ZStack {
                            
                            Image(image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            /// Aspect preventing height from occuring due to container relevant frame
                                .scrollTransition(
                                    axis: .horizontal
                                ) { content, phase in
                                    return content
                                        .offset(x: phase.value * -250)
                                }
                            
                        }
                        .containerRelativeFrame(.horizontal)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        
                    }
                    
                }
                
            }
            .scrollTargetLayout()
            
        }
        .contentMargins(.horizontal, 32)
        .scrollTargetBehavior(.paging)
        
    }
    
}

struct WWDC2024_HueRotation: View {
    
    @State private var colors: [Color] = [
        .darkRed,
        .darkBlue,
        .darkPurple,
        .darkYellow,
        .darkGreen
    ]
    
    var body: some View {
        
        ScrollView {
            
            RoundedRectangle(cornerRadius: 24)
                .fill(.purple)
                .frame(height: 10000)
                .visualEffect({ content, proxy in
                    content
                        .hueRotation(Angle(degrees: proxy.frame(in: .global).origin.y / 10))
                    
                })
            
        }
        .ignoresSafeArea()
        .overlay {
            
            Text("Scroll For Hue Rotation")
                .font(.title)
                .fontWeight(.black)
                .fontDesign(.rounded)
            
        }
        
    }
    
}

// Custom Transition

struct Twirl: Transition {
    
    func body(content: Content,
              phase: TransitionPhase) -> some View {
        
        content
            .scaleEffect(phase.isIdentity ? 1 : 0.5)
            .opacity(phase.isIdentity ? 1 : 0)
            .blur(radius: phase.isIdentity ? 0 : 10)
            .rotationEffect(
                .degrees(
                    phase == .willAppear ? 360 :
                        phase == .didDisappear ? -360 : .zero
                )
            )
            .brightness(phase == .willAppear ? 1 : 0)
    }
}

struct WWDC2024_Transition: View {
    
    @State private var shouldShowOtherView: Bool = false
    
    var body: some View {
        
        ZStack {
            
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack {
                
                if self.shouldShowOtherView {
                    
                    Rectangle()
                        .fill(.darkBlue)
                        .transition(Ripple())
                    
                } else {
                    
                    Rectangle()
                        .fill(.blue)
                        .transition(Ripple())
                    
                }
                
            }
            .ignoresSafeArea()
            .onTapGesture {
                
                withAnimation(.smooth(duration: 2)) {
                    self.shouldShowOtherView.toggle()
                }
                
            }
            .overlay {
                
                Text("Tap To Twirl")
                    .foregroundStyle(.white)
                    .font(.title)
                    .fontWeight(.black)
                    .fontDesign(.rounded)
                    .allowsHitTesting(false)
                
            }
            
        }
        
    }
    
}

#Preview {
    WWDC2024_ScrollViewPagination()
}

#Preview {
    WWDC2024_ScrollViewParallax()
}

#Preview {
    WWDC2024_HueRotation()
}

#Preview {
    WWDC2024_Transition()
}

struct Flip: Transition {
    
    func body(content: Content,
              phase: TransitionPhase) -> some View {
        
        content
            .rotation3DEffect(
                .degrees(phase.isIdentity ? 0 : 180 * phase.value),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(phase.isIdentity ? 1 : 0)
    }
}

struct Ripple: Transition {
    
    func body(content: Content,
              phase: TransitionPhase) -> some View {
        
        content
            .scaleEffect(phase.isIdentity ? 1 : 0.8)
            .opacity(phase.isIdentity ? 1 : 0.5 + 0.5 * phase.value)
    }
}

struct SpinAndZoom: Transition {
    
    func body(content: Content,
              phase: TransitionPhase) -> some View {
        
        content
            .scaleEffect(phase.isIdentity ? 1 : 0.2)
            .rotationEffect(.degrees(phase.isIdentity ? 0 : 720 * phase.value))
            .opacity(phase.isIdentity ? 1 : 0)
    }
}

struct SlideAndScale: Transition {
    
    func body(content: Content,
              phase: TransitionPhase) -> some View {
        
        content
            .offset(y: phase.isIdentity ? 0 : UIScreen.main.bounds.height * phase.value)
            .scaleEffect(phase.isIdentity ? 1 : 0.5)
            .opacity(phase.isIdentity ? 1 : 0)
    }
}

struct Pop: Transition {
    
    func body(content: Content,
              phase: TransitionPhase) -> some View {
        
        content
            .scaleEffect(phase.isIdentity ? 1 : 1.3)
            .opacity(phase.isIdentity ? 1 : 0)
    }
}

struct ExpandAndFade: Transition {
    
    func body(content: Content,
              phase: TransitionPhase) -> some View {
        
        content
            .scaleEffect(phase.isIdentity ? 1 : 0.5)
            .opacity(phase.isIdentity ? 1 : 0)
    }
}
