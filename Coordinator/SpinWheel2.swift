import SwiftUI
import UIKit

// TODO: - Have a way to tell it when to spin

// MARK: - Models

public struct Segment: Identifiable, Equatable {
    
    public let id = UUID()
    public let name: String
    public let value: Double
    public let color: Color
    public let backgroundImage: Image?
    
    public init(name: String, value: Double, color: Color, backgroundImage: Image? = nil) {
        self.name = name
        self.value = value
        self.color = color
        self.backgroundImage = backgroundImage
    }
    
    // Equatable conformance manually needed for Image comparison (we ignore image for equality or check via ID)
    public static func == (lhs: Segment, rhs: Segment) -> Bool {
        return lhs.id == rhs.id
    }
}

public enum Distribution: Equatable {
    case weighted
    case uniform
    /// Elimination style. Remove segment once selected
    case elimination
    /// Rigged style where we can prefedine who the winner should be
    case rigged(Segment)
}

// MARK: - Helper Shapes

/// A custom shape to draw the slice perfectly from the center, allowing for image clipping
struct WedgeShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    var animatableData: AnimatablePair<Double, Double> {
            get { AnimatablePair(startAngle.degrees, endAngle.degrees) }
            set {
                startAngle = Angle(degrees: newValue.first)
                endAngle = Angle(degrees: newValue.second)
            }
        }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Logic

public struct WheelMath {
    
    static func segment(for rotation: Double,
                        pointerAngle: Double,
                        in segments: [Segment],
                        distribution: Distribution) -> Segment? {
        
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
            
        case .weighted, .elimination, .rigged:
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
    
    static func rotationToLand(on target: Segment,
                               currentRotation: Double,
                               pointerAngle: Double,
                               segments: [Segment]) -> Double {
        
        let totalValue = segments.reduce(0) { $0 + $1.value }
        
        var cumulativeValue: Double = 0
        var targetCenterAngle: Double = 0
        
        for segment in segments {
            let sliceSize = (segment.value / totalValue) * (2 * .pi)
            if segment == target {
                targetCenterAngle = ((cumulativeValue / totalValue) * (2 * .pi)) + (sliceSize / 2)
                break
            }
            cumulativeValue += segment.value
        }
        
        let targetRotationPosition = pointerAngle - targetCenterAngle
        let currentMod = currentRotation.truncatingRemainder(dividingBy: 2 * .pi)
        var delta = targetRotationPosition - currentMod
        while delta < 0 { delta += 2 * .pi }
        
        return delta
    }
}

// MARK: - Main View

public struct SpinWheel<SliceContent: View, HubContent: View>: View {
    
    @Binding private var spinTrigger: Int
    
    @State private var rotation: Double = 0
    @State private var isSpinning: Bool = false
    @State private var winningIndex: Int = 0
    @State private var liveSegment: Segment?
    
    @State private var dragRotation: Double = 0
    @State private var lastDragValue: CGFloat = 0
    
    // Passive Spin State
    @State private var passiveRotationPhase: Double = 0
    
    private let segments: [Segment]
    private var distribution: Distribution
    private var pickerColor: Color
    private var spinAnimation: Animation
    private var shouldChangeColorWhileSpinning: Bool
    private var allowsDragging: Bool
    
    // Configurable Pointer
    private var pointerAngle: Double
    private var pointerRotationOffset: Double
    
    private var segmentDividerColor: Color
    
    // Passive Spin Flag
    private var enablePassiveSpin: Bool
    
    private var onSpinEnd: ((Segment) -> Void)?
    
    private let sliceBuilder: (Segment) -> SliceContent
    private let hubBuilder: () -> HubContent
    
