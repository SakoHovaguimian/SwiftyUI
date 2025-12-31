import SwiftUI
import CoreMotion
import Combine

// MARK: - Model

public struct LevelReading: Equatable, Sendable {
    
    public let pitchDegrees: Double   // front/back tilt
    public let rollDegrees: Double    // left/right tilt
    
    public init(pitchDegrees: Double,
                rollDegrees: Double) {
        
        self.pitchDegrees = pitchDegrees
        self.rollDegrees = rollDegrees
        
    }
    
}

// MARK: - Service

public protocol NewLevelMotionService: AnyObject, Sendable {
    
    var isAvailable: Bool { get }
    
    func start(updatesPerSecond: Double) -> AsyncStream<LevelReading>
    func stop()
    
}

public final class NewLevelMotionServiceImpl: NewLevelMotionService {
    
    private let motion = CMMotionManager()
    private var continuation: AsyncStream<LevelReading>.Continuation?
    
    public init() { }
    
    public var isAvailable: Bool {
        self.motion.isDeviceMotionAvailable
    }
    
    public func start(updatesPerSecond: Double = 60.0) -> AsyncStream<LevelReading> {
        
        AsyncStream { continuation in
            
            self.continuation = continuation
            
            guard self.motion.isDeviceMotionAvailable else {
                continuation.finish()
                return
            }
            
            self.motion.deviceMotionUpdateInterval = 1.0 / max(1.0, updatesPerSecond)
            
            self.motion.startDeviceMotionUpdates(to: .main) { motion, _ in
                
                guard let motion else { return }
                
                let pitch = motion.attitude.pitch * 180.0 / .pi
                let roll  = motion.attitude.roll  * 180.0 / .pi
                
                continuation.yield(.init(pitchDegrees: pitch, rollDegrees: roll))
                
            }
            
            continuation.onTermination = { _ in
                self.stop()
            }
            
        }
        
    }
    
    public func stop() {
        
        self.motion.stopDeviceMotionUpdates()
        self.continuation?.finish()
        self.continuation = nil
        
    }
    
}

// MARK: - View Model

@MainActor
public final class HorizontalLevelViewModel: ObservableObject {
    
    public struct Config: Sendable {
        
        public var toleranceDegrees: Double
        public var maxDisplayedDegrees: Double
        public var updatesPerSecond: Double
        public var hapticsEnabled: Bool
        
        public init(toleranceDegrees: Double = 1.0,
                    maxDisplayedDegrees: Double = 10.0,
                    updatesPerSecond: Double = 60.0,
                    hapticsEnabled: Bool = true) {
            
            self.toleranceDegrees = toleranceDegrees
            self.maxDisplayedDegrees = maxDisplayedDegrees
            self.updatesPerSecond = updatesPerSecond
            self.hapticsEnabled = hapticsEnabled
            
        }
        
    }
    
    @Published public private(set) var reading: LevelReading = .init(pitchDegrees: 0, rollDegrees: 0)
    @Published public private(set) var rollDegrees: Double = 0
    @Published public private(set) var isLevel: Bool = false
    @Published public private(set) var isRunning: Bool = false
    
    public var maxDisplayedDegrees: Double { self.config.maxDisplayedDegrees }
    public var toleranceDegrees: Double { self.config.toleranceDegrees }
    
    private let service: any NewLevelMotionService
    private let config: Config
    
    private var task: Task<Void, Never>?
    private var baseline: LevelReading = .init(pitchDegrees: 0, rollDegrees: 0)
    private var lastLevelState: Bool = false
    
    public init(service: any NewLevelMotionService,
                config: Config = .init()) {
        
        self.service = service
        self.config = config
        
    }
    
