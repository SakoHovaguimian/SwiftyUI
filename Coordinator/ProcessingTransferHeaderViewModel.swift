//
//  ProcessingTransferHeaderViewModel.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/20/26.
//

import SwiftUI
import Combine

struct ProcessingTransferHeaderView: View {
    
    @State var style: AnimatedTransferBars.AnimationStyle = .gradientFlow

    var body: some View {
        
        VStack(spacing: 12) {
            
            // Top row (two labels)
            HStack(alignment: .firstTextBaseline) {
                
                Text("Credit Card Transfer")
                    .font(.title)
                    .foregroundStyle(.black)

                Spacer()

                Text(19999, format: .currency(code: "USD"))
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                
            }

            // Animated gradient “bar” view
            AnimatedTransferBars(style: self.style)
                .frame(height: 34)
            
        }
        
    }
    
}

struct AnimatedTransferBars: View {
    
    enum AnimationStyle {
        case gradientFlow
        case barPulse
    }
    
    // You can swap these for your own values or generate them
    private let heights: [CGFloat] = [
        0.95, 0.65
    ]
    private let barWidth: CGFloat = 3
    private let spacing: CGFloat = 4
    let style: AnimationStyle

    @State private var phase: CGFloat = -1.0
    @State private var started = false
    // for barPulse
    @State private var pulseOn = false

    var body: some View {
        
        GeometryReader { geo in
            
            let safePattern = heights.isEmpty ? [0.6] : heights
            let count = barsThatFit(width: geo.size.width, barWidth: barWidth, spacing: spacing)
            let repeated = repeatedHeights(pattern: safePattern, count: count)
            let maxH = geo.size.height

            switch style {
                
            case .gradientFlow:
                gradientFlow(count: count, repeated: repeated, maxH: maxH)

            case .barPulse:
                barPulse(count: count, repeated: repeated, maxH: maxH)
                
            }
        }
        .onAppear { startIfNeeded() }
        .onChange(of: style) {
            startIfNeeded(reset: true)
        }
        
    }
    
    // MARK: - Styles

    private func gradientFlow(count: Int, repeated: [CGFloat], maxH: CGFloat) -> some View {
        
        let movingGradient = LinearGradient(
            gradient: SwiftUI.Gradient(stops: [
                .init(color: Color(hex: "#00D91E"), location: 0.00),
                .init(color: Color(hex: "#00B4FF"), location: 0.50),
                .init(color: Color(hex: "#00D91E"), location: 1.00),
            ]),
            startPoint: UnitPoint(x: phase, y: 0.5),
            endPoint: UnitPoint(x: phase + 1.0, y: 0.5)
        )

        return Rectangle()
            .fill(movingGradient)
            .opacity(0.65)
            .mask(
                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(0..<count, id: \.self) { i in
                        Capsule(style: .continuous)
                            .frame(
                                width: barWidth,
                                height: max(4, maxH * clamp01(repeated[i]))
                            )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            )
        
    }
    
    private func barPulse(count: Int, repeated: [CGFloat], maxH: CGFloat) -> some View {
        
        // Gradient is static across the whole width (still looks nice)
        let staticGradient = LinearGradient(
            gradient: SwiftUI.Gradient(stops: [
                .init(color: Color(hex: "#00D91E"), location: 0.00),
                .init(color: Color(hex: "#00B4FF"), location: 1.00)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )

        let base: CGFloat = 0.45 // how low bars shrink to

        return Rectangle()
            .fill(staticGradient)
            .opacity(0.65)
            .mask(
                
                HStack(alignment: .bottom, spacing: spacing) {
                    
                    ForEach(0..<count, id: \.self) { i in
                        let target = clamp01(repeated[i])
                        let current = pulseOn ? target : base

                        Capsule(style: .continuous)
                            .frame(width: barWidth, height: max(4, maxH * current))
                            // stagger so they don't all pump at once
                            .animation(
                                .easeInOut(duration: 0.9)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.02),
                                value: pulseOn
                            )
                        
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                
            )
        
    }
    
    // MARK: - Start / Helpers

    private func startIfNeeded(reset: Bool = false) {
        
        if reset {
            started = false
            phase = 0
            pulseOn = false
        }

        guard !started else { return }
        started = true

        switch style {
        case .gradientFlow:
            withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                phase = 1
            }
        case .barPulse:
            // trigger the forever animations
            pulseOn = true
        }
        
    }
    
    private func barsThatFit(width: CGFloat, barWidth: CGFloat, spacing: CGFloat) -> Int {
        
        guard width > 0 else { return 0 }
        // count * barWidth + (count - 1) * spacing <= width
        // => count <= (width + spacing) / (barWidth + spacing)
        let raw = Int(floor((width + spacing) / (barWidth + spacing)))
        return max(1, raw)
        
    }

    private func repeatedHeights(pattern: [CGFloat], count: Int) -> [CGFloat] {
        
        guard count > 0 else { return [] }
        return (0..<count).map { pattern[$0 % pattern.count] }
        
    }

    private func clamp01(_ v: CGFloat) -> CGFloat { min(max(v, 0), 1) }
    
}

// Preview
#Preview {
    AppCardView {
        ProcessingTransferHeaderView()
    }
    .padding()
}
