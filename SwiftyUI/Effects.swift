//
//  Effects.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/17/25.
//

import SwiftUI

// MARK: – Pop Modifier
public struct PopModifier: AnimatableModifier {
    public var animatableData: CGFloat
    public var scaleMagnitude: CGFloat = 1.2
    public func body(content: Content) -> some View {
        let reduced = animatableData - floor(animatableData)
        let progress = 1 - (cos(2 * .pi * Double(reduced)) + 1) / 2
        let scale = 1 + (scaleMagnitude - 1) * CGFloat(progress)
        return content.scaleEffect(scale)
    }
}
public extension View {
    func popEffect(_ value: CGFloat, magnitude: CGFloat = 1.2) -> some View {
        modifier(PopModifier(animatableData: value, scaleMagnitude: magnitude))
    }
}

// MARK: – Bounce Modifier
public struct BounceModifier: AnimatableModifier {
    public var animatableData: CGFloat
    public var amplitude: CGFloat = 20
    public var frequency: CGFloat = 2
    public func body(content: Content) -> some View {
        let offsetY = -abs(sin(animatableData * .pi * frequency)) * amplitude
        return content.offset(x: 0, y: offsetY)
    }
}
public extension View {
    func bounceEffect(_ value: CGFloat, amplitude: CGFloat = 20, frequency: CGFloat = 2) -> some View {
        modifier(BounceModifier(animatableData: value, amplitude: amplitude, frequency: frequency))
    }
}

// MARK: – Wobble Modifier
public struct WobbleModifier: AnimatableModifier {
    public var animatableData: CGFloat
    public var amplitude: CGFloat = 10
    public var shakesPerUnit: CGFloat = 3
    public func body(content: Content) -> some View {
        let angle = sin(animatableData * .pi * shakesPerUnit) * amplitude * .pi / 180
        return content.rotationEffect(.radians(Double(angle)))
    }
}
public extension View {
    func wobbleEffect(_ value: CGFloat, amplitude: CGFloat = 10, shakesPerUnit: CGFloat = 3) -> some View {
        modifier(WobbleModifier(animatableData: value, amplitude: amplitude, shakesPerUnit: shakesPerUnit))
    }
}

// MARK: – Pulse Color Modifier
public struct PulseColorModifier: AnimatableModifier {
    public var animatableData: Double
    public var fromColor: Color = .red
    public var toColor: Color = .pink
    public func body(content: Content) -> some View {
        let t = (sin(animatableData * .pi * 2) + 1) / 2
        let color = fromColor.interpolate(to: toColor, fraction: t)
        return content.foregroundColor(color)
    }
}
public extension Color {
    func interpolate(to: Color, fraction: Double) -> Color {
        let c1 = UIColor(self).cgColor.components ?? [0,0,0,1]
        let c2 = UIColor(to).cgColor.components ?? [0,0,0,1]
        return Color(
            red: Double(c1[0] + (c2[0] - c1[0]) * CGFloat(fraction)),
            green: Double(c1[1] + (c2[1] - c1[1]) * CGFloat(fraction)),
            blue: Double(c1[2] + (c2[2] - c1[2]) * CGFloat(fraction)),
            opacity: Double(c1[3] + (c2[3] - c1[3]) * CGFloat(fraction))
        )
    }
}
public extension View {
    func pulseColorEffect(_ value: Double, from: Color = .red, to: Color = .pink) -> some View {
        modifier(PulseColorModifier(animatableData: value, fromColor: from, toColor: to))
    }
}

// MARK: – Tilt 3D Modifier
public struct Tilt3DModifier: AnimatableModifier {
    public var animatableData: CGFloat
    public var axis: (x: CGFloat, y: CGFloat, z: CGFloat) = (x: 1, y: 0, z: 0)
    public func body(content: Content) -> some View {
        let angle = Angle(degrees: Double(animatableData) * 360)
        return content.rotation3DEffect(angle, axis: axis)
    }
}
public extension View {
    func tilt3DEffect(_ value: CGFloat, axis: (x: CGFloat, y: CGFloat, z: CGFloat) = (1,0,0)) -> some View {
        modifier(Tilt3DModifier(animatableData: value, axis: axis))
    }
}

// MARK: – Typewriter Text Modifier
public struct TypewriterModifier: AnimatableModifier {
    public var animatableData: CGFloat
    public func body(content: Content) -> some View {
        content.mask(
            GeometryReader { proxy in
                Rectangle()
                    .frame(width: proxy.size.width * animatableData, height: proxy.size.height)
                    .alignmentGuide(.leading) { _ in 0 }
            }
        )
    }
}
public extension View {
    func typewriterEffect(_ progress: CGFloat) -> some View {
        modifier(TypewriterModifier(animatableData: progress))
    }
}

