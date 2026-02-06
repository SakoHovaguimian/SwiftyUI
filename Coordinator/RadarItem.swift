//
//  RadarItem.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/5/26.
//


import SwiftUI

// MARK: - 1. Data Model
struct RadarItem: Identifiable {
    let id = UUID()
    let label: String
    let iconName: String // Optional helper for the default view, can be ignored in custom views
    let value: Double // Normalize this 0.0 to 1.0 usually, or we handle max value scaling
}

// MARK: - 2. Configuration & Styling
struct RadarChartStyle {
    // Grid (The Background Web)
    var gridColor: Color
    var gridLineWidth: CGFloat
    var gridSteps: Int // How many concentric rings/polygons?
    
    // Axis (The Spines)
    var axisColor: Color
    var axisLineWidth: CGFloat
    
    // Data Polygon (The Filled Shape)
    var fillGradient: LinearGradient
    var strokeColor: Color
    var strokeWidth: CGFloat
    
    // Data Points (The dots at the corners)
    var showDataPoints: Bool
    var dataPointColor: Color
    var dataPointSize: CGFloat
    
    // Layout
    var labelOffset: CGFloat // How far from the tip to place the label
    
    // Standard Defaults matching your "Clean" aesthetic
    static let defaults = RadarChartStyle(
        gridColor: Color.gray.opacity(0.2),
        gridLineWidth: 1,
        gridSteps: 4,
        axisColor: Color.gray.opacity(0.2),
        axisLineWidth: 1,
        fillGradient: LinearGradient(
            colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.2)],
            startPoint: .top,
            endPoint: .bottom
        ),
        strokeColor: .purple,
        strokeWidth: 2,
        showDataPoints: true,
        dataPointColor: .purple,
        dataPointSize: 8,
        labelOffset: 40
    )
}

// MARK: - 3. The Geometry Engine
/// Helper to convert polar coordinates (value, index) to Cartesian (x, y)
struct RadarGeometry {
    static func point(
        value: Double,      // 0.0 to 1.0
        index: Int,
        totalCount: Int,
        radius: CGFloat,
        center: CGPoint
    ) -> CGPoint {
        // -90 degrees (pi/2) to start at 12 o'clock
        let angle = (CGFloat.pi * 2 * CGFloat(index) / CGFloat(totalCount)) - (CGFloat.pi / 2)
        
        let x = center.x + radius * CGFloat(value) * cos(angle)
        let y = center.y + radius * CGFloat(value) * sin(angle)
        return CGPoint(x: x, y: y)
    }
}

// MARK: - 4. Shapes

/// The Background Grid (Concentric Polygons)
struct RadarGridShape: Shape {
    let steps: Int
    let count: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        // Draw concentric polygons
        for step in 1...steps {
            let stepRadius = radius * (CGFloat(step) / CGFloat(steps))
            
            for i in 0..<count {
                let pt = RadarGeometry.point(value: 1.0, index: i, totalCount: count, radius: stepRadius, center: center)
                if i == 0 {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
            }
            path.closeSubpath()
        }
        
        return path
    }
}

/// The Axis Lines (Spines radiating from center)
struct RadarAxisShape: Shape {
    let count: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<count {
            let pt = RadarGeometry.point(value: 1.0, index: i, totalCount: count, radius: radius, center: center)
            path.move(to: center)
            path.addLine(to: pt)
        }
        
        return path
    }
}

/// The Data Polygon (The actual chart value)
struct RadarDataShape: Shape {
    var data: [Double] // Normalized values 0...1
    
