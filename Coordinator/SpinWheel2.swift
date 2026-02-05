//
//  SpinWheel2.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/5/26.
//

// APP: -
// Spin Wheels
// Ads to spin a specific wheel unlimited
// $1 for more than one wheel
// See other wheel options, but cannot use
// Widget ?

// TODO: -
/// Allow for flag to allow passively slowly rotation for their to be no true 0
/// Elimation style
/// Rigged style

import SwiftUI
import UIKit

// MARK: - Models

public struct Segment: Identifiable, Equatable {
    
    public let id = UUID()
    public let name: String
    public let value: Double
    public let color: Color
    
    public init(name: String, value: Double, color: Color) {
        self.name = name
        self.value = value
        self.color = color
    }
    
}

public enum Distribution {
    
    case weighted
    case uniform
    /// Elimation style. Remove segment once selected
    /// Rigged
    
}

// MARK: - Logic

public struct WheelMath {
    
    static func segment(for rotation: Double,
                        pointerAngle: Double,
                        in segments: [Segment],
                        distribution: Distribution) -> Segment? {
        
        // pointerAngle is where the physical arrow sits (e.g., -pi/2 for Top)
        // rotation is the cumulative spin of the wheel
        var relativeAngle = pointerAngle - rotation
        
        relativeAngle = relativeAngle.truncatingRemainder(dividingBy: 2 * .pi)
        if relativeAngle < 0 { relativeAngle += 2 * .pi }
        
        switch distribution {
        case .uniform:
            let segmentCount = Double(segments.count)
            let sliceSize = (2 * .pi) / segmentCount
            let index = Int(floor(relativeAngle / sliceSize))
            let clampedIndex = max(0, min(index, segments.count - 1))
            return segments[clampedIndex]
            
        case .weighted:
            let totalValue = segments.reduce(0) { $0 + $1.value }
            var currentAngle: Double = 0
            
            for segment in segments {
                let sliceSize = (segment.value / totalValue) * (2 * .pi)
                let endAngle = currentAngle + sliceSize
                
                if relativeAngle >= currentAngle && relativeAngle < endAngle {
                    return segment
                }
                currentAngle += sliceSize
            }
        }
        
        return segments.first
    }
    
}

// MARK: - Main View

public struct SpinWheel<SliceContent: View, HubContent: View>: View {
    
    @State private var rotation: Double = 0
    @State private var isSpinning: Bool = false
    @State private var winningIndex: Int = 0
    @State private var liveSegment: Segment?
    
    @State private var dragRotation: Double = 0
    @State private var lastDragValue: CGFloat = 0
    
    private let segments: [Segment]
    private var distribution: Distribution
    private var pickerColor: Color
    private var spinAnimation: Animation
    private var shouldChangeColorWhileSpinning: Bool
    private var allowsDragging: Bool
    
    // Configurable Pointer
    private var pointerAngle: Double
    private var pointerRotationOffset: Double
    
    private var onSpinEnd: ((Segment) -> Void)?
    
    private let sliceBuilder: (Segment) -> SliceContent
    private let hubBuilder: () -> HubContent
    
    public init(segments: [Segment]? = nil,
                distribution: Distribution = .weighted,
                pickerColor: Color = .primary,
                pointerAngle: Double = -Double.pi / 2,
                pointerRotationOffset: Double = 0,
                spinAnimation: Animation = .timingCurve(0.15, 0.5, 0.2, 1.0, duration: 4.5),
                shouldChangeColorWhileSpinning: Bool = true,
                allowsDragging: Bool = true,
                onSpinEnd: ((Segment) -> Void)? = nil,
                @ViewBuilder sliceContent: @escaping (Segment) -> SliceContent,
                @ViewBuilder hubContent: @escaping () -> HubContent) {
        
        let defaultSegments = [
            Segment(name: "Steve", value: 20, color: .pink),
            Segment(name: "John", value: 40, color: .green),
            Segment(name: "Bill", value: 10, color: .mint),
            Segment(name: "Dave", value: 10, color: .indigo),
            Segment(name: "Alan", value: 20, color: .teal),
        ]
        
        self.segments = segments ?? defaultSegments
        self.distribution = distribution
        self.pickerColor = pickerColor
        self.pointerAngle = pointerAngle
        self.pointerRotationOffset = pointerRotationOffset
        self.spinAnimation = spinAnimation
        self.shouldChangeColorWhileSpinning = shouldChangeColorWhileSpinning
        self.allowsDragging = allowsDragging
        self.onSpinEnd = onSpinEnd
        self.sliceBuilder = sliceContent
        self.hubBuilder = hubContent
        
    }
    
