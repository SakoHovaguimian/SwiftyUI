//
//  FireworksModifier.swift
//  YourApp
//
//  Created by You on 12/18/25.
//

import SwiftUI

// *********************************
// MARK: - Public API
// *********************************

public struct FireworksConfiguration {
    
    public var particleCount: Int
    public var lifetime: TimeInterval
    public var maxParticleDelay: TimeInterval
    
    public var speed: ClosedRange<CGFloat>
    public var gravity: CGVector
    public var velocityDampingPerSecond: CGFloat
    
    public var size: ClosedRange<CGFloat>
    public var particleSource: FireworksParticleSource
    
    public var fadeOutFraction: Double
    public var twinkleStrength: Double
    
    public var fps: Double
    public var blendMode: BlendMode
    
    public init(particleCount: Int = 140,
                lifetime: TimeInterval = 1.8,
                maxParticleDelay: TimeInterval = 0.12,
                speed: ClosedRange<CGFloat> = 180...520,
                gravity: CGVector = .init(dx: 0, dy: 720),
                velocityDampingPerSecond: CGFloat = 0.90,
                size: ClosedRange<CGFloat> = 2...7,
                particleSource: FireworksParticleSource = .colors([
                    .red, .orange, .yellow, .pink, .purple, .blue, .mint
                ]),
                fadeOutFraction: Double = 0.35,
                twinkleStrength: Double = 0.25,
                fps: Double = 60,
                blendMode: BlendMode = .plusLighter) {
        
        self.particleCount = particleCount
        self.lifetime = lifetime
        self.maxParticleDelay = maxParticleDelay
        
        self.speed = speed
        self.gravity = gravity
        self.velocityDampingPerSecond = velocityDampingPerSecond
        
        self.size = size
        self.particleSource = particleSource
        
        self.fadeOutFraction = fadeOutFraction
        self.twinkleStrength = twinkleStrength
        
        self.fps = fps
        self.blendMode = blendMode
        
    }
    
}

public enum FireworksOrigin: Equatable {
    
    case center
    case unit(UnitPoint)
    case point(CGPoint)
    
    fileprivate func resolve(in rect: CGRect) -> CGPoint {
        
        switch self {
        case .center:
            return CGPoint(x: rect.midX, y: rect.midY)
            
        case .unit(let unit):
            return CGPoint(x: rect.minX + rect.width * unit.x,
                           y: rect.minY + rect.height * unit.y)
            
        case .point(let point):
            return point
        }
        
    }
    
}

// *********************************
// MARK: - Particle Sources
// *********************************

public enum FireworksParticleSource {
    
    case colors([Color])
    case images([Image])
    case shapes([AnyFireworksShape], fill: Color = .white)
    case mixed([FireworksParticleAsset])
    
    fileprivate var assets: [FireworksParticleAsset] {
        
        switch self {
        case .colors(let colors):
            return colors.map { .color($0) }
            
        case .images(let images):
            return images.map { .image($0) }
            
        case .shapes(let shapes, let fill):
            return shapes.map { .shape($0, fill: fill) }
            
        case .mixed(let assets):
            return assets
        }
        
    }
    
    fileprivate var safeAssets: [FireworksParticleAsset] {
        
        let resolved = assets
        return resolved.isEmpty ? [.color(.white)] : resolved
        
    }
    
}

public enum FireworksParticleAsset {
    case color(Color)
    case image(Image)
    case shape(AnyFireworksShape, fill: Color)
}

public struct AnyFireworksShape {
    
    private let builder: (CGRect) -> Path
    
    public init<S: Shape>(_ shape: S) {
        self.builder = { rect in
            shape.path(in: rect)
        }
    }
    
    fileprivate func path(in rect: CGRect) -> Path {
        builder(rect)
    }
    
}

public extension Shape {
    
    func asFireworksShape() -> AnyFireworksShape {
        AnyFireworksShape(self)
    }
    
}

// *********************************
// MARK: - View Extension
// *********************************

public extension View {
    
    func fireworks<T: Equatable>(trigger: T,
                                 configuration: FireworksConfiguration = .init(),
                                 origin: FireworksOrigin = .center) -> some View {
        
        self.modifier(FireworksViewModifier(
            trigger: trigger,
            configuration: configuration,
            origin: origin
        ))
        
    }
    
