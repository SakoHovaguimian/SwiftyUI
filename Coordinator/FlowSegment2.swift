import SwiftUI

// MARK: - 1. Data Model
struct FlowSegment: Identifiable {
    let id = UUID()
    let name: String
    let subTitle: String
    let value: Double
    let color: Color
}

// MARK: - 2. Configuration & Styling
enum SankeyLabelPlane {
    case leading
    case trailing
}

/// Holds the styling options for the label, allowing "Heavy" customization via init
struct SankeyLabelOptions {
    var labelFont: Font
    var subTitleFont: Font
    var labelColor: Color
    var subTitleColor: Color
    var horizontalPadding: CGFloat
    var labelPlane: SankeyLabelPlane
    
    init(
        labelFont: Font,
        subTitleFont: Font,
        labelColor: Color,
        subTitleColor: Color,
        horizontalPadding: CGFloat,
        labelPlane: SankeyLabelPlane = .leading
    ) {
        self.labelFont = labelFont
        self.subTitleFont = subTitleFont
        self.labelColor = labelColor
        self.subTitleColor = subTitleColor
        self.horizontalPadding = horizontalPadding
        self.labelPlane = labelPlane
    }
    
    // Default Configuration
    static let defaults = SankeyLabelOptions(
        labelFont: .system(size: 12, weight: .medium),
        subTitleFont: .system(size: 12, weight: .regular),
        labelColor: .primary.opacity(0.8),
        subTitleColor: .secondary,
        horizontalPadding: 16, // The requested default (was previously offset -20)
        labelPlane: .leading
    )
}

// MARK: - 3. The Shape (The Ribbon)
struct SankeyRibbon: Shape {
    var leftYTop: CGFloat
    var leftYBottom: CGFloat
    var rightYTop: CGFloat
    var rightYBottom: CGFloat
    var curvature: CGFloat = 0.5

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        
        let topLeft = CGPoint(x: 0, y: leftYTop)
        let bottomLeft = CGPoint(x: 0, y: leftYBottom)
        let topRight = CGPoint(x: width, y: rightYTop)
        let bottomRight = CGPoint(x: width, y: rightYBottom)
        
        let control1 = CGPoint(x: width * curvature, y: leftYTop)
        let control2 = CGPoint(x: width * (1 - curvature), y: rightYTop)
        let control3 = CGPoint(x: width * (1 - curvature), y: rightYBottom)
        let control4 = CGPoint(x: width * curvature, y: leftYBottom)
        
        path.move(to: topLeft)
        path.addCurve(to: topRight, control1: control1, control2: control2)
        path.addLine(to: bottomRight)
        path.addCurve(to: bottomLeft, control1: control3, control2: control4)
        path.closeSubpath()
        
        return path
    }
    
    var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
        get {
            AnimatablePair(
                AnimatablePair(leftYTop, leftYBottom),
                AnimatablePair(rightYTop, rightYBottom)
            )
        }
        set {
            leftYTop = newValue.first.first
            leftYBottom = newValue.first.second
            rightYTop = newValue.second.first
            rightYBottom = newValue.second.second
        }
    }
}

// MARK: - 4. The Default Label View
/// Extracted View to handle the default look if no closure is passed
struct DefaultSankeyLabel: View {
    let segment: FlowSegment
    let options: SankeyLabelOptions
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(segment.name)
                .font(options.labelFont)
                .foregroundColor(options.labelColor)
            Text(segment.subTitle)
                .font(options.subTitleFont)
                .foregroundColor(options.subTitleColor)
        }
    }
}

// MARK: - 5. The Heavy Customizable Chart
struct DailySankeyChart<LabelContent: View>: View {
    
    // Core Data
    let data: [FlowSegment]
    
    // Visual Configuration
    let spineWidth: CGFloat
    let spineColor: Color
    let rightBarWidth: CGFloat
    let verticalSpacing: CGFloat
    let labelOptions: SankeyLabelOptions
    
    // The Custom Label Builder
    let labelBuilder: (FlowSegment) -> LabelContent
    
    private struct Band {
        let top: CGFloat
        let bottom: CGFloat
    }
    
    private struct RowLayout: Identifiable {
        let id: UUID
        let segment: FlowSegment
        let leftTop: CGFloat
        let leftBottom: CGFloat
        let rightTop: CGFloat
        let rightBottom: CGFloat
        
        var height: CGFloat { rightBottom - rightTop }
    }
    
    private struct ChartLayout {
        let spineTop: CGFloat
        let spineHeight: CGFloat
        let rows: [RowLayout]
    }
    
    // MARK: Generic Initializer (Custom Label)
    init(
        data: [FlowSegment],
        spineWidth: CGFloat = 8,
        spineColor: Color = .blue,
        rightBarWidth: CGFloat = 6,
        verticalSpacing: CGFloat = 16,
        labelOptions: SankeyLabelOptions = .defaults,
        @ViewBuilder labelBuilder: @escaping (FlowSegment) -> LabelContent
    ) {
        self.data = data
        self.spineWidth = spineWidth
        self.spineColor = spineColor
        self.rightBarWidth = rightBarWidth
        self.verticalSpacing = verticalSpacing
        self.labelOptions = labelOptions
        self.labelBuilder = labelBuilder
    }
    
