//
//  ConfettiViewNew.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 5/8/25.
//


import SwiftUI

public struct WNGConfettiView: View {
    
    // MARK: - Public Types
    
    public enum Mode {
        case loop
        case burst(duration: TimeInterval)
    }
    
    public enum ConfettiType: Hashable {
        
        case shape(ShapeType)
        
        public enum ShapeType {
            case circle
            case square
            case triangle
            case rectangle
        }
    }
    
    public struct ConfettiConfig {
        let num: Int
        let types: [ConfettiType]
        let colors: [Color]
        let size: CGFloat
        let rainHeight: CGFloat
        let fadesOut: Bool
        let opacity: Double
        let openingAngle: Angle
        let closingAngle: Angle
        let radius: CGFloat
        let intensity: Double
        
        public init(
            num: Int = 20,
            types: [ConfettiType] = [.shape(.circle), .shape(.square), .shape(.triangle)],
            colors: [Color] = [.green, .purple, .blue],
            size: CGFloat = 10.0,
            rainHeight: CGFloat = 600.0,
            fadesOut: Bool = true,
            opacity: Double = 1.0,
            openingAngle: Angle = .degrees(60),
            closingAngle: Angle = .degrees(120),
            radius: CGFloat = 300,
            intensity: Double = 0.8
        ) {
            self.num = num
            self.types = types
            self.colors = colors
            self.size = size
            self.rainHeight = rainHeight
            self.fadesOut = fadesOut
            self.opacity = opacity
            self.openingAngle = openingAngle
            self.closingAngle = closingAngle
            self.radius = radius
            self.intensity = intensity
        }
    }
    
    // MARK: - Public Properties
    
    @Binding private var isActive: Bool
    private let mode: Mode
    @StateObject private var confettiConfig: ConfettiConfigStore
    
    // MARK: - Private Properties
    
    @State private var animate: [Bool] = []
    @State private var finishedAnimationCounter = 0
    @State private var firstAppear = true
    @State private var timer: Timer?
    
    // MARK: - Initialization
    
    public init(
        isActive: Binding<Bool>,
        mode: Mode = .burst(duration: 3.0),
        config: ConfettiConfig = ConfettiConfig()
    ) {
        self._isActive = isActive
        self.mode = mode
        
        let confettiStore = ConfettiConfigStore(
            num: Int(Double(config.num) * config.intensity),
            types: config.types,
            colors: config.colors,
            confettiSize: config.size,
            rainHeight: config.rainHeight,
            fadesOut: config.fadesOut,
            opacity: config.opacity,
            openingAngle: config.openingAngle,
            closingAngle: config.closingAngle,
            radius: config.radius
        )
        
        self._confettiConfig = StateObject(wrappedValue: confettiStore)
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            ForEach(finishedAnimationCounter..<animate.count, id: \.self) { i in
                ConfettiContainer(
                    finishedAnimationCounter: $finishedAnimationCounter,
                    confettiConfig: confettiConfig
                )
            }
        }
        .onAppear {
            firstAppear = true
        }
        .onChange(of: isActive) { _, newValue in
            if newValue && firstAppear {
                startAnimation()
            } else if !newValue {
                stopAnimation()
            }
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    // MARK: - Private Methods
    
    private func startAnimation() {
        switch mode {
        case .burst(let duration):
            animate.append(false)
            playHapticFeedback()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.isActive = false
            }
            
        case .loop:
            // Start with initial burst
            animate.append(false)
            playHapticFeedback()
            
            // Schedule repeating bursts at intervals
            timer = Timer.scheduledTimer(withTimeInterval: confettiConfig.animationDuration * 0.8, repeats: true) { _ in
                if self.isActive {
                    animate.append(false)
                    playHapticFeedback()
                }
            }
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
    
    private func playHapticFeedback() {
        #if os(iOS) && !os(tvOS) && !os(visionOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
    }
}

// MARK: - Supporting Views

private struct ConfettiContainer: View {
    @Binding var finishedAnimationCounter: Int
    @ObservedObject var confettiConfig: ConfettiConfigStore
    @State var firstAppear = true
    
    var body: some View {
        ZStack {
            ForEach(0..<confettiConfig.num, id: \.self) { _ in
                ConfettiPiece(confettiConfig: confettiConfig)
            }
        }
        .onAppear {
            if firstAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + confettiConfig.animationDuration) {
                    self.finishedAnimationCounter += 1
                }
                firstAppear = false
            }
        }
    }
}

