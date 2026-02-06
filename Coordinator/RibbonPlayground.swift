//
//  RibbonPlayground.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/6/26.
//

import SwiftUI

// MARK: - 1. Interactive Playground (Best for Testing)
/// Use this to drag values and break/fix the shape in real-time
struct RibbonPlayground: View {
    @State private var leftTop: CGFloat = 50
    @State private var leftHeight: CGFloat = 100
    @State private var rightTop: CGFloat = 20
    @State private var rightHeight: CGFloat = 50
    @State private var curvature: CGFloat = 0.5
    @State private var animate: Bool = false

    var body: some View {
        VStack {
            ZStack {
                Color.gray.opacity(0.1)
                
                // The Shape
                SankeyRibbon(
                    leftYTop: leftTop,
                    leftYBottom: leftTop + leftHeight,
                    rightYTop: rightTop,
                    rightYBottom: rightTop + rightHeight,
                    curvature: curvature
                )
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing).opacity(0.6))
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: leftTop)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: leftHeight)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: rightTop)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: rightHeight)
                .animation(.easeInOut, value: curvature)
                
                // Visual Guides (so you see the anchor points)
                GeometryReader { geo in
                    let width = geo.size.width
                    
                    // Left Anchors
                    AnchorDot(x: 0, y: leftTop, color: .green)
                    AnchorDot(x: 0, y: leftTop + leftHeight, color: .green)
                    
                    // Right Anchors
                    AnchorDot(x: width, y: rightTop, color: .red)
                    AnchorDot(x: width, y: rightTop + rightHeight, color: .red)
                }
            }
            .frame(height: 300)
            .border(Color.gray.opacity(0.3))
            .padding()

            // Controls
            ScrollView {
                VStack(spacing: 20) {
                    Group {
                        LabeledSlider(label: "Left Top Y", value: $leftTop, range: 0...200)
                        LabeledSlider(label: "Left Height", value: $leftHeight, range: 0...200)
                        Divider()
                        LabeledSlider(label: "Right Top Y", value: $rightTop, range: 0...200)
                        LabeledSlider(label: "Right Height", value: $rightHeight, range: 0...200)
                        Divider()
                        LabeledSlider(label: "Curvature", value: $curvature, range: -1.0...1.0)
                    }
                    
                    Button("Animate Randomly") {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            leftTop = CGFloat.random(in: 0...100)
                            leftHeight = CGFloat.random(in: 20...150)
                            rightTop = CGFloat.random(in: 0...100)
                            rightHeight = CGFloat.random(in: 20...150)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}

// Helper for Playground
struct AnchorDot: View {
    let x: CGFloat
    let y: CGFloat
    let color: Color
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .position(x: x, y: y)
    }
}

struct LabeledSlider: View {
    let label: String
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label).font(.caption).bold()
                Spacer()
                Text(String(format: "%.0f", value)).font(.caption).monospacedDigit()
            }
            Slider(value: $value, in: range)
        }
    }
}

// MARK: - 2. Static Gallery (Edge Cases)
#Preview("Static Gallery") {
    ScrollView {
        VStack(spacing: 40) {
            
            // Case A: Standard Flow
            PreviewContainer(title: "Standard Flow") {
                SankeyRibbon(leftYTop: 20, leftYBottom: 80, rightYTop: 20, rightYBottom: 80, curvature: 0.5)
                    .fill(.blue.opacity(0.5))
            }
            
            // Case B: Fan Out (Expansion)
            PreviewContainer(title: "Fan Out (Point to Bar)") {
                SankeyRibbon(leftYTop: 50, leftYBottom: 50, rightYTop: 10, rightYBottom: 90, curvature: 0.5)
                    .fill(.orange.opacity(0.5))
            }
            
            // Case C: Funnel (Compression)
            PreviewContainer(title: "Funnel (Bar to Point)") {
                SankeyRibbon(leftYTop: 10, leftYBottom: 90, rightYTop: 50, rightYBottom: 50, curvature: 0.5)
                    .fill(.green.opacity(0.5))
            }
            
            // Case D: Falling Flow (Diagonal)
            PreviewContainer(title: "Diagonal Drop") {
                SankeyRibbon(leftYTop: 10, leftYBottom: 30, rightYTop: 70, rightYBottom: 90, curvature: 0.6)
                    .fill(.red.opacity(0.5))
            }
            
            // Case E: Extreme Curvature (Square vs Smooth)
            PreviewContainer(title: "Curvature: 0.0 vs 0.8") {
                ZStack {
                    SankeyRibbon(leftYTop: 10, leftYBottom: 40, rightYTop: 60, rightYBottom: 90, curvature: 0.0)
                        .stroke(.black, style: StrokeStyle(lineWidth: 2, dash: [5]))
                    
                    SankeyRibbon(leftYTop: 10, leftYBottom: 40, rightYTop: 60, rightYBottom: 90, curvature: 0.8)
                        .fill(.purple.opacity(0.5))
                }
            }
        }
        .padding()
    }
}

struct PreviewContainer<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            content
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .border(Color.gray.opacity(0.2))
        }
    }
}

// MARK: - 3. Interactive Preview
#Preview("Interactive Debugger") {
    RibbonPlayground()
}