    public init(segments: [Segment]? = nil,
                distribution: Distribution = .weighted,
                pickerColor: Color = .primary,
                segmentDividerColor: Color = .clear,
                pointerAngle: Double = -Double.pi / 2,
                pointerRotationOffset: Double = 0,
                spinAnimation: Animation = .timingCurve(0.15, 0.5, 0.2, 1.0, duration: 4.5),
                shouldChangeColorWhileSpinning: Bool = true,
                allowsDragging: Bool = true,
                enablePassiveSpin: Bool = false,
                spinTrigger: Binding<Int> = .constant(0),
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
        
        self._spinTrigger = spinTrigger
        self.segments = segments ?? defaultSegments
        self.distribution = distribution
        self.pickerColor = pickerColor
        self.segmentDividerColor = segmentDividerColor
        self.pointerAngle = pointerAngle
        self.pointerRotationOffset = pointerRotationOffset
        self.spinAnimation = spinAnimation
        self.shouldChangeColorWhileSpinning = shouldChangeColorWhileSpinning
        self.allowsDragging = allowsDragging
        self.enablePassiveSpin = enablePassiveSpin
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
        .onAppear {
            if enablePassiveSpin {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    passiveRotationPhase = 2 * .pi
                }
            }
        }
        .onChange(of: spinTrigger) { _, _ in
            spin()
        }
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
        let totalRotation = rotation + dragRotation + (isSpinning ? 0 : passiveRotationPhase)
        
        return WheelView(
            segments: segments,
            distribution: distribution,
            dividerColor: segmentDividerColor,
            sliceBuilder: sliceBuilder
        )
        .frame(width: 280, height: 280)
        .rotationEffect(.radians(totalRotation))
        .gesture(allowsDragging ? dragGesture : nil)
    }
    
    private var pointerView: some View {
        GeometryReader { proxy in
            let radius = min(proxy.size.width, proxy.size.height) / 2
            let activeRotation = rotation + dragRotation + (isSpinning ? 0 : passiveRotationPhase)
            
            PointerView(
                rotation: activeRotation,
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
            
            if !segments.isEmpty {
                Text(liveSegment?.name ?? segments[winningIndex].name)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(isSpinning ? .primary : (liveSegment?.color ?? segments[winningIndex].color))
                    .transition(.identity)
                    .id("ResultText_\(liveSegment?.id.uuidString ?? "")")
            } else {
                Text("Empty Wheel")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
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
        
        let currentVisualRotation = rotation + dragRotation + passiveRotationPhase
        self.rotation = currentVisualRotation
        self.dragRotation = 0
        self.passiveRotationPhase = 0
        
        isSpinning = true
        var totalSpinAmount: Double = 0
        
        if case .rigged(let target) = distribution {
            let baseSpins = 5.0
            let requiredDelta = WheelMath.rotationToLand(on: target,
                                                         currentRotation: self.rotation,
                                                         pointerAngle: pointerAngle,
                                                         segments: segments)
            totalSpinAmount = (baseSpins * 2 * .pi) + requiredDelta
        } else {
            let baseSpin = Double.random(in: 8...14)
            let extraVelocity = max(abs(velocity), 2.0)
            totalSpinAmount = ((baseSpin + extraVelocity) * (2 * .pi))
        }
        
        let newRotation = self.rotation + totalSpinAmount
        
        withAnimation(spinAnimation) {
            self.rotation = newRotation
        } completion: {
            self.isSpinning = false
            finalizeWinner()
            
            if enablePassiveSpin {
                passiveRotationPhase = 0
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    passiveRotationPhase = 2 * .pi
                }
            }
        }
    }
    
    private func reset() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            rotation = 0
            dragRotation = 0
            winningIndex = 0
            passiveRotationPhase = 0
        }
        if enablePassiveSpin {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                passiveRotationPhase = 2 * .pi
            }
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
                segmentDividerColor: Color = .clear,
                pointerAngle: Double = -Double.pi / 2,
                pointerRotationOffset: Double = 0,
                spinAnimation: Animation = .timingCurve(0.15, 0.5, 0.2, 1.0, duration: 4.5),
                shouldChangeColorWhileSpinning: Bool = true,
                allowsDragging: Bool = true,
                enablePassiveSpin: Bool = false,
                onSpinEnd: ((Segment) -> Void)? = nil) {
        
        self.init(segments: segments,
                  distribution: distribution,
                  pickerColor: pickerColor,
                  segmentDividerColor: segmentDividerColor,
                  pointerAngle: pointerAngle,
                  pointerRotationOffset: pointerRotationOffset,
                  spinAnimation: spinAnimation,
                  shouldChangeColorWhileSpinning: shouldChangeColorWhileSpinning,
                  allowsDragging: allowsDragging,
                  enablePassiveSpin: enablePassiveSpin,
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
            .rotationEffect(.radians(pointerAngle + (3 * .pi / 2) + pointerRotationOffset))
            .onChange(of: activeSegment) { _, newValue in
                if let segment = newValue {
                    feedback.selectionChanged()
                    updateBinding(segment)
                }
            }
            .onAppear {
                if let s = activeSegment { liveSegment = s }
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
    let dividerColor: Color
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
                        dividerColor: dividerColor,
                        content: sliceBuilder
                    )
                }
            }
        }
    }
}