    /// Convenience: pass a Bool binding and this will auto-reset to false after firing.
    /// Good for "one-shot" triggers without managing counters.
    func fireworks(isTriggered: Binding<Bool>,
                   configuration: FireworksConfiguration = .init(),
                   origin: FireworksOrigin = .center,
                   resetDelay: TimeInterval = 0.05) -> some View {
        
        self.modifier(FireworksBoolTriggerViewModifier(
            isTriggered: isTriggered,
            configuration: configuration,
            origin: origin,
            resetDelay: resetDelay
        ))
        
    }
    
}

// *********************************
// MARK: - Modifier (Equatable Trigger)
// *********************************

fileprivate struct FireworksViewModifier<T: Equatable>: ViewModifier {
    
    private let trigger: T
    private let configuration: FireworksConfiguration
    private let origin: FireworksOrigin
    
    @State private var bursts: [Burst] = []
    
    init(trigger: T,
         configuration: FireworksConfiguration,
         origin: FireworksOrigin) {
        
        self.trigger = trigger
        self.configuration = configuration
        self.origin = origin
        
    }
    
    func body(content: Content) -> some View {
        
        content
            .overlay {
                FireworksOverlayView(
                    bursts: bursts,
                    configuration: configuration,
                    origin: origin
                )
            }
            .onChange(of: trigger) { _, _ in
                launchBurst()
            }
        
    }
    
    // *********************************
    // MARK: - Burst lifecycle
    // *********************************
    
    private func launchBurst() {
        
        let now = Date()
        let burst = Burst(
            createdAt: now,
            particles: makeParticles()
        )
        
        bursts.append(burst)
        scheduleCleanup()
        
    }
    
    private func scheduleCleanup() {
        
        let cleanupDelay = configuration.lifetime + configuration.maxParticleDelay + 0.35
        
        Task { @MainActor in
            
            try? await Task.sleep(nanoseconds: UInt64(cleanupDelay * 1_000_000_000))
            pruneBursts()
            
        }
        
    }
    
    private func pruneBursts() {
        
        let now = Date()
        let cutoff = configuration.lifetime + configuration.maxParticleDelay + 0.25
        
        bursts.removeAll { burst in
            now.timeIntervalSince(burst.createdAt) > cutoff
        }
        
    }
    
    // *********************************
    // MARK: - Particle generation
    // *********************************
    
    private func makeParticles() -> [Particle] {
        
        let assets = configuration.particleSource.safeAssets
        
        var result: [Particle] = []
        result.reserveCapacity(configuration.particleCount)
        
        for _ in 0..<configuration.particleCount {
            
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: configuration.speed)
            
            let vx = cos(angle) * speed
            let vy = sin(angle) * speed
            
            let particle = Particle(
                velocity: .init(dx: vx, dy: vy),
                assetIndex: Int.random(in: 0..<assets.count),
                size: CGFloat.random(in: configuration.size),
                delay: Double.random(in: 0...configuration.maxParticleDelay),
                seed: Double.random(in: 0...1000)
            )
            
            result.append(particle)
            
        }
        
        return result
        
    }
    
}

// *********************************
// MARK: - Modifier (Bool Trigger)
// *********************************

fileprivate struct FireworksBoolTriggerViewModifier: ViewModifier {
    
    @Binding private var isTriggered: Bool
    
    private let configuration: FireworksConfiguration
    private let origin: FireworksOrigin
    private let resetDelay: TimeInterval
    
    @State private var token: Int = 0
    
    init(isTriggered: Binding<Bool>,
         configuration: FireworksConfiguration,
         origin: FireworksOrigin,
         resetDelay: TimeInterval) {
        
        self._isTriggered = isTriggered
        self.configuration = configuration
        self.origin = origin
        self.resetDelay = resetDelay
        
    }
    
    func body(content: Content) -> some View {
        
        content
            .fireworks(
                trigger: token,
                configuration: configuration,
                origin: origin
            )
            .onChange(of: isTriggered) { _, newValue in
                
                guard newValue else { return }
                
                token += 1
                resetTrigger()
                
            }
        
    }
    
    private func resetTrigger() {
        
        Task { @MainActor in
            
            try? await Task.sleep(nanoseconds: UInt64(resetDelay * 1_000_000_000))
            isTriggered = false
            
        }
        
    }
    
}