private struct ConfettiPiece: View {
    @State private var location = CGPoint(x: 0, y: 0)
    @State private var opacity = 0.0
    @ObservedObject var confettiConfig: ConfettiConfigStore
    
    // Random values for animation
    @State private var spinDirectionX = Bool.random() ? 1.0 : -1.0
    @State private var spinDirectionZ = Bool.random() ? 1.0 : -1.0
    @State private var xSpeed = Double.random(in: 0.5...2.2)
    @State private var zSpeed = Double.random(in: 0.5...2.2)
    @State private var distance: CGFloat = 0
    @State private var randomAngle: CGFloat = 0
    
    private func getRandomConfettiView() -> AnyView {
        let type = confettiConfig.types.randomElement()!
        let color = confettiConfig.colors.randomElement()!
        
        switch type {
        case .shape(let shapeType):
            switch shapeType {
            case .circle:
                return AnyView(Circle().fill(color).frame(width: confettiConfig.confettiSize, height: confettiConfig.confettiSize))
            case .square:
                return AnyView(Rectangle().fill(color).frame(width: confettiConfig.confettiSize, height: confettiConfig.confettiSize))
            case .triangle:
                return AnyView(Triangle().fill(color).frame(width: confettiConfig.confettiSize, height: confettiConfig.confettiSize))
            case .rectangle:
                return AnyView(Rectangle().fill(color).frame(width: confettiConfig.confettiSize * 1.5, height: confettiConfig.confettiSize * 0.5))
            }
//        case .image(let imageSource):
//            return AnyView(imageSource.view().foregroundColor(color).frame(width: confettiConfig.confettiSize, height: confettiConfig.confettiSize))
        }
    }
    
    private func getRandomExplosionTimeVariation() -> CGFloat {
        CGFloat.random(in: 0...0.5)
    }
    
    private func getAnimationDuration() -> CGFloat {
        return 0.2 + confettiConfig.explosionAnimationDuration + getRandomExplosionTimeVariation()
    }
    
    private func getAnimation() -> Animation {
        return Animation.timingCurve(0.1, 0.8, 0, 1, duration: getAnimationDuration())
    }
    
    private func getDistance() -> CGFloat {
        return pow(CGFloat.random(in: 0.01...1), 2.0/7.0) * confettiConfig.radius
    }
    
    private func getDelayBeforeRainAnimation() -> TimeInterval {
        confettiConfig.explosionAnimationDuration * 0.1
    }
    
    private func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * CGFloat.pi / 180
    }
    
    var body: some View {
        getRandomConfettiView()
            .rotation3DEffect(.degrees(xSpeed * 360), axis: (x: spinDirectionX, y: 0, z: 0))
            .animation(Animation.linear(duration: xSpeed).repeatCount(10, autoreverses: false), value: location.y)
            .rotation3DEffect(.degrees(zSpeed * 360), axis: (x: 0, y: 0, z: spinDirectionZ))
            .animation(Animation.linear(duration: zSpeed).repeatForever(autoreverses: false), value: location.y)
            .offset(x: location.x, y: location.y)
            .opacity(opacity)
            .onAppear {
                // Calculate random properties
                distance = getDistance()
                
                if confettiConfig.openingAngle.degrees <= confettiConfig.closingAngle.degrees {
                    randomAngle = CGFloat.random(in: CGFloat(confettiConfig.openingAngle.degrees)...CGFloat(confettiConfig.closingAngle.degrees))
                } else {
                    randomAngle = CGFloat.random(in: CGFloat(confettiConfig.openingAngle.degrees)...CGFloat(confettiConfig.closingAngle.degrees + 360)).truncatingRemainder(dividingBy: 360)
                }
                
                // Start explosion animation
                withAnimation(getAnimation()) {
                    opacity = confettiConfig.opacity
                    location.x = distance * cos(deg2rad(randomAngle))
                    location.y = -distance * sin(deg2rad(randomAngle))
                }
                
                // Start falling animation after explosion
                DispatchQueue.main.asyncAfter(deadline: .now() + getDelayBeforeRainAnimation()) {
                    withAnimation(Animation.timingCurve(0.12, 0, 0.39, 0, duration: confettiConfig.rainAnimationDuration)) {
                        location.y += confettiConfig.rainHeight
                        opacity = confettiConfig.fadesOut ? 0 : confettiConfig.opacity
                    }
                }
            }
    }
}