    public var body: some View {
        
        VStack(spacing: 30) {
            
            wheelContainer
            
            VStack(spacing: 16) {
                resultLabel
                resetButton
            }
            
        }
        .padding()
        
    }
    
    private var wheelContainer: some View {
        
        ZStack {
            
            wheelView
            pointerView
            
            // The Hub acts as the spin button
            Button(action: { spin() }) {
                hubBuilder()
            }
            .disabled(isSpinning)
            .buttonStyle(.plain)
            
        }
        
    }
    
    private var wheelView: some View {
        
        WheelView(segments: segments, distribution: distribution, sliceBuilder: sliceBuilder)
            .frame(width: 280, height: 280)
            .rotationEffect(.radians(rotation + dragRotation))
            .gesture(allowsDragging ? dragGesture : nil)
        
    }
    
    private var pointerView: some View {
        
        GeometryReader { proxy in
            
            let radius = min(proxy.size.width, proxy.size.height) / 2
            
            PointerView(
                rotation: rotation + dragRotation,
                pointerAngle: pointerAngle,
                pointerRotationOffset: pointerRotationOffset,
                segments: segments,
                distribution: distribution,
                defaultColor: pickerColor,
                shouldUpdateColor: shouldChangeColorWhileSpinning,
                liveSegment: $liveSegment
            )
            .frame(width: 35, height: 35)
            .position(
                x: proxy.size.width / 2 + cos(pointerAngle) * radius,
                y: proxy.size.height / 2 + sin(pointerAngle) * radius
            )
            .zIndex(2)
            
        }
        .frame(width: 280, height: 280)
        
    }
    
    private var resultLabel: some View {
        
        VStack(spacing: 4) {
            
            Text(isSpinning ? "Spinning..." : "Winner")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            Text(segments[winningIndex].name)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(isSpinning ? .primary : segments[winningIndex].color)
            
        }
        .animation(.spring(), value: isSpinning)
        
    }
    
    private var resetButton: some View {
        
        Button(action: reset) {
            Label("Reset", systemImage: "arrow.counterclockwise")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
        }
        .opacity(isSpinning || (rotation == 0 && dragRotation == 0) ? 0 : 1)
        
    }
    
    // MARK: - Interactions
    
    private var dragGesture: some Gesture {
        
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard !isSpinning else { return }
                let velocity = value.translation.width - lastDragValue
                dragRotation += Double(velocity / 100)
                lastDragValue = value.translation.width
            }
            .onEnded { value in
                lastDragValue = 0
                let velocity = value.predictedEndTranslation.width / 50
                spin(withVelocity: Double(velocity))
            }
        
    }
    
    private func spin(withVelocity velocity: Double = 0) {
        
        guard !isSpinning else { return }
        isSpinning = true
        
        let baseSpin = Double.random(in: 8...14)
        let extraVelocity = max(abs(velocity), 2.0)
        let totalSpinAmount = ((baseSpin + extraVelocity) * (2 * .pi))
        let newRotation = (self.rotation + dragRotation) + totalSpinAmount
        
        withAnimation(spinAnimation) {
            self.rotation = newRotation
            self.dragRotation = 0
        } completion: {
            self.isSpinning = false
            finalizeWinner()
        }
        
    }
    
    private func reset() {
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            rotation = 0
            dragRotation = 0
            winningIndex = 0
        }
        
    }
    
    private func finalizeWinner() {
        
        if let winner = WheelMath.segment(for: rotation, pointerAngle: pointerAngle, in: segments, distribution: distribution),
           let index = segments.firstIndex(of: winner) {
            self.winningIndex = index
            self.onSpinEnd?(winner)
        }
        
    }
    
}

// MARK: - Default Initializers

extension SpinWheel where HubContent == DefaultHubView, SliceContent == Text {
    
