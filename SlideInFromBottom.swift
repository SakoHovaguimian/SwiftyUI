//
//  SlideInFromBottom.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/6/26.
//

import SwiftUI

// MARK: - Blur / Slide In Modifier

struct SlideInFromBottom: ViewModifier {
    
    var isVisible: Bool
    var delay: Double = 0
    
    func body(content: Content) -> some View {
        
        content
            .opacity(isVisible ? 1 : 0)
            .blur(radius: isVisible ? 0 : 10)
            .offset(y: isVisible ? 0 : 50)
            .animation(
                .easeOut(duration: 0.5).delay(delay),
                value: isVisible
            )
        
    }
    
}

extension View {
    
    func blurFromBottom(
        _ isVisible: Bool,
        delay: Double = 0
    ) -> some View {
        
        modifier(SlideInFromBottom(isVisible: isVisible, delay: delay))
        
    }
    
}

// MARK: - Inline Flow Layout

import SwiftUI

struct InlineFlow: Layout {
    
    var horizontalSpacing: CGFloat = 6
    var verticalSpacing: CGFloat = 0
    var rowHeight: CGFloat = 30
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        
        let maxWidth = proposal.width ?? fallbackWidth(for: subviews)
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        for v in subviews {
            
            let s = v.sizeThatFits(.unspecified)
            
            if x > 0, x + s.width > maxWidth {
                
                x = 0
                y += rowHeight + verticalSpacing
                
            }
            
            x += s.width + horizontalSpacing
            
        }
        
        return CGSize(width: maxWidth, height: y + rowHeight)
        
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        
        let maxX = bounds.maxX
        
        var x = bounds.minX
        var y = bounds.minY
        
        for v in subviews {
            
            let s = v.sizeThatFits(.unspecified)
            
            if x > bounds.minX, x + s.width > maxX {
                
                x = bounds.minX
                y += rowHeight + verticalSpacing
                
            }
            
            v.place(
                at: CGPoint(
                    x: x,
                    y: y + (rowHeight - s.height) / 2
                ),
                proposal: ProposedViewSize(s)
            )
            
            x += s.width + horizontalSpacing
            
        }
        
    }
    
    private func fallbackWidth(for subviews: Subviews) -> CGFloat {
        
        // If no width is proposed (rare), pick a deterministic fallback.
        // This keeps previews sane and avoids `.infinity` math.
        subviews
            .map { $0.sizeThatFits(.unspecified).width }
            .max() ?? 0
        
    }
    
}

// MARK: - Demo View

struct InlineViewPreviewDemo: View {
    
    @State private var show = false
    
    var body: some View {
        
        VStack {
            
            InlineFlow(horizontalSpacing: 4, verticalSpacing: 4) {
                
                Text("Your active energy today is at") // line 1
                    .blurFromBottom(show, delay: 0.4)
                
                ProgressBadgeView(value: 199, maxValue: 500, title: "kCal", color: .red) // line 2
                    .blurFromBottom(show, delay: 0.5)
                
                Text(", and you have")
                    .blurFromBottom(show, delay: 0.6)
                
                Text("exercised for") // line 3
                    .blurFromBottom(show, delay: 0.7)
                
                ProgressBadgeView(value: 40, maxValue: 100, title: "min", color: .mint) // line 3
                    .blurFromBottom(show, delay: 0.8)
                
                Text("Your")
                    .blurFromBottom(show, delay: 0.9)
                
                Text("recovery score is") // line 4
                    .blurFromBottom(show, delay: 1.0)
                
                ProgressBadgeView(value: 66, maxValue: 100, title: "", color: .orange) // line 4
                    .blurFromBottom(show, delay: 1.1)
                
                Text(". The")
                    .blurFromBottom(show, delay: 1.2)
                
                Text("current temperature is") // line 5
                    .blurFromBottom(show, delay: 1.3)
                
                CapsuleInfo(icon: "thermometer", text: "16°C", color: .blue)
                    .blurFromBottom(show, delay: 1.4)
                
                Text("with") // line 6
                    .blurFromBottom(show, delay: 1.5)
                
                CapsuleInfo(icon: "sun.max.fill", text: "Clear", color: .blue)
                    .blurFromBottom(show, delay: 1.6)
                
                Text(".")
                    .blurFromBottom(show, delay: 1.7)
                
            }
            .font(.system(size: 19, weight: .regular, design: .rounded))
            .padding(.trailing, 90)
            .onAppear { show = true }
            
            HStack {
                
                Image(systemName: "hand.thumbsup")
                    .scaleEffect(x: -1, y: 1)
                
                Image(systemName: "hand.thumbsup")
                
                Spacer()
                
            }
            .foregroundStyle(.gray)
            .font(.title2)
            .blurFromBottom(show, delay: 1.8)
            .padding(.top)
            
        }
        
    }
    
}

// MARK: - Progress Badge

struct ProgressBadgeView: View {
    
    let value: Double
    let maxValue: Double
    let title: String
    let color: Color
    
    private var progress: Double {
        min(value / maxValue, 1)
    }
    
    var body: some View {
        
        HStack(spacing: 7) {
            ProgressRing(progress: progress, color: color)
            Text("\(Int(value)) \(title)")
        }
        .font(.system(size: 17, weight: .medium, design: .rounded))
        .padding(.horizontal, 11)
        .frame(height: 30)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
                .overlay(content: {
                    Capsule()
                        .stroke(lineWidth: 1.2)
                        .foregroundStyle(.white)
                })
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 3)
        )
        
    }
    
}

// MARK: - Progress Ring

struct ProgressRing: View {
    
    let progress: Double
    let color: Color
    
    let size: CGFloat = 15
    let lineWidth: CGFloat = 3.5
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 3)) {
                animatedProgress = progress
            }
        }
        
    }
    
}

// MARK: - Capsule Info

struct CapsuleInfo: View {
    
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        
        HStack(spacing: 3) {
            
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .foregroundStyle(color)
                .frame(width: 15, height: 17)
            
            Text(text)
            
        }
        .font(.system(size: 17, weight: .medium, design: .rounded))
        .padding(.horizontal, 11)
        .frame(height: 30)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
                .overlay(content: {
                    Capsule()
                        .stroke(lineWidth: 1.2)
                        .foregroundStyle(.white)
                })
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 11)
        )
        
    }
    
}

// MARK: - Preview

#Preview {
    InlineViewPreviewDemo()
        .padding()
}