// *********************************
// MARK: - Overlay Rendering
// *********************************

fileprivate struct FireworksOverlayView: View {
    
    let bursts: [Burst]
    let configuration: FireworksConfiguration
    let origin: FireworksOrigin
    
    var body: some View {
        
        GeometryReader { proxy in
            
            TimelineView(.animation(minimumInterval: 1.0 / max(configuration.fps, 15))) { timeline in
                
                Canvas { context, size in
                    
                    let rect = CGRect(origin: .zero, size: size)
                    let originPoint = origin.resolve(in: rect)
                    
                    for burst in bursts {
                        drawBurst(
                            burst,
                            in: &context,
                            canvasSize: size,
                            origin: originPoint,
                            now: timeline.date
                        )
                    }
                    
                }
                .blendMode(configuration.blendMode)
                
            }
            
        }
        .allowsHitTesting(false)
        
    }
    
    // *********************************
    // MARK: - Drawing
    // *********************************
    
    private func drawBurst(_ burst: Burst,
                           in context: inout GraphicsContext,
                           canvasSize: CGSize,
                           origin: CGPoint,
                           now: Date) {
        
        let assets = configuration.particleSource.safeAssets
        let elapsed = now.timeIntervalSince(burst.createdAt)
        
        for particle in burst.particles {
            
            let t = elapsed - particle.delay
            
            if t <= 0 { continue }
            if t >= configuration.lifetime { continue }
            
            let progress = t / configuration.lifetime
            
            let damping = pow(
                max(min(configuration.velocityDampingPerSecond, 1), 0.001),
                CGFloat(t)
            )
            
            let x = origin.x
                + (particle.velocity.dx * CGFloat(t) * damping)
                + (configuration.gravity.dx * CGFloat(0.5 * t * t))
            
            let y = origin.y
                + (particle.velocity.dy * CGFloat(t) * damping)
                + (configuration.gravity.dy * CGFloat(0.5 * t * t))
            
            let alpha = particleAlpha(progress: progress,
                                      t: t,
                                      seed: particle.seed)
            
            if alpha <= 0 { continue }
            
            let rect = CGRect(
                x: x - particle.size * 0.5,
                y: y - particle.size * 0.5,
                width: particle.size,
                height: particle.size
            )
            
            context.opacity = alpha
            
            let safeIndex = min(particle.assetIndex, assets.count - 1)
            let asset = assets[safeIndex]
            
            drawAsset(asset,
                      in: &context,
                      rect: rect)
            
        }
        
        context.opacity = 1
        
    }
    
    private func drawAsset(_ asset: FireworksParticleAsset,
                           in context: inout GraphicsContext,
                           rect: CGRect) {
        
        switch asset {
        case .color(let color):
            context.fill(
                Path(ellipseIn: rect),
                with: .color(color)
            )
            
        case .image(let image):
            context.draw(image, in: rect)
            
        case .shape(let shape, let fill):
            context.fill(
                shape.path(in: rect),
                with: .color(fill)
            )
        }
        
    }
    
    private func particleAlpha(progress: Double,
                               t: Double,
                               seed: Double) -> Double {
        
        let fadeStart = max(0, 1.0 - configuration.fadeOutFraction)
        
        let baseAlpha: Double
        if progress <= fadeStart {
            baseAlpha = 1
        } else {
            let local = (progress - fadeStart) / max(0.0001, (1.0 - fadeStart))
            baseAlpha = 1.0 - smoothstep(local)
        }
        
        if configuration.twinkleStrength <= 0 { return baseAlpha }
        
        let twinkle = (sin((t * 16) + seed) * 0.5 + 0.5)
        let twinkleAlpha = 1.0 - (configuration.twinkleStrength * (1.0 - twinkle))
        
        return max(0, min(1, baseAlpha * twinkleAlpha))
        
    }
    
    private func smoothstep(_ x: Double) -> Double {
        
        let t = max(0, min(1, x))
        return t * t * (3 - 2 * t)
        
    }
    
}

// *********************************
// MARK: - Models
// *********************************

fileprivate struct Burst: Identifiable {
    let id = UUID()
    let createdAt: Date
    let particles: [Particle]
}