    public func start() {
        
        guard !self.isRunning else { return }
        guard self.service.isAvailable else { return }
        
        self.isRunning = true
        
        self.task = Task { [weak self] in
            
            guard let self else { return }
            
            let stream = self.service.start(updatesPerSecond: self.config.updatesPerSecond)
            
            for await reading in stream {
                
                let adjusted = self.applyBaseline(to: reading)
                
                self.reading = adjusted
                self.rollDegrees = adjusted.rollDegrees
                
                let nowLevel = abs(adjusted.rollDegrees) <= self.config.toleranceDegrees
                self.isLevel = nowLevel
                
                if self.config.hapticsEnabled,
                   nowLevel != self.lastLevelState,
                   nowLevel == true {
                    
                    Self.fireHaptic()
                    
                }
                
                self.lastLevelState = nowLevel
                
            }
            
        }
        
    }
    
    public func stop() {
        
        guard self.isRunning else { return }
        
        self.task?.cancel()
        self.task = nil
        
        self.service.stop()
        self.isRunning = false
        
    }
    
    public func calibrate() {
        self.baseline = self.reading
    }
    
    public func resetCalibration() {
        self.baseline = .init(pitchDegrees: 0, rollDegrees: 0)
    }
    
    private func applyBaseline(to reading: LevelReading) -> LevelReading {
        
        .init(
            pitchDegrees: reading.pitchDegrees - self.baseline.pitchDegrees,
            rollDegrees: reading.rollDegrees - self.baseline.rollDegrees
        )
        
    }
    
    private static func fireHaptic() {
        
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        #endif
        
    }
    
}

// MARK: - View

public struct HorizontalLevelView: View {
    
    public struct Style: Sendable {
        
        public var width: CGFloat
        public var height: CGFloat
        public var bubbleSize: CGFloat
        public var trackCornerRadius: CGFloat
        public var showsTicks: Bool
        public var showsReadout: Bool
        
        public init(width: CGFloat = 320,
                    height: CGFloat = 56,
                    bubbleSize: CGFloat = 20,
                    trackCornerRadius: CGFloat = 16,
                    showsTicks: Bool = true,
                    showsReadout: Bool = true) {
            
            self.width = width
            self.height = height
            self.bubbleSize = bubbleSize
            self.trackCornerRadius = trackCornerRadius
            self.showsTicks = showsTicks
            self.showsReadout = showsReadout
            
        }
        
    }
    
    @StateObject private var viewModel: HorizontalLevelViewModel
    
    private let style: Style
    
    public init(viewModel: @autoclosure @escaping () -> HorizontalLevelViewModel,
                style: Style = .init()) {
        
        _viewModel = StateObject(wrappedValue: viewModel())
        self.style = style
        
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            ZStack {
                
                trackBackground
                
                if style.showsTicks {
                    ticksOverlay
                }
                
                centerLine
                
                bubble
                    .animation(.interactiveSpring(response: 0.18, dampingFraction: 0.85), value: viewModel.rollDegrees)
                
            }
            .frame(width: style.width, height: style.height)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Horizontal level")
            .accessibilityValue(accessibilityValue)
            
            if style.showsReadout {
                readoutRow
                    .frame(width: style.width)
            }
            
            controlsRow
                .frame(width: style.width)
            
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        
    }
    