// MARK: - Supporting Types

private class ConfettiConfigStore: ObservableObject {
    @Published var num: Int
    @Published var types: [WNGConfettiView.ConfettiType]
    @Published var colors: [Color]
    @Published var confettiSize: CGFloat
    @Published var rainHeight: CGFloat
    @Published var fadesOut: Bool
    @Published var opacity: Double
    @Published var openingAngle: Angle
    @Published var closingAngle: Angle
    @Published var radius: CGFloat
    @Published var explosionAnimationDuration: Double
    @Published var rainAnimationDuration: Double
    
    var animationDuration: Double {
        return explosionAnimationDuration + rainAnimationDuration
    }
    
    init(
        num: Int,
        types: [WNGConfettiView.ConfettiType],
        colors: [Color],
        confettiSize: CGFloat,
        rainHeight: CGFloat,
        fadesOut: Bool,
        opacity: Double,
        openingAngle: Angle,
        closingAngle: Angle,
        radius: CGFloat
    ) {
        self.num = num
        self.types = types
        self.colors = colors
        self.confettiSize = confettiSize
        self.rainHeight = rainHeight
        self.fadesOut = fadesOut
        self.opacity = opacity
        self.openingAngle = openingAngle
        self.closingAngle = closingAngle
        self.radius = radius
        self.explosionAnimationDuration = Double(radius / 1300)
        self.rainAnimationDuration = Double((rainHeight + radius) / 200)
    }
}

// MARK: - Custom Shape Extensions

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

import SwiftUI

struct ContentView10: View {
    @State private var showConfetti: Bool = false
    
    var body: some View {
        ZStack {
            
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("WNG Confetti Demo")
                    .font(.largeTitle)
                    .padding()
                
                Button("Burst Confetti") {
                    showConfetti = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Stop Confetti") {
                    showConfetti = false
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Default burst confetti
            WNGConfettiView(
                isActive: $showConfetti,
                mode: .loop,
                config: WNGConfettiView.ConfettiConfig(
                    num: 100,
                    types: [
                        .shape(.circle),
                        .shape(.square),
                        .shape(.triangle),
                    ],
                    colors: [.red, .blue, .green, .yellow, .purple],
                    size: 12.0,
                    rainHeight: 23,
                    fadesOut: false,
                    intensity: 0.5
                )
            )
            
            // Or for a looping confetti effect:
            /*
            WNGConfettiView(
                isActive: $showConfetti,
                mode: .loop
            )
            */
            
            // Custom confetti:
            /*
            WNGConfettiView(
                isActive: $showConfetti,
                mode: .burst(duration: 5.0),
                config: WNGConfettiView.ConfettiConfig(
                    num: 30,
                    types: [
                        .shape(.circle),
                        .shape(.triangle),
                        .shape(.square),
                        // Add images if you have an ImageSource implementation:
                        // .image(WNGImage.illustration(.confetti))
                    ],
                    colors: [
                        .red, .blue, .green, .yellow, .purple
                    ],
                    size: 12.0,
                    rainHeight: 700,
                    intensity: 1.0
                )
            )
            */
        }
    }
}

#Preview {
    
    ContentView10()
    
}