// MARK: - UPDATED SLICE VIEW

struct SliceView<SliceContent: View>: View {
    
    let segment: Segment
    let index: Int
    let count: Int
    let totalValue: Double
    let radius: CGFloat
    let segmentsBeforeValue: Double
    let distribution: Distribution
    let dividerColor: Color // New Property
    let content: (Segment) -> SliceContent
    
    var body: some View {
        let data = calculateData()
        
        // Convert percentages to Angles for the Shape
        let startAngle = Angle(radians: data.start * 2 * .pi)
        let endAngle = Angle(radians: data.end * 2 * .pi)
        
        ZStack {
            // 1. The Wedge Container
            WedgeShape(startAngle: startAngle, endAngle: endAngle)
                .fill(segment.color) // Fallback color if image fails or is transparent
                .overlay {
                    // 2. The Image Overlay (if present)
                    if let bgImage = segment.backgroundImage {
                        GeometryReader { geo in
                            bgImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        }
                        // Clip the square image into the wedge shape
                        .clipShape(WedgeShape(startAngle: startAngle, endAngle: endAngle))
                    }
                }
                // 3. The Separator / Border Stroke
                .overlay {
                    WedgeShape(startAngle: startAngle, endAngle: endAngle)
                        .stroke(dividerColor, lineWidth: 1)
                }

            // 4. The Content (Text/Icons) on top
            content(segment)
                .offset(x: radius * 0.65)
                .rotationEffect(.radians(data.midAngle))
        }
    }
    
    private func calculateData() -> (start: Double, end: Double, midAngle: Double) {
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
        
        return (startPct, endPct, midAngle)
    }
}

struct DemoWheelSpin: View {
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 80) {
                    
                    VStack(alignment: .leading) {
                        
                        VStack(alignment: .leading) {
                                                previewHeader(title: "Segment Dividers", subtitle: "Opt-in: White Stroke enabled")
                                                SpinWheel(
                                                    distribution: .weighted,
                                                    segmentDividerColor: .white // Opt-in here
                                                )
                                            }
                        
                        previewHeader(title: "Nature", subtitle: "Complex Custom Slices • Pointer Left (180°)")
                        
                        SpinWheel(
                            segments: [
                                Segment(name: "Sky", value: 1, color: .blue, backgroundImage: Image(.image1)),
                                Segment(name: "Fire", value: 1, color: .red, backgroundImage: Image(.image2)),
                                Segment(name: "Nature", value: 1, color: .green, backgroundImage: Image(.image3)),
                                Segment(name: "Ocean", value: 1, color: .teal, backgroundImage: Image(.image4))
                            ],
                            distribution: .uniform,
                            segmentDividerColor: .white,
                            pointerAngle: .pi,
                            shouldChangeColorWhileSpinning: false
                        ) { segment in
                            Text(segment.name)
                                .font(.caption.bold())
                                .padding(4)
                                .background(.ultraThinMaterial)
                                .cornerRadius(4)
                        } hubContent: {
                            Circle().fill(.white).frame(width: 40).shadow(radius: 2)
                        }
                    }
                    
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
                    
                    // -----------------------------------------------------
                    // NEW PREVIEWS BELOW
                    // -----------------------------------------------------
                    
                    Divider()
                    Text("NEW FEATURES").font(.headline).foregroundStyle(.secondary)
                    
                    // 6. Passive Rotation
                    VStack(alignment: .leading) {
                        previewHeader(title: "Passive Spin", subtitle: "Always rotating slowly (No true 0)")
                        SpinWheel(
                            distribution: .weighted,
                            enablePassiveSpin: true
                        )
                    }
                    
                    // 7. Elimination Mode
                    EliminationPreviewWrapper()
                    
                    // 8. Rigged Mode
                    RiggedPreviewWrapper()
                    
                    Spacer(minLength: 100)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Spin Wheel Lab")
            .background(Color(.systemGroupedBackground))
            
        }
    }
    
}

