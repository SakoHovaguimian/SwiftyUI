//
//  SliderTicker.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 5/24/25.
//

import SwiftUI

/// A slider with discrete steps, snapping ticks and an embedded knob.
public struct CustomSlider: View {
    
    @Binding public var value: Double
    public var range: ClosedRange<Double>
    public var step: Double
    public var label: () -> Text
    public var minimumValueLabel: () -> Text
    public var maximumValueLabel: () -> Text
    
    // MARK: – Styling
    let placeholderHeight: CGFloat = 6
    let knobSize: CGSize      = CGSize(width: 26, height: 26)
    let ticksSize: CGSize     = CGSize(width: 1, height: 8)
    
    let placeholderColor: Color = Color(UIColor.purple)
    let ticksColor:       Color = .pink
    let progressColor:    Color = .accentColor
    let knobColor:        Color = .white
    
    /// Number of discrete positions (including both ends).
    private var maxTicks: Int {
        let totalSteps = (range.upperBound - range.lowerBound) / step
        return Int(totalSteps) + 1
    }
    
    public var body: some View {
        VStack {
            HStack {
                label()
                Spacer()
            }
            
            HStack(spacing: 8) {
                minimumValueLabel()
                
                GeometryReader { geometry in
                    let trackWidth = geometry.size.width - knobSize.width
                    
                    ZStack(alignment: .leading) {
                        // 1) empty track
                        Capsule()
                            .fill(placeholderColor)
                            .frame(height: placeholderHeight)
                        
                        // 2) filled portion
                        Capsule()
                            .fill(progressColor)
                            .frame(width: CGFloat(normalizedValue) * trackWidth,
                                   height: placeholderHeight)
                        
                        // 3) optional tick marks (dots)
                        HStackTicks(length: 16, candidates: [], maxTicks: self.maxTicks)
                            .fill(ticksColor)
                            .frame(width: trackWidth, height: ticksSize.height)
                            .offset(x: knobSize.width / 2,
                                    y: (knobSize.height - ticksSize.height) / 2)
                        
                        // 4) draggable knob
                        HStack {
                            Circle()
                                .fill(knobColor)
                                .frame(width: knobSize.width, height: knobSize.height)
                                .shadow(color: .gray.opacity(0.4),
                                        radius: 3, x: 2, y: 2)
                                .offset(x: knobOffset(width: trackWidth))
                                .gesture(
                                    DragGesture()
                                        .onChanged { g in
                                            updateValue(from: g.location.x,
                                                        in: geometry)
                                        }
                                )
                            Spacer()
                        }
                    }
                    .frame(height: knobSize.height)
                }
                
                maximumValueLabel()
            }
            .frame(height: knobSize.height + 16)
        }
        .animation(.smooth(duration: 0.2), value: self.value)
    }
    
    /// 0…1 representation of current value
    private var normalizedValue: Double {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
    
    private func knobOffset(width: CGFloat) -> CGFloat {
        let steps    = (range.upperBound - range.lowerBound) / step
        let tickW    = width / CGFloat(steps)
        let current  = (value - range.lowerBound) / step
        return tickW * CGFloat(current)
    }
    
    private func updateValue(from x: CGFloat, in geo: GeometryProxy) {
        let steps    = (range.upperBound - range.lowerBound) / step
        let trackW   = geo.size.width - knobSize.width
        let tickW    = trackW / CGFloat(steps)
        let clamped = max(0, min(x - knobSize.width/2, trackW))
        let stepped  = Double(round(clamped / tickW)) * step
        value = max(range.lowerBound,
                    min(range.lowerBound + stepped,
                        range.upperBound))
    }
}


/// Vertical line ticks across a normalized HStack.
public struct HStackTicks: Shape {
    public var length:   CGFloat = 8
    public var candidates: Set<Int> = []
    public var maxTicks: Int = 6
    
    public func path(in rect: CGRect) -> Path {
        var p = Path()
        let count = max(maxTicks, 1)
        let spacing = (rect.width - 2) / CGFloat(count - 1)
        
        for i in 0..<count {
            guard candidates.isEmpty || candidates.contains(i) else { continue }
            let x = spacing * CGFloat(i) + 1
            p.move(to: CGPoint(x: x, y: rect.minY))
            p.addLine(to: CGPoint(x: x, y: rect.minY + length))
        }
        return p
    }
}


/// Dot‐style ticks across a normalized HStack.
public struct HStackDots: Shape {
    public var diameter: CGFloat
    public var maxDots:  Int
    public var inSet:    Bool
    
    public func path(in rect: CGRect) -> Path {
        var p = Path()
        let count = max(maxDots, 1)
        guard inSet else { return p }
        
        // compute center‐to‐center spacing
        let spacing = (rect.width - diameter) / CGFloat(count - 1)
        for i in 0..<count {
            let cx = spacing * CGFloat(i) + diameter/2
            let cy = rect.midY
            let r = CGRect(x: cx - diameter/2,
                           y: cy - diameter/2,
                           width: diameter,
                           height: diameter)
            p.addEllipse(in: r)
        }
        return p
    }
}


#Preview {
    struct ContentView: View {
        @State private var sliderValue: Double = 1.0
        
        var body: some View {
            VStack(spacing: 24) {
                Text("Custom Slider with snapping tick marks")
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                CustomSlider(
                    value: $sliderValue,
                    range: 1...5,
                    step: 1,
                    label: { Text("Text size \(sliderValue.formatted(.number))") },
                    minimumValueLabel: { Text("A").font(.body.smallCaps()).bold() },
                    maximumValueLabel: { Text("A").font(.body).bold() }
                )
                .accentColor(.orange)
                
                Spacer()
                Text("bento.me/codelaby")
                    .foregroundStyle(.blue)
            }
            .padding()
        }
    }
    
    return ContentView()
    //.environment(\.layoutDirection, .rightToLeft)
}