    private var trackBackground: some View {
        
        RoundedRectangle(cornerRadius: style.trackCornerRadius, style: .continuous)
            .fill(Color.primary.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: style.trackCornerRadius, style: .continuous)
                    .strokeBorder(viewModel.isLevel ? Color.green.opacity(1) : Color.primary.opacity(0.10), lineWidth: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: style.trackCornerRadius, style: .continuous)
                    .fill(viewModel.isLevel ? Color.green.opacity(0.15) : Color.clear)
            )
        
    }
    
    private var centerLine: some View {
        
        Rectangle()
            .fill(viewModel.isLevel ? Color.green.opacity(1) : Color.primary.opacity(0.35))
            .frame(width: 2)
        
    }
    
    private var ticksOverlay: some View {
        
        GeometryReader { proxy in
            
            let w = proxy.size.width
            let h = proxy.size.height
            
            // 5 ticks: -max, -half, 0, +half, +max
            let xs: [CGFloat] = [0.08, 0.30, 0.50, 0.70, 0.92].map { w * $0 }
            
            Path { path in
                
                for (idx, x) in xs.enumerated() {
                    
                    let isCenter = idx == 2
                    let tickHeight = isCenter ? h * 0.55 : h * 0.35
                    
                    path.move(to: .init(x: x, y: (h - tickHeight) * 0.5))
                    path.addLine(to: .init(x: x, y: (h + tickHeight) * 0.5))
                    
                }
                
            }
            .stroke(Color.primary.opacity(0.22), lineWidth: 1)
            
        }
        
    }
    
    private var bubble: some View {
        
        GeometryReader { proxy in
            
            let w = proxy.size.width
            let h = proxy.size.height
            
            let padding: CGFloat = 10
            let travel = max(0, (w - (padding * 2)) - style.bubbleSize)
            
            let maxDeg = max(1.0, viewModel.maxDisplayedDegrees)
            let roll = clamp(viewModel.rollDegrees, -maxDeg, maxDeg)
            let t = CGFloat((roll + maxDeg) / (maxDeg * 2.0)) // 0...1
            
            let x = padding + (travel * t)
            let y = (h - style.bubbleSize) * 0.5
            
            Circle()
                .fill(viewModel.isLevel ? Color.green.opacity(1) : Color.primary.opacity(1))
                .frame(width: style.bubbleSize, height: style.bubbleSize)
                .position(x: x + style.bubbleSize * 0.5,
                          y: y + style.bubbleSize * 0.5)
                .shadow(radius: viewModel.isLevel ? 6 : 2)
            
        }
        
    }
    
    private var readoutRow: some View {
        
        HStack(spacing: 10) {
            
            valuePill(title: "Roll", value: formatDegrees(viewModel.rollDegrees))
            
            Spacer(minLength: 0)
            
            Text(viewModel.isLevel ? "LEVEL" : "NOT LEVEL")
                .font(.system(size: 13, weight: .semibold))
                .opacity(viewModel.isLevel ? 1.0 : 0.55)
            
        }
        
    }
    
    private var controlsRow: some View {
        
        HStack(spacing: 10) {
            
            Button {
                viewModel.calibrate()
            } label: {
                Text("Calibrate")
            }
            
            Button {
                viewModel.resetCalibration()
            } label: {
                Text("Reset")
            }
            
            Spacer(minLength: 0)
            
            Button {
                viewModel.isRunning ? viewModel.stop() : viewModel.start()
            } label: {
                Text(viewModel.isRunning ? "Stop" : "Start")
            }
            
        }
        
    }
    
    private func valuePill(title: String, value: String) -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .opacity(0.65)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.06))
        )
        
    }
    
    private var accessibilityValue: String {
        "Roll \(formatDegreesForVoice(viewModel.rollDegrees))"
    }
    
    private func formatDegrees(_ value: Double) -> String {
        String(format: "%.1f°", value)
    }
    
    private func formatDegreesForVoice(_ value: Double) -> String {
        String(format: "%.1f degrees", value)
    }
    
    private func clamp(_ value: Double, _ minValue: Double, _ maxValue: Double) -> Double {
        min(max(value, minValue), maxValue)
    }
    
}

// MARK: - Preview

#Preview("HorizontalLevelView") {
    
    let service = NewLevelMotionServiceImpl()
    let vm = HorizontalLevelViewModel(
        service: service,
        config: .init(
            toleranceDegrees: 1.0,
            maxDisplayedDegrees: 12.0,
            updatesPerSecond: 60.0,
            hapticsEnabled: true
        )
    )
    
    return VStack(spacing: 18) {
        
        HorizontalLevelView(viewModel: vm, style: .init(width: 340, height: 56, bubbleSize: 22))
        
        HorizontalLevelView(viewModel: vm, style: .init(width: 340, height: 44, bubbleSize: 16, showsTicks: false, showsReadout: false))
        
    }
    .padding()
    
}