    var animatableData: [Double] {
        get { data }
        set { data = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !data.isEmpty else { return path }
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for (i, value) in data.enumerated() {
            let pt = RadarGeometry.point(value: value, index: i, totalCount: data.count, radius: radius, center: center)
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - 5. The Main Component
struct RadarChart<LabelContent: View>: View {
    
    let data: [RadarItem]
    let maxValue: Double // The value that represents the outer edge (100%)
    let style: RadarChartStyle
    let labelBuilder: (RadarItem) -> LabelContent
    
    // Normalized data helper
    private var normalizedValues: [Double] {
        data.map { $0.value / maxValue }
    }
    
    // MARK: - Initializer (Custom Label)
    init(
        data: [RadarItem],
        maxValue: Double = 100,
        style: RadarChartStyle = .defaults,
        @ViewBuilder labelBuilder: @escaping (RadarItem) -> LabelContent
    ) {
        self.data = data
        self.maxValue = maxValue
        self.style = style
        self.labelBuilder = labelBuilder
    }
    
    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .local)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            // Leave room for labels by subtracting the offset
            let radius = (min(rect.width, rect.height) / 2) - style.labelOffset
            
            ZStack {
                // 1. The Grid (Web)
                RadarGridShape(steps: style.gridSteps, count: data.count)
                    .stroke(style.gridColor, lineWidth: style.gridLineWidth)
                    .frame(width: radius * 2, height: radius * 2)
                
                // 2. The Axes (Spines)
                RadarAxisShape(count: data.count)
                    .stroke(style.axisColor, lineWidth: style.axisLineWidth)
                    .frame(width: radius * 2, height: radius * 2)
                
                // 3. The Data Fill
                RadarDataShape(data: normalizedValues)
                    .fill(style.fillGradient)
                    .frame(width: radius * 2, height: radius * 2)
                
                // 4. The Data Stroke
                RadarDataShape(data: normalizedValues)
                    .stroke(style.strokeColor, style: StrokeStyle(lineWidth: style.strokeWidth, lineCap: .round, lineJoin: .round))
                    .frame(width: radius * 2, height: radius * 2)
                
                // 5. Data Points (Dots)
                if style.showDataPoints {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                        let pt = RadarGeometry.point(
                            value: item.value / maxValue,
                            index: index,
                            totalCount: data.count,
                            radius: radius,
                            center: center
                        )
                        
                        Circle()
                            .fill(style.dataPointColor)
                            .frame(width: style.dataPointSize, height: style.dataPointSize)
                            .position(pt)
                            // Optional: Add a white border to the dot like the image
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: style.dataPointSize, height: style.dataPointSize)
                                    .position(pt)
                            )
                    }
                }
                
                // 6. Labels
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    let labelPoint = RadarGeometry.point(
                        value: 1.0, // Always at the outer edge
                        index: index,
                        totalCount: data.count,
                        radius: radius + (style.labelOffset * 0.6), // Push out slightly
                        center: center
                    )
                    
                    labelBuilder(item)
                        .position(labelPoint)
                }
            }
        }
    }
}

// MARK: - 6. Convenience Init (Default Labels)
extension RadarChart where LabelContent == AnyView {
    init(
        data: [RadarItem],
        maxValue: Double = 100,
        style: RadarChartStyle = .defaults
    ) {
        self.init(data: data, maxValue: maxValue, style: style) { item in
            AnyView(
                VStack(spacing: 4) {
                    if !item.iconName.isEmpty {
                        Image(systemName: item.iconName)
                            .font(.caption)
                            .foregroundColor(style.strokeColor)
                    }
                    Text(item.label)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            )
        }
    }
}

// MARK: - 7. Preview & Usage
struct RadarChartExample: View {
    // Data matching the "Balance Wheel" image
    let lifeBalanceData: [RadarItem] = [
        RadarItem(label: "Health", iconName: "heart.fill", value: 80),
        RadarItem(label: "Career", iconName: "briefcase.fill", value: 65),
        RadarItem(label: "Finance", iconName: "dollarsign.circle.fill", value: 40),
        RadarItem(label: "Relationships", iconName: "person.2.fill", value: 75),
        RadarItem(label: "Growth", iconName: "brain.head.profile", value: 90),
        RadarItem(label: "Fun", iconName: "sparkles", value: 55),
        RadarItem(label: "Environment", iconName: "house.fill", value: 70),
        RadarItem(label: "Spirituality", iconName: "sun.max.fill", value: 60)
    ]
    
    // Custom Style to match the purple aesthetic
    let purpleStyle = RadarChartStyle(
        gridColor: Color.gray.opacity(0.15),
        gridLineWidth: 1,
        gridSteps: 5, // 5 rings
        axisColor: Color.gray.opacity(0.15),
        axisLineWidth: 1,
        fillGradient: LinearGradient(
            colors: [Color.purple.opacity(0.5), Color.purple.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        ),
        strokeColor: .purple,
        strokeWidth: 2,
        showDataPoints: true,
        dataPointColor: .purple,
        dataPointSize: 10,
        labelOffset: 32
    )

    var body: some View {
        VStack {
            Text("Balance Wheel")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            // Usage with Custom View Builder for Labels
            RadarChart(
                data: lifeBalanceData,
                maxValue: 100,
                style: purpleStyle
            ) { item in
                // Custom Label Layout matching the screenshot (Icon Top, Text Bottom)
                VStack(spacing: 2) {
                    // Colorful Icons
                    Image(systemName: item.iconName)
                        .font(.system(size: 14))
                        .foregroundColor(colorForLabel(item.label))
                    
                    Text(item.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 350)
            .padding()
            
            Spacer()
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    // Helper for varied colors in the example
    func colorForLabel(_ label: String) -> Color {
        switch label {
        case "Health": return .red
        case "Career": return .orange
        case "Finance": return .green
        case "Relationships": return .pink
        case "Growth": return .purple
        case "Fun": return .cyan
        case "Environment": return .blue
        case "Spirituality": return .yellow
        default: return .gray
        }
    }
}

#Preview {
    RadarChartExample()
}
