//
//  SpinWheel.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/23/25.
//

import SwiftUI

struct Segment: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
}

struct SpinWheel: View {
    
    @State private var rotation: Double = 0
    @State private var isSpinning: Bool = false
    @State private var winningIndex: Int = 0
    
    // 1. Define Segments with different sizes (values)
    // Note: The math will normalize these to percentages automatically.
    private let segments: [Segment] = [
        Segment(name: "Steve (50%)", value: 50, color: .brandPink),
        Segment(name: "John (10%)", value: 10, color: .brandGreen),
        Segment(name: "Bill (10%)", value: 10, color: .mint),
        Segment(name: "Dave (10%)", value: 10, color: .indigo),
        Segment(name: "Alan (20%)", value: 20, color: .teal),
    ]
    
    var body: some View {
        
        VStack(spacing: 40) {
            
            ZStack(alignment: .top) {
                
                // Wheel
                Wheel(segments: segments)
                    .frame(width: 300, height: 300)
                    .rotationEffect(.radians(rotation))
                    .onTapGesture { spin() }
                
                // Pointer (Carrot)
                // 2. Dynamic Color & Shadow
                Image(systemName: "triangle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(segments[winningIndex].color) // Matches winner
                    .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 2)
                    .rotationEffect(.degrees(180))
                    .offset(y: -15) // Peak down from the very top edge
                    .zIndex(1)
                
            }
            
            Text("Winner: \(segments[winningIndex].name)")
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }
    
    private func spin() {
        guard !isSpinning else { return }
        isSpinning = true
        
        let randomAdditional = Double.random(in: 0...(2 * .pi))
        let spinCount = Double.random(in: 20...32)
        let totalSpinAmount = (spinCount * (2 * .pi)) + randomAdditional
        let newRotation = self.rotation + totalSpinAmount
        
        let frictionCurve = Animation.timingCurve(0.1, 0.7, 0.1, 1.0, duration: .random(in: 2...10))
        
        withAnimation(frictionCurve) {
            self.rotation = newRotation
        } completion: {
            self.isSpinning = false
            determineWinner()
        }
    }
    
    private func determineWinner() {
        
        let pointerAngle = -Double.pi / 2 // 12 o'clock
        
        // Calculate relative angle 0...2pi
        var relativeAngle = pointerAngle - rotation
        relativeAngle = relativeAngle.truncatingRemainder(dividingBy: 2 * .pi)
        if relativeAngle < 0 { relativeAngle += 2 * .pi }
        
        // Iterate through segments to find which range contains this angle
        let totalValue = segments.reduce(0) { $0 + $1.value }
        var currentAngle: Double = 0
        
        for (index, segment) in segments.enumerated() {
            let sliceSize = (segment.value / totalValue) * (2 * .pi)
            let endAngle = currentAngle + sliceSize
            
            // Check if our angle falls within this slice
            if relativeAngle >= currentAngle && relativeAngle < endAngle {
                self.winningIndex = index
                break
            }
            
            currentAngle += sliceSize
        }
    }
}

struct Wheel: View {
    
    let segments: [Segment]
    
    // Computed props to handle variable sizes
    private var totalValue: Double {
        segments.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        GeometryReader { proxy in
            let radius = proxy.size.width / 2
            
            ZStack {
                ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
                    
                    let data = calculateSegmentData(index: index)
                    
                    ZStack {
                        // 3. Fixed Bounds Logic
                        // To make a solid pie slice using Stroke, we:
                        // - Inset by half the radius (putting the path in the middle of the solid area)
                        // - Stroke by the full radius (filling outward to edge and inward to center)
                        Circle()
                            .inset(by: radius / 2) // Crucial: This keeps it inside bounds
                            .trim(from: data.startPct, to: data.endPct)
                            .stroke(segment.color, style: StrokeStyle(lineWidth: radius))
                            
                        
                        // Label Math
                        // We rotate to the 'midAngle' of this specific slice
                        Text(segment.name)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .offset(x: radius * 0.7) // Push text towards outer rim
                            .rotationEffect(.radians(data.midAngle))
                    }
                }
            }
        }
    }
    
    // Helper to calculate start/end/mid angles for variable slices
    private func calculateSegmentData(index: Int) -> (startPct: CGFloat, endPct: CGFloat, midAngle: Double) {
        
        // Sum values up to this index
        var precedingValue: Double = 0
        for i in 0..<index {
            precedingValue += segments[i].value
        }
        
        // Calculate percentages
        let startPct = precedingValue / totalValue
        let endPct = (precedingValue + segments[index].value) / totalValue
        
        // Calculate Mid Angle (in Radians) for rotation
        // 2pi * (start + half of width)
        let midPct = startPct + ((endPct - startPct) / 2)
        let midAngle = midPct * (2 * .pi)
        
        return (CGFloat(startPct), CGFloat(endPct), midAngle)
    }
}

#Preview {
    SpinWheel()
}
