import SwiftUI

// 1. The Clean, Reusable Main View
struct DynamicDottedLineView: View {
    var body: some View {
        VStack(spacing: 40) {
            
            // Look how incredibly clean this is now!
            
            // Static Horizontal Line
            SmartDottedLine(axis: .horizontal, color: .gray, isAnimated: false)
            
            // Animated Horizontal Line
            SmartDottedLine(axis: .horizontal, lineWidth: 6, dashLength: 15, color: .blue)
            
            // Animated Vertical Lines in an HStack to show dynamic height
            HStack(spacing: 50) {
                SmartDottedLine(axis: .vertical, lineWidth: 3, dashLength: 10, color: .secondary)
                SmartDottedLine(axis: .vertical, lineWidth: 5, dashLength: 20, color: .green)
            }
            .frame(height: 150) // The vertical lines will naturally stretch to fill this container
            
            // Circle Border
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [0, 20]))
                .foregroundColor(.orange)
                .frame(width: 100, height: 100)
            
        }
        .padding(24)
        
    }
    
}

// 2. The Smart Wrapper Component
struct SmartDottedLine: View {
    enum Axis { case horizontal, vertical }
    var axis: Axis
    
    // Configurable defaults
    var lineWidth: CGFloat = 4
    var dashLength: CGFloat = 15
    var color: Color = .blue
    var isAnimated: Bool = true
    var animationSpeed: TimeInterval = 0.5
    
    @State private var phase: CGFloat = 0
    
    var body: some View {
        DottedLineShape(axis: axis)
            .stroke(
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    dash: [0, dashLength],
                    dashPhase: phase
                )
            )
            .foregroundColor(color)
            // THE FIX: Dynamic framing based on the axis.
            // It expands infinitely along its length, but tightly hugs its exact lineWidth.
            .frame(
                maxWidth: axis == .horizontal ? .infinity : lineWidth,
                maxHeight: axis == .vertical ? .infinity : lineWidth
            )
            // Because the frame perfectly matches the lineWidth, clipped() will never cut off the stroke's thickness.
            .clipped()
            .onAppear {
                if isAnimated {
                    withAnimation(.linear(duration: animationSpeed).repeatForever(autoreverses: false)) {
                        phase = -dashLength
                    }
                }
            }
    }
}

// 3. The Underlying Runway Shape
struct DottedLineShape: Shape {
    var axis: SmartDottedLine.Axis

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let runway: CGFloat = 50 // Hidden extension to prevent popping
        
        if axis == .horizontal {
            path.move(to: CGPoint(x: -runway, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.width + runway, y: rect.midY))
        } else {
            path.move(to: CGPoint(x: rect.midX, y: -runway))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.height + runway))
        }
        return path
    }
}

#Preview {
    DynamicDottedLineView()
}