    public init(segments: [Segment]? = nil,
                distribution: Distribution = .weighted,
                pickerColor: Color = .primary,
                pointerAngle: Double = -Double.pi / 2,
                pointerRotationOffset: Double = 0,
                spinAnimation: Animation = .timingCurve(0.15, 0.5, 0.2, 1.0, duration: 4.5),
                shouldChangeColorWhileSpinning: Bool = true,
                allowsDragging: Bool = true,
                onSpinEnd: ((Segment) -> Void)? = nil) {
        
        self.init(segments: segments,
                  distribution: distribution,
                  pickerColor: pickerColor,
                  pointerAngle: pointerAngle,
                  pointerRotationOffset: pointerRotationOffset,
                  spinAnimation: spinAnimation,
                  shouldChangeColorWhileSpinning: shouldChangeColorWhileSpinning,
                  allowsDragging: allowsDragging,
                  onSpinEnd: onSpinEnd) { segment in
            Text(segment.name)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.white)
        } hubContent: {
            DefaultHubView()
        }
    }
    
}

// MARK: - Subviews

public struct DefaultHubView: View {
    public var body: some View {
        Circle()
            .fill(Color(.systemBackground))
            .frame(width: 50, height: 50)
            .shadow(color: .black.opacity(0.15), radius: 4)
            .overlay(
                Image(systemName: "hand.tap.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            )
    }
}

struct PointerView: View, Animatable {
    
    var rotation: Double
    var pointerAngle: Double
    var pointerRotationOffset: Double
    var segments: [Segment]
    var distribution: Distribution
    var defaultColor: Color
    var shouldUpdateColor: Bool
    @Binding var liveSegment: Segment?
    
    private let feedback = UISelectionFeedbackGenerator()
    
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    var body: some View {
        
        let activeSegment = WheelMath.segment(for: rotation, pointerAngle: pointerAngle, in: segments, distribution: distribution)
        
        Image(systemName: "triangle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(shouldUpdateColor ? activeSegment?.color ?? defaultColor : defaultColor)
            .shadow(color: .black.opacity(0.3), radius: 2, y: -4)
            // (3 * .pi / 2) rotates the triangle 270 deg so the Tip faces the Center
            .rotationEffect(.radians(pointerAngle + (3 * .pi / 2) + pointerRotationOffset))
            .onChange(of: activeSegment) { _, newValue in
                if let segment = newValue {
                    feedback.selectionChanged()
                    updateBinding(segment)
                }
            }
        
    }
    
    private func updateBinding(_ segment: Segment) {
        Task { @MainActor in
            self.liveSegment = segment
        }
    }
    
}

struct WheelView<SliceContent: View>: View {
    
    let segments: [Segment]
    let distribution: Distribution
    let sliceBuilder: (Segment) -> SliceContent
    
    var body: some View {
        
        GeometryReader { proxy in
            
            let radius = proxy.size.width / 2
            let totalValue = segments.reduce(0) { $0 + $1.value }
            
            ZStack {
                ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
                    let startValue = segments.prefix(index).reduce(0) { $0 + $1.value }
                    SliceView(
                        segment: segment,
                        index: index,
                        count: segments.count,
                        totalValue: totalValue,
                        radius: radius,
                        segmentsBeforeValue: startValue,
                        distribution: distribution,
                        content: sliceBuilder
                    )
                }
            }
            
        }
        
    }
    
    private func calculateTotalValue() -> Double {
        segments.reduce(0) { $0 + $1.value }
    }
    
}

struct SliceView<SliceContent: View>: View {
    
    let segment: Segment
    let index: Int
    let count: Int
    let totalValue: Double
    let radius: CGFloat
    let segmentsBeforeValue: Double
    let distribution: Distribution
    let content: (Segment) -> SliceContent
    
    var body: some View {
        
        let data = calculateData()
        
        ZStack {
            Circle()
                .inset(by: radius / 2)
                .trim(from: data.start, to: data.end)
                .stroke(segment.color, style: StrokeStyle(lineWidth: radius))
            
            content(segment)
                .offset(x: radius * 0.65)
                .rotationEffect(.radians(data.midAngle))
        }
        
    }
    
    private func calculateData() -> (start: CGFloat, end: CGFloat, midAngle: Double) {
        let startPct: Double
        let endPct: Double
        
        if distribution == .uniform {
            startPct = Double(index) / Double(count)
            endPct = Double(index + 1) / Double(count)
        } else {
            startPct = segmentsBeforeValue / totalValue
            endPct = (segmentsBeforeValue + segment.value) / totalValue
        }
        
        let midPct = startPct + ((endPct - startPct) / 2)
        let midAngle = midPct * (2 * .pi)
        
        return (CGFloat(startPct), CGFloat(endPct), midAngle)
    }
    
}

// MARK: - Testing Preview

#Preview {
    NavigationStack {
        ScrollView {
            VStack(spacing: 80) {
                
                // 1. Basic Default (Pointer Top -90°)
                // Tests: Default Init, Weighted, Text Slice, Default Hub
                VStack(alignment: .leading) {
                    previewHeader(title: "Default Config", subtitle: "Pointer Top (-90°) • Weighted")
                    SpinWheel(distribution: .weighted)
                }
                
                // 2. Right-Side Pointer (0 radians)
                // Tests: Pointer Rotation logic, Uniform, No Dragging
                VStack(alignment: .leading) {
                    previewHeader(title: "Right Side Pointer", subtitle: "Pointer Right (0°) • Uniform • No Drag")
                    SpinWheel(
                        segments: [
                            Segment(name: "A", value: 1, color: .red),
                            Segment(name: "B", value: 1, color: .blue),
                            Segment(name: "C", value: 1, color: .green)
                        ],
                        distribution: .uniform,
                        pointerAngle: 0,
                        allowsDragging: false
                    )
                }

                // 3. Bottom Pointer (pi/2) with Custom Hub
                // Tests: Pointer Rotation (should face UP), Custom Hub Builder
                VStack(alignment: .leading) {
                    previewHeader(title: "Bottom Pointer", subtitle: "Pointer Bottom (90°) • Custom Hub")
                    SpinWheel(
                        distribution: .weighted,
                        pointerAngle: .pi / 2
                    ) { segment in
                        Text(segment.name).bold().foregroundColor(.white)
                    } hubContent: {
                        Circle().fill(.black)
                            .frame(width: 40, height: 40)
                            .overlay(Text("GO").foregroundColor(.white).font(.caption2.bold()))
                    }
                }
                
                // 4. Complex Custom Slice View (Casino Royale)
                // Tests: Complex ViewBuilder content, Left Pointer (pi), Uniform
                VStack(alignment: .leading) {
                    previewHeader(title: "Casino Royale", subtitle: "Complex Custom Slices • Pointer Left (180°)")
                    SpinWheel(
                        segments: [
                            Segment(name: "100", value: 1, color: .black),
                            Segment(name: "500", value: 1, color: .red),
                            Segment(name: "1000", value: 1, color: .black),
                            Segment(name: "BANK", value: 1, color: .green)
                        ],
                        distribution: .uniform,
                        pointerAngle: .pi,
                        shouldChangeColorWhileSpinning: false
                    ) { segment in
                        VStack(spacing: 2) {
                            if segment.name == "BANK" {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.yellow)
                            } else {
                                Text("$")
                                    .font(.caption2)
                                    .opacity(0.6)
                                Text(segment.name)
                                    .font(.headline)
                                    .fontWeight(.heavy)
                            }
                        }
                        .foregroundColor(.white)
                        .rotationEffect(.radians(.pi / 2)) // Counter-rotate content
                        .padding(8)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .opacity(0.3)
                        )
                        .rotationEffect(.radians(-.pi / 2)) // Re-align capsule
                    } hubContent: {
                        ZStack {
                            Circle().fill(Color.yellow)
                            Image(systemName: "star.fill").foregroundColor(.black)
                        }
                        .frame(width: 50, height: 50)
                        .shadow(radius: 5)
                    }
                }
                
                // 5. Manual Offset Override
                // Tests: PointerRotationOffset (Dev wants pointer to skew 45 degrees)
                VStack(alignment: .leading) {
                    previewHeader(title: "Manual Offset", subtitle: "Pointer Skewed 45° via Dev Override")
                    SpinWheel(
                        distribution: .uniform,
                        pointerAngle: -Double.pi / 2,
                        pointerRotationOffset: .pi / 4 // 45 deg skew
                    )
                }
                
                Spacer(minLength: 100)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Spin Wheel Lab")
        .background(Color(.systemGroupedBackground))
    }
}

@ViewBuilder
private func previewHeader(title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title).font(.title3.bold())
        Text(subtitle).font(.caption).foregroundStyle(.secondary)
    }
    .padding(.horizontal)
}
