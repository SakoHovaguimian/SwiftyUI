//
//  SexyTransition.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/21/25.
//

import SwiftUI

extension AnyTransition {
    
    static func ripple(location: CGPoint) -> AnyTransition {
        
        .asymmetric(
            insertion: .modifier(
                active: RippleModifier(location: location, isIdentity: false),
                identity: RippleModifier(location: location, isIdentity: true)
            ),
            removal: .modifier(
                // Setting this to one removes the view completely
                active: IdentityDelayTransition(opacity: 0.99),
                identity: IdentityDelayTransition(opacity: 1)
            )
        )
        
    }
    
    static func reverseRipple(location: CGPoint) -> AnyTransition {
     
        .modifier(
            active: RippleModifier(location: location, isIdentity: false),
            identity: RippleModifier(location: location, isIdentity: true)
        )
        
    }
    
}

struct SexyTransition: View {
    
    @State private var count: Int = 0
    @State private var rippleLocation: CGPoint = .zero
    @State private var showOverlayView: Bool = false
    @State private var overlayRippleLocation: CGPoint = .zero
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                GeometryReader {
                    
                    let size = $0.size
                    
                    ForEach(0...1, id: \.self) { index in
                        
                        if self.count == index {
                            
                            customImageView(
                                index: index,
                                size: size
                            )
                            .transition(.ripple(location: self.rippleLocation))
                            
                        }
                        
                    }
                    
                }
                .frame(
                    width: 350,
                    height: 500
                )
                .coordinateSpace(.named("VIEW"))
                .onTapGesture(count: 1, coordinateSpace: .named("VIEW")) { location in
                    handleTapAction(location: location)
                }
                
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .overlay(alignment: .bottomTrailing) {
                bottomButton()
            }
            .navigationTitle("Ripple Transition")
            
        }
        .overlay {
            
            if self.showOverlayView {
                
                ZStack {
                    
                    Rectangle()
                        .fill(.indigo)
                        .ignoresSafeArea()
                        .appOnTapGesture {
                            
                            withAnimation(.easeIn(duration: 0.55)) {
                                self.showOverlayView = false
                            }
                            
                        }
                    
                    Text("Tap Anywhere to Animate")
                        .appFont(with: .header(.h6))
                    
                }
                .transition(.reverseRipple(location: self.overlayRippleLocation))
                
            }
            
        }
        
    }
    
    private func handleTapAction(location: CGPoint) {
        
        self.rippleLocation = location
        
        withAnimation(.linear(duration: 1.0)) {
         
            self.count = (self.count + 1) % 2
            
        }
        
    }
    
    private func customImageView(index: Int,
                                 size: CGSize) -> some View {
        
        let image: ImageResource = index == 1
            ? .image3
            : .image4
        
        return Image(image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(
                width: size.width,
                height: size.height
            )
            .clipShape(.rect(cornerRadius: .appLarge))
        
    }
    
    private func bottomButton() -> some View {
        
        GeometryReader {
            
            let frame = $0.frame(in: .global)
            
            CircularIconView(
                foregroundColor: .white,
                backgroundColor: .blue,
                size: 50,
                systemImage: "pencil"
            )
            .asButton {
                
                self.overlayRippleLocation = .init(
                    x: frame.midX,
                    y: frame.midY
                )
                
                withAnimation(.linear(duration: 1.0)) {
                    self.showOverlayView = true
                }
                
            }

            
        }
        .frame(
            maxWidth: 50,
            maxHeight: 50
        )
        .padding(.large)
        
    }
    
}

// MARK: - RIPPLE VIEW -

fileprivate struct RippleModifier: ViewModifier {
    
    var location: CGPoint
    var isIdentity: Bool = false
    
    func body(content: Content) -> some View {
        
        content
            .mask(alignment: .topLeading) {
                
                maskShape()
                    .ignoresSafeArea()
                
            }
        
    }
    
    func maskShape() -> some View {
        
        GeometryReader {
            
            let size = $0.size
            let progress: CGFloat = isIdentity ? 1 : 0
            
            let circleSize: CGFloat = 50
            let circleRadius: CGFloat = circleSize / 2
            
            let widthDiff = size.width / circleRadius
            let heightdiff = size.height / circleRadius
            let fillCircleScale: CGFloat = max(widthDiff, heightdiff) + 4
            let defaultScale: CGFloat = isIdentity ? 1 : 0
            let scaleProgress: CGFloat = defaultScale + (fillCircleScale * progress)
            
            ZStack {
                
                Circle()
                    .frame(
                        width: circleSize,
                        height: circleSize
                    )
                
                Circle()
                    .frame(
                        width: circleSize + 10,
                        height: circleSize + 10
                    )
                    .blur(radius: 3)
                
                Circle()
                    .frame(
                        width: circleSize + 20,
                        height: circleSize + 20
                    )
                    .blur(radius: 7)
                
                Circle()
                    .opacity(0.5)
                    .frame(
                        width: circleSize + 30,
                        height: circleSize + 30
                    )
                    .blur(radius: 7)
                
            }
            .frame(
                width: circleSize,
                height: circleSize
            )
            .compositingGroup()
            .scaleEffect(
                scaleProgress,
                anchor: .center
            )
            .offset(
                x: location.x - circleRadius,
                y: location.y - circleRadius
            )
            
        }
        
    }
    
}

fileprivate struct IdentityDelayTransition: ViewModifier {
    
    var opacity: CGFloat
    
    func body(content: Content) -> some View {
        
        content
            .opacity(self.opacity)
        
    }
    
}

struct RippleView: View {
 
    var body: some View {
        
        RoundedRectangle(cornerRadius: .appLarge)
            .fill(.blue.gradient)
            
        
    }
    
}

#Preview {
    
    SexyTransition()
    
}