    var totalValue: Double {
        data.map { $0.value }.reduce(0, +)
    }
    
    var body: some View {
        GeometryReader { geo in
            let fullWidth = geo.size.width
            let fullHeight = geo.size.height
            let layout = makeLayout(fullHeight: fullHeight)
            let shapeWidth = max(fullWidth - spineWidth, 1)
            
            ZStack(alignment: .topLeading) {
                
                // --- Layer A: Left Spine ---
                Capsule()
                    .fill(spineColor)
                    .frame(width: spineWidth, height: layout.spineHeight)
                    .offset(x: 0, y: layout.spineTop)
                
                // --- Layer B: Ribbons, Caps, Labels ---
                ForEach(layout.rows) { row in
                    
                    // 1. Ribbon
                    SankeyRibbon(
                        leftYTop: row.leftTop,
                        leftYBottom: row.leftBottom,
                        rightYTop: row.rightTop,
                        rightYBottom: row.rightBottom,
                        curvature: 0.5
                    )
                    .fill(row.segment.color.opacity(0.3))
                    .frame(width: shapeWidth, height: fullHeight, alignment: .topLeading)
                    .offset(x: spineWidth)
                    .offset(x: -2)
                    
                    // 2. Right Cap
                    Capsule()
                        .fill(row.segment.color)
                        .frame(width: rightBarWidth, height: row.height)
                        .offset(x: fullWidth - rightBarWidth, y: row.rightTop)
                    
                    // 3. The Label (Custom or Default), vertically centered by row height
                    labelLayer(for: row, fullWidth: fullWidth)
                }
            }
        }
    }
    
    @ViewBuilder
    private func labelLayer(for row: RowLayout, fullWidth: CGFloat) -> some View {
        let isLeading = labelOptions.labelPlane == .leading
        let labelTop = isLeading ? row.leftTop : row.rightTop
        
        HStack {
            if isLeading {
                labelBuilder(row.segment)
                Spacer(minLength: 0)
            } else {
                Spacer(minLength: 0)
                labelBuilder(row.segment)
            }
        }
        .padding(.leading, isLeading ? spineWidth + labelOptions.horizontalPadding : 0)
        .padding(.trailing, isLeading ? 0 : rightBarWidth + labelOptions.horizontalPadding)
        .frame(width: fullWidth, height: row.height, alignment: .leading)
        .offset(y: labelTop)
    }
    
    private func makeLayout(fullHeight: CGFloat) -> ChartLayout {
        guard !data.isEmpty, fullHeight > 0 else {
            return ChartLayout(spineTop: 0, spineHeight: 0, rows: [])
        }
        
        let spacing = effectiveSpacing(height: fullHeight, count: data.count)
        let totalGapsHeight = spacing * CGFloat(max(data.count - 1, 0))
        let availableDataHeight = max(fullHeight - totalGapsHeight, 0)
        
        let leftStackTopOffset = (fullHeight - availableDataHeight) / 2
        let leftStackBottom = leftStackTopOffset + availableDataHeight
        
        let leftBands = contiguousBands(for: data, top: leftStackTopOffset, bottom: leftStackBottom)
        let rightBands = gappedBands(for: data, top: 0, bottom: fullHeight, spacing: spacing)
        
        var rows: [RowLayout] = []
        for index in data.indices {
            rows.append(
                RowLayout(
                    id: data[index].id,
                    segment: data[index],
                    leftTop: leftBands[index].top,
                    leftBottom: leftBands[index].bottom,
                    rightTop: rightBands[index].top,
                    rightBottom: rightBands[index].bottom
                )
            )
        }
        
        return ChartLayout(
            spineTop: leftStackTopOffset,
            spineHeight: availableDataHeight,
            rows: rows
        )
    }
    
    private func contiguousBands(for segments: [FlowSegment], top: CGFloat, bottom: CGFloat) -> [Band] {
        let total = segments.map { $0.value }.reduce(0, +)
        let safeTotal = total > 0 ? total : Double(max(segments.count, 1))
        let height = max(bottom - top, 0)
        let pointsPerValue = height / CGFloat(safeTotal)
        
        var cursor = top
        var bands: [Band] = []
        
        for segment in segments {
            let value = total > 0 ? segment.value : 1
            let segmentHeight = CGFloat(value) * pointsPerValue
            
            let bandTop = cursor
            let bandBottom = bandTop + segmentHeight
            
            bands.append(Band(top: bandTop, bottom: bandBottom))
            cursor = bandBottom
        }
        
        return bands
    }
    