fileprivate struct Particle: Identifiable {
    
    let id = UUID()
    
    let velocity: CGVector
    let assetIndex: Int
    let size: CGFloat
    
    let delay: TimeInterval
    let seed: Double
    
}

// *********************************
// MARK: - Previews
// *********************************

fileprivate struct FireworksPreviewScaffold: View {
    
    let title: String
    let subtitle: String
    
    let configuration: FireworksConfiguration
    let origin: FireworksOrigin
    
    @State private var token: Int = 0
    @State private var oneShot: Bool = false
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                
                Button("Fire (Token)") {
                    token += 1
                }
                .buttonStyle(.borderedProminent)
                
                Button("Fire (Bool)") {
                    oneShot = true
                }
                .buttonStyle(.bordered)
                
            }
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 18)
                .fill(.thinMaterial)
                .overlay {
                    VStack(spacing: 6) {
                        Text("Tap buttons above")
                            .font(.headline)
                        Text("Overlay is non-interactive")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 180)
            
            Spacer()
            
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            LinearGradient(
                colors: [
                    Color.black.opacity(0.85),
                    Color.black.opacity(0.65),
                    Color.black.opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
        .fireworks(
            trigger: token,
            configuration: configuration,
            origin: origin
        )
        .fireworks(
            isTriggered: $oneShot,
            configuration: configuration,
            origin: origin
        )
        
    }
    
}

#Preview("1) Colors - Center") {
    
    FireworksPreviewScaffold(
        title: "Colors",
        subtitle: "ParticleSource.colors(...) • origin: .center",
        configuration: .init(
            particleCount: 160, particleSource: .colors([.indigo, .mint, .white, .pink, .purple])
        ),
        origin: .center
    )
    
}

#Preview("2) Images - Center") {
    
    FireworksPreviewScaffold(
        title: "Images",
        subtitle: "ParticleSource.images(...) • origin: .center",
        configuration: .init(
            particleCount: 2,
            size: 64...72,
            particleSource: .images([
                Image(systemName: "sparkle"),
                Image(systemName: "star.fill"),
                Image(systemName: "circle.fill"),
                Image(systemName: "hexagon.fill")
            ])
        ),
        origin: .center
    )
    
}

#Preview("3) Shapes - Bottom") {
    
    FireworksPreviewScaffold(
        title: "Shapes",
        subtitle: "ParticleSource.shapes(...) • origin: .unit(.bottom)",
        configuration: .init(
            particleCount: 6, speed: 220...620, gravity: .init(dx: 0, dy: 980), size: 65...72, particleSource: .shapes([
                Circle().asFireworksShape(),
                RoundedRectangle(cornerRadius: 4).asFireworksShape(),
                Capsule().asFireworksShape()
            ], fill: .yellow)
        ),
        origin: .unit(.bottom)
    )
    
}

#Preview("4) Mixed - Top Leading") {
    
    FireworksPreviewScaffold(
        title: "Mixed",
        subtitle: "colors + images + shapes • origin: .unit(.topLeading)",
        configuration: .init(
            particleCount: 170, speed: 160...460, gravity: .init(dx: 0, dy: 640), particleSource: .mixed([
                .color(.mint),
                .color(.indigo),
                .image(Image(systemName: "sparkle")),
                .image(Image(systemName: "star.fill")),
                .shape(Circle().asFireworksShape(), fill: .white)
            ]),
            twinkleStrength: 0.45
        ),
        origin: .unit(.init(x: 0.22, y: 0.25))
    )
    
}

#Preview("5) Faster / Smaller - Right") {
    
    FireworksPreviewScaffold(
        title: "Fast + Tight",
        subtitle: "High fps, low lifetime, smaller size • origin: .unit(.trailing)",
        configuration: .init(
            particleCount: 110,
            lifetime: 1.1,
            maxParticleDelay: 0.06,
            speed: 220...720,
            gravity: .init(dx: 0, dy: 820),
            velocityDampingPerSecond: 0.86,
            size: 1.5...4.5,
            particleSource: .colors([.white, .yellow, .orange, .pink]),
            fadeOutFraction: 0.45,
            twinkleStrength: 0.15,
            fps: 90,
            blendMode: .plusLighter
        ),
        origin: .unit(.trailing)
    )
    
}
