//
//  SlideToUnlockButton.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/16/24.
//

import SwiftUI

public struct BackgroundComponent: View {

    @State private var hueRotation = false

    public var body: some View {
        
        ZStack(alignment: .leading)  {
            
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.darkBlue.opacity(0.6),
                            Color.darkPurple.opacity(0.6)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .hueRotation(.degrees(hueRotation ? 20 : -20))

            Text("Slide to unlock")
                .font(.footnote)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
            
        }
        .onAppear {
            
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                hueRotation.toggle()
            }
            
        }
        
    }

}

public struct BaseButtonStyle: ButtonStyle {

    public func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.default, value: configuration.isPressed)
        
    }

}

import SwiftUI
import CoreHaptics

public struct DraggingComponent: View {

    @Binding private var isLocked: Bool
    @State private var isLoading: Bool
    let maxWidth: CGFloat

    @State private var width = CGFloat(50)
    private  let minWidth = CGFloat(50)

    public init(isLocked: Binding<Bool>, isLoading: Bool, maxWidth: CGFloat) {
        _isLocked = isLocked
        self.isLoading = isLoading
        self.maxWidth = maxWidth
    }

    public var body: some View {
        
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.darkBlue)
            .opacity(width / maxWidth)
            .frame(width: width)
            .overlay(alignment: isLocked ? .trailing : .center) {
                
                Button(action: {} ) {
                    ZStack {
                        
                        image(name: "lock", isShown: isLocked)
                        progressView(isShown: isLoading)
                        image(name: "lock.open", isShown: !isLocked && !isLoading)
                        
                    }
                    .animation(.easeIn(duration: 0.35).delay(0.55), value: !isLocked && !isLoading)
                    
                }
                .buttonStyle(BaseButtonStyle())
                .disabled(!isLocked || isLoading)
            }
        
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        
                        guard isLocked else { return }
                        
                        if value.translation.width > 0 {
                            width = min(max(value.translation.width + minWidth, minWidth), maxWidth)
                        }
                        
                    }
                    .onEnded { value in
                        
                        guard isLocked else { return }
                        
                        if width < maxWidth {
                            
                            width = minWidth
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                            
                        } else {
                            
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            
                            withAnimation(.spring().delay(0.5)) {
                                
                                isLocked = false
                            
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
                                    
                                    withAnimation(.spring) {
                                        
                                        isLoading = true
                                        
                                    }
                                    
                                })
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                    
                                    withAnimation(.spring) {
                                        width = 50
                                    }
                                    
                                })
                                
                            }
                            
                        }
                        
                    }
            )
            .animation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 0), value: width)

    }

    private func image(name: String, isShown: Bool) -> some View {
        
        Image(systemName: name)
            .font(.system(size: 20, weight: .regular, design: .rounded))
            .foregroundColor(Color.darkBlue)
            .frame(width: 42, height: 42)
            .background(RoundedRectangle(cornerRadius: 14).fill(.white))
            .padding(4)
            .opacity(isShown ? 1 : 0)
            .scaleEffect(isShown ? 1 : 0.01)
        
    }

    private func progressView(isShown: Bool) -> some View {
        
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.white)
            .opacity(isShown ? 1 : 0)
            .scaleEffect(isShown ? 1 : 0.01)
        
    }

}

struct UnlockButton: View {

    @State private var isLocked = true

    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .leading) {
                
                if isLocked {
                    BackgroundComponent()
                        .transition(.opacity.combined(with: .blurReplace))
                }
                
                HStack {
                    
                    if !isLocked {
                        
                        Spacer()
                            .transition(.move(edge: .leading))
                        
                    }
                    
                    DraggingComponent(
                        isLocked: $isLocked,
                        isLoading: false,
                        maxWidth: geometry.size.width
                    )
                    
                    if !isLocked {
                        
                        Spacer()
                            .transition(.move(edge: .trailing))
                        
                    }
                    
                }
                
            }
            .frame(maxWidth: isLocked ? nil : .infinity, alignment: isLocked ? .leading : .center)
            
        }
        .frame(height: 50)
        .animation(.bouncy, value: isLocked)
        .padding()
    }

}

#Preview {
    UnlockButton()
}
