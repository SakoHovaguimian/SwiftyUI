import SwiftUI

// MARK: - Pattern Definition

/// Defines the mask pattern used for the rotating border.
public enum BorderBeamPattern {
    case solid
    case singleBeam
    case dualBeam
    case quadBeam
    case custom([Gradient.Stop])
    
    var stops: [Gradient.Stop] {
        switch self {
        case .solid:
            return [.init(color: .white, location: 0)]
            
        case .singleBeam:
            return [
                .init(color: .clear, location: 0.0),
                .init(color: .white, location: 0.1),
                .init(color: .clear, location: 0.2)
            ]
            
        case .dualBeam:
            // The original logic
            return [
                .init(color: .clear, location: 0.0),
                .init(color: .white, location: 0.10),
                .init(color: .clear, location: 0.20),
                .init(color: .clear, location: 0.50),
                .init(color: .white, location: 0.60),
                .init(color: .clear, location: 0.70)
            ]
            
        case .quadBeam:
            return [
                .init(color: .clear, location: 0.0), .init(color: .white, location: 0.05), .init(color: .clear, location: 0.1),
                .init(color: .clear, location: 0.25), .init(color: .white, location: 0.30), .init(color: .clear, location: 0.35),
                .init(color: .clear, location: 0.5), .init(color: .white, location: 0.55), .init(color: .clear, location: 0.6),
                .init(color: .clear, location: 0.75), .init(color: .white, location: 0.80), .init(color: .clear, location: 0.85)
            ]
            
        case .custom(let stops):
            return stops
        }
    }
}

// MARK: - View Modifier

struct SimpleCornerBorder<S: ShapeStyle>: ViewModifier {
    
    // MARK: - Private Properties
    
    private let style: S
    private let radius: CGFloat
    private let thickness: CGFloat
    private let isAnimating: Bool
    
    // Configuration properties
    private let animation: Animation
    private let pattern: BorderBeamPattern
    
    // MARK: - Initializer
    
    /// Applies a rotating border with a masking effect to the view.
    public init(
        radius: CGFloat = 16,
        thickness: CGFloat = 4,
        style: S,
        animation: Animation = .linear(duration: 3).repeatForever(autoreverses: false),
        pattern: BorderBeamPattern = .dualBeam,
        isAnimating: Bool
    ) {
        self.radius = radius
        self.thickness = thickness
        self.style = style
        self.animation = animation
        self.pattern = pattern
        self.isAnimating = isAnimating
    }
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    let dimension = max(proxy.size.width, proxy.size.height) * 2
                   
                    RoundedRectangle(cornerRadius: radius)
                        .strokeBorder(style, lineWidth: thickness)
                        .mask {
                            AngularGradient(
                                stops: pattern.stops,
                                center: .center
                            )
                            .frame(width: dimension, height: dimension)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                        }
                }
            }
            .animation(
                isAnimating
                    ? animation
                    : .default,
                value: isAnimating
            )
    }
}

// MARK: - View Extension

extension View {
    
    /// Applies a customizable rotating corner border.
    func simpleCornerBorder<S: ShapeStyle>(
        radius: CGFloat = 16,
        thickness: CGFloat = 4,
        style: S,
        animation: Animation = .linear(duration: 3).repeatForever(autoreverses: false),
        pattern: BorderBeamPattern = .dualBeam, // New Enum Default
        isAnimating: Bool = false
    ) -> some View {
        self.modifier(
            SimpleCornerBorder(
                radius: radius,
                thickness: thickness,
                style: style,
                animation: animation,
                pattern: pattern,
                isAnimating: isAnimating
            )
        )
    }
}

// MARK: - Preview

struct SimpleExample: View {
    @State private var isSpinning = false
    
    var body: some View {
        VStack(spacing: 40) {
            
            CardViewCustom(title: "Dual Beam (Default)")
                .simpleCornerBorder(
                    style: .linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom),
                    pattern: .singleBeam,
                    isAnimating: isSpinning
                )
            
            // Example 1: Standard Dual Beam
            CardViewCustom(title: "Dual Beam (Default)")
                .simpleCornerBorder(
                    style: .linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom),
                    pattern: .dualBeam,
                    isAnimating: isSpinning
                )
            
            // Example 2: Quad Beam
            CardViewCustom(title: "Quad Beam")
                .simpleCornerBorder(
                    style: .linearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom),
                    pattern: .quadBeam,
                    isAnimating: isSpinning
                )

            // Example 3: Custom Pattern
            CardViewCustom(title: "Custom (Tiny Dot)")
                .simpleCornerBorder(
                    style: .green,
                    pattern: .custom([
                        .init(color: .clear, location: 0),
                        .init(color: .white, location: 0.01),
                        .init(color: .clear, location: 0.1),
                        .init(color: .clear, location: 0.2),
                        .init(color: .clear, location: 0.3),
                        .init(color: .clear, location: 0.9),
                        .init(color: .clear, location: 1.9),
                    ]),
                    isAnimating: isSpinning
                )
            
            Button("Spin") {
                isSpinning.toggle()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9))
    }
}

// Helper for preview cleanliness
struct CardViewCustom: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.white)
            .frame(width: 200, height: 100)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    SimpleExample()
}