#Preview {
    DemoWheelSpin()
}

// MARK: - New Feature Preview Helpers

struct EliminationPreviewWrapper: View {
    
    @State private var segments: [Segment] = [
        Segment(name: "A", value: 20, color: .red),
        Segment(name: "B", value: 20, color: .orange),
        Segment(name: "C", value: 20, color: .yellow),
        Segment(name: "D", value: 20, color: .green),
        Segment(name: "E", value: 20, color: .blue),
        Segment(name: "F", value: 20, color: .purple)
    ]
    
    @State private var lastRemoved: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            previewHeader(title: "Elimination Mode", subtitle: "Removes winner on completion")
            
            Text("Last Removed: \(lastRemoved)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            SpinWheel(
                segments: segments,
                distribution: .elimination,
                onSpinEnd: { winner in
                    lastRemoved = winner.name
                    // In a real app, you might want a delay before removal
                    withAnimation {
                        if let index = segments.firstIndex(of: winner) {
                            segments.remove(at: index)
                        }
                    }
                }
            )
            
            if segments.isEmpty {
                Button("Reset Elimination") {
                    segments = [
                        Segment(name: "A", value: 20, color: .red),
                        Segment(name: "B", value: 20, color: .orange),
                        Segment(name: "C", value: 20, color: .yellow),
                        Segment(name: "D", value: 20, color: .green),
                        Segment(name: "E", value: 20, color: .blue),
                        Segment(name: "F", value: 20, color: .purple)
                    ]
                    lastRemoved = ""
                }
            }
        }
    }
}

struct RiggedPreviewWrapper: View {
    
    let allSegments = [
        Segment(name: "LOSE", value: 40, color: .gray),
        Segment(name: "LOSE", value: 40, color: .gray),
        Segment(name: "JACKPOT", value: 5, color: .yellow),
        Segment(name: "LOSE", value: 40, color: .gray),
    ]
    
    @State private var mode: Distribution = .weighted
    
    var body: some View {
        VStack(alignment: .leading) {
            previewHeader(title: "Rigged Mode", subtitle: "Force specific outcomes")
            
            HStack {
                Button("Fair Spin") { mode = .weighted }
                    .buttonStyle(.bordered)
                    .tint(mode == .weighted ? .blue : .gray)
                
                Button("Force Jackpot") {
                    // Find the jackpot segment
                    if let jackpot = allSegments.first(where: { $0.name == "JACKPOT" }) {
                        mode = .rigged(jackpot)
                    }
                }
                .buttonStyle(.bordered)
                .tint(isRigged ? .red : .gray)
            }
            
            SpinWheel(
                segments: allSegments,
                distribution: mode,
                enablePassiveSpin: true
            ) { segment in
                Text(segment.name)
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(segment.name == "JACKPOT" ? .black : .white)
            } hubContent: {
                 DefaultHubView()
            }
        }
    }
    
    var isRigged: Bool {
        if case .rigged = mode { return true }
        return false
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

