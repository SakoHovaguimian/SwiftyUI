//
//  SpinWheel.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/23/25.
//

//import SwiftUI
//import AudioToolbox
//
//struct Segment: Identifiable, Equatable {
//    let id = UUID()
//    let name: String
//    let value: Double
//    let color: Color
//}
//
//struct SpinWheel: View {
//    
//    @State private var rotation: Double = 0
//    @State private var isSpinning: Bool = false
//    @State private var winningIndex: Int = 0
//    
//    private let segments: [Segment] = [
//        Segment(name: "Steve (20%)", value: 20, color: .brandPink),
//        Segment(name: "John (40%)", value: 40, color: .brandGreen),
//        Segment(name: "Bill (10%)", value: 10, color: .mint),
//        Segment(name: "Dave (10%)", value: 10, color: .indigo),
//        Segment(name: "Alan (20%)", value: 20, color: .teal),
//    ]
//    
//    var body: some View {
//        
//        VStack(spacing: 40) {
//            
//            ZStack(alignment: .top) {
//                
//                // Wheel
//                Wheel(segments: segments)
//                    .frame(width: 300, height: 300)
//                    .rotationEffect(.radians(rotation))
//                    .onTapGesture { spin() }
//                
//                // Pointer (Carrot)
//                // Using a custom Animatable View so it updates color
//                // frame-by-frame, but STAYS STATIONARY.
//                PointerView(
//                    rotation: rotation,
//                    segments: segments
//                )
//                .frame(width: 30, height: 30)
//                .offset(y: -15) // Peak down from the very top edge
//                .zIndex(1)
//                
//            }
//            
//            // Only show the finalized winner text when we aren't spinning
//            Text(isSpinning ? "Spinning..." : "Winner: \(segments[winningIndex].name)")
//                .font(.headline)
//                .foregroundStyle(.primary)
//                .animation(nil, value: isSpinning)
//        }
//    }
//    
//    private func spin() {
//           guard !isSpinning else { return }
//           isSpinning = true
//           
//           let randomAdditional = Double.random(in: 0...(2 * .pi))
//           let spinCount = Double.random(in: 20...32)
//           let totalSpinAmount = (spinCount * (2 * .pi)) + randomAdditional
//           let newRotation = self.rotation + totalSpinAmount
//           
//           let frictionCurve = Animation.timingCurve(0.1, 0.7, 0.1, 1.0, duration: .random(in: 2...10))
//           
//           withAnimation(frictionCurve) {
//               self.rotation = newRotation
//           } completion: {
//               self.isSpinning = false
//               determineWinner()
//           }
//       }
//    
//    private func determineWinner() {
//           
//           let pointerAngle = -Double.pi / 2 // 12 o'clock
//           
//           // Calculate relative angle 0...2pi
//           var relativeAngle = pointerAngle - rotation
//           relativeAngle = relativeAngle.truncatingRemainder(dividingBy: 2 * .pi)
//           if relativeAngle < 0 { relativeAngle += 2 * .pi }
//           
//           // Iterate through segments to find which range contains this angle
//           let totalValue = segments.reduce(0) { $0 + $1.value }
//           var currentAngle: Double = 0
//           
//           for (index, segment) in segments.enumerated() {
//               let sliceSize = (segment.value / totalValue) * (2 * .pi)
//               let endAngle = currentAngle + sliceSize
//               
//               // Check if our angle falls within this slice
//               if relativeAngle >= currentAngle && relativeAngle < endAngle {
//                   self.winningIndex = index
//                   break
//               }
//               
//               currentAngle += sliceSize
//           }
//       }
//}
//
//// MARK: - Smart Pointer (Animatable, Fixed Position)
//struct PointerView: View, Animatable {
//    
//    var rotation: Double
//    var segments: [Segment]
//    
//    // Generator for the "Picker" click sound/haptic
//    private let feedback = UISelectionFeedbackGenerator()
//    
//    // This allows SwiftUI to interpolate the rotation value frame-by-frame
//    // so we can calculate the color, even though the view itself doesn't rotate.
//    var animatableData: Double {
//        get { rotation }
//        set { rotation = newValue }
//    }
//    
//    // Helper to find the current active segment based on rotation
//    private var currentSegment: Segment {
//        let pointerAngle = -Double.pi / 2
//        var relativeAngle = pointerAngle - rotation
//        relativeAngle = relativeAngle.truncatingRemainder(dividingBy: 2 * .pi)
//        if relativeAngle < 0 { relativeAngle += 2 * .pi }
//        
//        let totalValue = segments.reduce(0) { $0 + $1.value }
//        var currentAngle: Double = 0
//        
//        for segment in segments {
//            let sliceSize = (segment.value / totalValue) * (2 * .pi)
//            let endAngle = currentAngle + sliceSize
//            
//            if relativeAngle >= currentAngle && relativeAngle < endAngle {
//                return segment
//            }
//            currentAngle += sliceSize
//        }
//        return segments.first!
//    }
//    
//    var body: some View {
//        
//        // Capture the computed segment for this frame
//        let segmentForFrame = currentSegment
//        
//        Image(systemName: "triangle.fill")
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .foregroundColor(segmentForFrame.color) // <--- Updates real-time
//            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: -5)
//            .rotationEffect(.degrees(180)) // <--- Fixed rotation (pointing down)
//            
//            // Trigger sound when the calculated segment changes
//            .onChange(of: segmentForFrame) { _ in
//                
////                AudioServicesPlaySystemSoundWithCompletion(1104) {}
//                feedback.selectionChanged()
//                // Optional: For louder audio if haptics aren't enough:
//                // AudioServicesPlaySystemSound(1104)
//            }
//    }
//}
//
//struct Wheel: View {
//    
//    let segments: [Segment]
//    
//    private var totalValue: Double {
//        segments.reduce(0) { $0 + $1.value }
//    }
//    
//    var body: some View {
//        GeometryReader { proxy in
//            let radius = proxy.size.width / 2
//            
//            ZStack {
//                ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
//                    
//                    let data = calculateSegmentData(index: index)
//                    
//                    ZStack {
//                        Circle()
//                            .inset(by: radius / 2)
//                            .trim(from: data.startPct, to: data.endPct)
//                            .stroke(segment.color, style: StrokeStyle(lineWidth: radius))
//                            
//                        
//                        Text(segment.name)
//                            .font(.system(size: 12, weight: .bold))
//                            .foregroundColor(.white)
//                            .offset(x: radius * 0.7)
//                            .rotationEffect(.radians(data.midAngle))
//                    }
//                }
//            }
//        }
//    }
//    
//    private func calculateSegmentData(index: Int) -> (startPct: CGFloat, endPct: CGFloat, midAngle: Double) {
//        
//        var precedingValue: Double = 0
//        for i in 0..<index {
//            precedingValue += segments[i].value
//        }
//        
//        let startPct = precedingValue / totalValue
//        let endPct = (precedingValue + segments[index].value) / totalValue
//        
//        let midPct = startPct + ((endPct - startPct) / 2)
//        let midAngle = midPct * (2 * .pi)
//        
//        return (CGFloat(startPct), CGFloat(endPct), midAngle)
//    }
//}
//
//#Preview {
//    SpinWheel()
//}