    private func gappedBands(for segments: [FlowSegment], top: CGFloat, bottom: CGFloat, spacing: CGFloat) -> [Band] {
        let total = segments.map { $0.value }.reduce(0, +)
        let safeTotal = total > 0 ? total : Double(max(segments.count, 1))
        
        let height = max(bottom - top, 0)
        let gapHeight = spacing * CGFloat(max(segments.count - 1, 0))
        let availableHeight = max(height - gapHeight, 0)
        let pointsPerValue = availableHeight / CGFloat(safeTotal)
        
        var cursor = top
        var bands: [Band] = []
        
        for index in segments.indices {
            let segment = segments[index]
            let value = total > 0 ? segment.value : 1
            let segmentHeight = CGFloat(value) * pointsPerValue
            
            let bandTop = cursor
            let bandBottom = bandTop + segmentHeight
            
            bands.append(Band(top: bandTop, bottom: bandBottom))
            
            if index < segments.count - 1 {
                cursor = bandBottom + spacing
            } else {
                cursor = bandBottom
            }
        }
        
        return bands
    }
    
    private func effectiveSpacing(height: CGFloat, count: Int) -> CGFloat {
        guard count > 1 else { return 0 }
        let maxSafeSpacing = height / CGFloat(count + 1)
        return min(verticalSpacing, maxSafeSpacing)
    }
}

// MARK: - 6. Convenience Extension (Default Label)
extension DailySankeyChart where LabelContent == DefaultSankeyLabel {
    
    // This initializer is used when the user DOES NOT provide a closure.
    // It uses the DefaultSankeyLabel and allows customizing options via the struct.
    init(
        data: [FlowSegment],
        spineWidth: CGFloat = 8,
        spineColor: Color = .blue,
        rightBarWidth: CGFloat = 6,
        verticalSpacing: CGFloat = 16,
        labelOptions: SankeyLabelOptions = .defaults
    ) {
        self.init(
            data: data,
            spineWidth: spineWidth,
            spineColor: spineColor,
            rightBarWidth: rightBarWidth,
            verticalSpacing: verticalSpacing,
            labelOptions: labelOptions
        ) { segment in
            // The default "Callback" implementation
            DefaultSankeyLabel(segment: segment, options: labelOptions)
        }
    }
}

// MARK: - 7. Usage Examples
struct ContentView: View {
    let sampleData: [FlowSegment] = [
        FlowSegment(name: "Sleep", subTitle: "(6h 15m)", value: 6.25, color: Color(red: 0.6, green: 0.6, blue: 0.95)),
        FlowSegment(name: "Learning", subTitle: "(3h 36m)", value: 3.6, color: Color(red: 0.85, green: 0.75, blue: 0.65)),
        FlowSegment(name: "University", subTitle: "(5h 10m)", value: 5.16, color: Color(red: 0.6, green: 0.85, blue: 0.6)),
        FlowSegment(name: "Gym", subTitle: "(2h)", value: 2.0, color: Color(red: 1.0, green: 0.6, blue: 0.65)),
        FlowSegment(name: "Free Time", subTitle: "(6h 58m)", value: 6.9, color: Color(red: 0.6, green: 0.8, blue: 1.0))
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                
                // EXAMPLE 1: Default Style (Uses DefaultSankeyLabel)
                // We just pass data and maybe tweak the spine color
                VStack(alignment: .leading) {
                    Text("1. Default Style").bold()
                    DailySankeyChart(
                        data: sampleData,
                        spineColor: .blue,
                        labelOptions: SankeyLabelOptions(
                            labelFont: .caption.bold(),
                            subTitleFont: .caption,
                            labelColor: .black,
                            subTitleColor: .gray,
                            horizontalPadding: 8 // Default 16
                        )
                    )
                    .frame(height: 300)
                }
                
                Divider()

                // EXAMPLE 2: Totally Custom ViewBuilder
                // Here we ignore the default style and build whatever we want
                VStack(alignment: .leading) {
                    Text("2. Custom ViewBuilder").bold()
                    DailySankeyChart(
                        data: sampleData,
                        verticalSpacing: 32,
                        // We can still use labelOptions to control the padding of our custom view
                        labelOptions: SankeyLabelOptions(
                            labelFont: .body, // Ignored by custom view
                            subTitleFont: .body, // Ignored
                            labelColor: .clear, // Ignored
                            subTitleColor: .clear, // Ignored
                            horizontalPadding: 8, // Custom padding
                            labelPlane: .trailing
                        )
                    ) { segment in
                        // COMPLETELY CUSTOM LABEL
                        HStack {
                            
                            Image(systemName: "clock")
                                .font(.caption)
                            
                            Text(segment.name.uppercased())
                                .font(.caption2)
                                .fontWeight(.black)
                            
                        }
//                        .padding(6)
//                        .background(Color.white.opacity(0.6))
//                        .cornerRadius(99)
                    }
                    .frame(height: 350)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

#Preview {
    
    VStack {
        
        SankeyRibbon(leftYTop: 10, leftYBottom: 10, rightYTop: 10, rightYBottom: 0, curvature: 0)
            .fill(.blue)
        
    }
    
}