// MARK: – Blur Pulse Modifier
public struct BlurPulseModifier: AnimatableModifier {
    public var animatableData: CGFloat
    public var maxRadius: CGFloat = 10
    public func body(content: Content) -> some View {
        let radius = abs(sin(animatableData * .pi * 2)) * maxRadius
        return content.blur(radius: radius)
    }
}
public extension View {
    func blurPulseEffect(_ value: CGFloat, maxRadius: CGFloat = 10) -> some View {
        modifier(BlurPulseModifier(animatableData: value, maxRadius: maxRadius))
    }
}

// MARK: – Wrapper Enum
public enum AppAnimationEffect {
    case pop(value: CGFloat, magnitude: CGFloat)
    case bounce(value: CGFloat, amplitude: CGFloat, frequency: CGFloat)
    case wobble(value: CGFloat, amplitude: CGFloat, shakes: CGFloat)
    case pulseColor(value: Double, from: Color, to: Color)
    case tilt3D(value: CGFloat, axisX: CGFloat, axisY: CGFloat, axisZ: CGFloat)
    case typewriter(progress: CGFloat)
    case blurPulse(value: CGFloat, maxRadius: CGFloat)
}
public extension View {
    @ViewBuilder
    func apply(effect: AppAnimationEffect) -> some View {
        switch effect {
        case let .pop(v, m): self.popEffect(v, magnitude: m)
        case let .bounce(v, a, f): self.bounceEffect(v, amplitude: a, frequency: f)
        case let .wobble(v, a, s): self.wobbleEffect(v, amplitude: a, shakesPerUnit: s)
        case let .pulseColor(v, from, to): self.pulseColorEffect(v, from: from, to: to)
        case let .tilt3D(v, x, y, z): self.tilt3DEffect(v, axis: (x: x, y: y, z: z))
        case let .typewriter(p): self.typewriterEffect(p)
        case let .blurPulse(v, r): self.blurPulseEffect(v, maxRadius: r)
        }
    }
}

// MARK: – Demo Preview
struct EffectDemoAllView: View {
    @State private var pop: CGFloat = 0
    @State private var bounce: CGFloat = 0
    @State private var wobble: CGFloat = 0
    @State private var pulse: Double = 0
    @State private var tilt: CGFloat = 0
    @State private var type: CGFloat = 0
    @State private var blur: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Text("Pop")
                    .font(.headline)
                    .popEffect(pop)
                    .onTapGesture { withAnimation(.easeInOut(duration: 0.6)) { pop += 1 } }

                Text("Bounce")
                    .font(.headline)
                    .bounceEffect(bounce, amplitude: 10)
                    .onTapGesture { withAnimation(.snappy(duration: 1)) { bounce += 1 } }

                Text("Wobble")
                    .font(.headline)
                    .wobbleEffect(wobble)
                    .onTapGesture { withAnimation(.linear(duration: 0.4)) { wobble += 1 } }

                Text("Pulse Color")
                    .font(.headline)
                    .pulseColorEffect(pulse, from: .blue, to: .green)
                    .onAppear { withAnimation(.linear(duration: 1).repeatForever(autoreverses: true)) { pulse += 1 } }

                Text("Tilt 3D")
                    .font(.headline)
                    .tilt3DEffect(tilt, axis: (x: 1, y: 1, z: 0))
                    .onAppear { withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { tilt = 1 } }

                // REMOVE THIS. NEEDS TO BE CHARACTR BASED NOT SCOPE BASED
                Text("Typewriter Effect This is a long sentence to try and make it work character by character")
                    .font(.headline)
                    .typewriterEffect(type)
                    .onTapGesture { withAnimation(.linear(duration: 0.4)) { type = type == 1 ? 0 : 1 } }

                // REMOVE THIS
                Text("Blur Pulse")
                    .font(.headline)
                    .blurPulseEffect(blur)
                    .onAppear { withAnimation(.easeInOut(duration: 1)) { blur = 1 } }
                    .onTapGesture { withAnimation(.linear(duration: 0.4)) { blur = blur == 1 ? 0 : 1 } }
            }
            .padding()
        }
    }
}

struct EffectDemoAllView_Previews: PreviewProvider {
    static var previews: some View {
        EffectDemoAllView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
