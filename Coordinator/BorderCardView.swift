import SwiftUI

struct SimpleCornerBorder<S: ShapeStyle>: ViewModifier {
    
    // MARK: - Private Properties
    
    private let style: S
    private let radius: CGFloat
    private let thickness: CGFloat
    private let isAnimating: Bool
    
    // Configuration properties
    private let animation: Animation
    private let gradientStops: [Gradient.Stop]?
    
    // MARK: - Initializer
    
    /// Applies a rotating border with a masking effect to the view.
    ///
    /// - Parameters:
    ///   - radius: The corner radius of the border. Defaults to `16`.
    ///   - thickness: The line width of the border. Defaults to `4`.
    ///   - style: The shape style (color or gradient) to apply to the border.
    ///   - animation: The animation the border follows. Defaults to  `.linear(duration: 3).repeatForever(autoreverses: false)`
    ///   - gradientStops: Custom gradient stops for the mask. If `nil`, uses the default "dual-beam" pattern.
    ///   - isAnimating: Controls whether the border rotation animation is active.
    public init(
        radius: CGFloat = 16,
        thickness: CGFloat = 4,
        style: S,
        animation: Animation = .linear(duration: 3).repeatForever(autoreverses: false),
        gradientStops: [Gradient.Stop]? = nil,
        isAnimating: Bool
    ) {
        self.radius = radius
        self.thickness = thickness
        self.style = style
        self.animation = animation
        self.gradientStops = gradientStops
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
                                stops: currentGradientStops,
                                center: .center
                            )
                            .frame(width: dimension, height: dimension)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                        }
                }
            }
            // TODO: - Add configuration for Animation Curve (e.g., .easeInOut vs .linear)
            .animation(
                isAnimating
                    ? animation
                    : .default,
                value: isAnimating
            )
    }
    
    // MARK: - Helpers
    
    private var currentGradientStops: [Gradient.Stop] {
        // TODO: - Create a static preset enum for different beam patterns (e.g. .singleBeam, .quadBeam)
        if let customStops = gradientStops {
            return customStops
        }
        
        // Default "Dual Beam" Pattern
        return [
            .init(color: .clear, location: 0.0),
            .init(color: .white, location: 0.10),
            .init(color: .clear, location: 0.20),
            .init(color: .clear, location: 0.50),
            .init(color: .white, location: 0.60),
            .init(color: .clear, location: 0.70)
        ]
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
        gradientStops: [Gradient.Stop]? = nil,
        isAnimating: Bool = false
    ) -> some View {
        self.modifier(
            SimpleCornerBorder(
                radius: radius,
                thickness: thickness,
                style: style,
                animation: animation,
                gradientStops: gradientStops,
                isAnimating: isAnimating
            )
        )
    }
}

// MARK: - Preview

struct SimpleExample: View {
    @State private var isSpinning = false
    
    var body: some View {
        VStack {
            Text("Investments")
                .font(.headline)
                .frame(width: 300, height: 500)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .simpleCornerBorder(
                    radius: 20,
                    thickness: 4,
                    style: LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    isAnimating: isSpinning
                )
            
            Button("Spin") {
                isSpinning.toggle()
            }
            .padding(.top, 50)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

#Preview {
    SimpleExample()
}
