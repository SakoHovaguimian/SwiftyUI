//
//  SpinWheel.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/23/25.
//

import SwiftUI

struct SpinWheel: View {
    
    @State private var rotation: CGFloat = 0
    @State private var isSpinning: Bool = false
    @State private var selectedIndex: Int = 0
    
    private let duration: Double = 5
    private let extraFullSpinsRange = 3...6
    
    private let segments = ["Steve", "John", "Bill", "Dave", "Alan"]
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            Wheel(segments: self.segments)
                .frame(width: 200, height: 200)
                .rotationEffect(.radians(rotation))
                .animation(.easeInOut(duration: 5), value: self.rotation)
                .onTapGesture {
                    spin()
                }
            
            Image(systemName: "triangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 24)
                .foregroundStyle(.red)
                .rotationEffect(.degrees(180))
            
        }
        .overlay(alignment: .bottom) {
            
            Text("Selected: \(self.segments[self.selectedIndex])")
                .font(.headline)
                .padding(.top, 12)
                .offset(y: 40)
            
        }
        
    }
    
    private func spin() {

        guard !self.isSpinning else { return }
        self.isSpinning = true

        let winnerIndex = Int.random(in: 0..<self.segments.count)

        let extraSpins = CGFloat(Int.random(in: self.extraFullSpinsRange)) * (2 * .pi)

        let currentNorm = normalized(self.rotation)
        let baseTarget = baseRotationForSliceCenterAtTop(index: winnerIndex)
        let deltaForward = normalized(baseTarget - currentNorm) // always forward (0...2π)

        let target = self.rotation + extraSpins + deltaForward

        withAnimation(.easeInOut(duration: self.duration), completionCriteria: .logicallyComplete) {
            self.rotation = target
        } completion: {
            self.isSpinning = false
            self.selectedIndex = self.selectedIndexForRotation(self.rotation)
        }
        
    }
    
    private func finishSpin() {

        self.isSpinning = false
        self.selectedIndex = self.selectedIndexForRotation(self.rotation)

    }

    private var segmentAngle: CGFloat {
        (2 * .pi) / CGFloat(self.segments.count)
    }

    private var sliceShift: CGFloat {
        self.segmentAngle / 2 // matches: .rotationEffect(.radians(.pi * segmentSize))
    }

    private func normalized(_ angle: CGFloat) -> CGFloat {
        var a = angle.truncatingRemainder(dividingBy: 2 * .pi)
        if a < 0 { a += 2 * .pi }
        return a
    }

    /// Which segment is currently under the 12 o’clock pointer
    private func selectedIndexForRotation(_ rotation: CGFloat) -> Int {

        let pointerAngle: CGFloat = .pi / 2 // 12 o’clock, because 0 is 3 o’clock
        let local = normalized(pointerAngle - rotation)       // undo wheel rotation
        let adjusted = normalized(local - self.sliceShift)    // undo your slice shift

        let index = Int(floor(adjusted / self.segmentAngle))
        return (self.segments.count - 1 - index)
    }

    /// Rotation (from “zero”) that puts the CENTER of `index` at 12 o’clock
    private func baseRotationForSliceCenterAtTop(index: Int) -> CGFloat {

        let pointerAngle: CGFloat = .pi / 2
        let centerAngle = self.segmentAngle * CGFloat(index + 1) // matches your label math
        return normalized(pointerAngle - centerAngle)
    }

    private func rotationForSliceCenter(index: Int) -> CGFloat {

        let pointerAngle: CGFloat = -.pi / 2
        let sliceVisualShift: CGFloat = self.segmentAngle / 2

        // Center of slice `index` in “slice space”
        let sliceCenterAngle = (CGFloat(index) + 0.5) * self.segmentAngle

        // Invert the selection math to find the rotation that puts that center under the pointer.
        return pointerAngle + sliceVisualShift - sliceCenterAngle

    }
    
}

struct Wheel: View {

    let segments: [String]

    var body: some View {

        GeometryReader { proxy in

            ZStack(alignment: .top) {

                ForEach(self.segments.indices, id: \.self) { index in

                    ZStack {

                        Circle()
                            .inset(by: proxy.size.width / 4)
                            .trim(from: CGFloat(index) * self.segmentSize,
                                  to: CGFloat(index + 1) * self.segmentSize)
                            .stroke(Color.all[index], style: StrokeStyle(lineWidth: proxy.size.width / 2))
                            // This is the “visual shift” accounted for in selection math above.
                            .rotationEffect(.radians(.pi * self.segmentSize))
                            .opacity(0.3)

                        self.label(
                            text: self.segments[index],
                            index: CGFloat(index),
                            offset: proxy.size.width / 4
                        )

                    }

                }

            }

        }

    }

    private var segmentSize: CGFloat {
        1 / CGFloat(self.segments.count)
    }

    private func rotation(index: CGFloat) -> CGFloat {
        (.pi * (2 * self.segmentSize * (CGFloat(index + 1))))
    }

    private func label(text: String,
                       index: CGFloat,
                       offset: CGFloat) -> some View {

        Text(text)
            .rotationEffect(.radians(self.rotation(index: CGFloat(index))))
            .offset(x: cos(self.rotation(index: index)) * offset,
                    y: sin(self.rotation(index: index)) * offset)

    }

}

extension Color {
    
    static var all: [Color] {
        [Color.yellow, .green, .pink, .cyan, .mint, .orange, .teal, .indigo]
    }
    
}

#Preview {
    SpinWheel()
}
