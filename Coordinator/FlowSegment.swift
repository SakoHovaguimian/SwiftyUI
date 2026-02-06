//import SwiftUI
//
//// MARK: - 1. Data Model
//struct FlowSegment: Identifiable {
//    let id = UUID()
//    let name: String
//    let subTitle: String
//    let value: Double
//    let color: Color
//}
//
//// MARK: - 2. Configuration & Styling
///// Holds the styling options for the label, allowing "Heavy" customization via init
//struct SankeyLabelOptions {
//    var labelFont: Font
//    var subTitleFont: Font
//    var labelColor: Color
//    var subTitleColor: Color
//    var horizontalPadding: CGFloat
//    
//    // Default Configuration
//    static let defaults = SankeyLabelOptions(
//        labelFont: .system(size: 12, weight: .medium),
//        subTitleFont: .system(size: 12, weight: .regular),
//        labelColor: .primary.opacity(0.8),
//        subTitleColor: .secondary,
//        horizontalPadding: 16 // The requested default (was previously offset -20)
//    )
//}
//
//// MARK: - 3. The Shape (The Ribbon)
//struct SankeyRibbon: Shape {
//    var leftYTop: CGFloat
//    var leftYBottom: CGFloat
//    var rightYTop: CGFloat
//    var rightYBottom: CGFloat
//    var curvature: CGFloat = 0.5
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let width = rect.width
//        
//        let topLeft = CGPoint(x: 0, y: leftYTop)
//        let bottomLeft = CGPoint(x: 0, y: leftYBottom)
//        let topRight = CGPoint(x: width, y: rightYTop)
//        let bottomRight = CGPoint(x: width, y: rightYBottom)
//        
//        let control1 = CGPoint(x: width * curvature, y: leftYTop)
//        let control2 = CGPoint(x: width * (1 - curvature), y: rightYTop)
//        let control3 = CGPoint(x: width * (1 - curvature), y: rightYBottom)
//        let control4 = CGPoint(x: width * curvature, y: leftYBottom)
//        
//        path.move(to: topLeft)
//        path.addCurve(to: topRight, control1: control1, control2: control2)
//        path.addLine(to: bottomRight)
//        path.addCurve(to: bottomLeft, control1: control3, control2: control4)
//        path.closeSubpath()
//        
//        return path
//    }
//    
//    var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
//        get {
//            AnimatablePair(
//                AnimatablePair(leftYTop, leftYBottom),
//                AnimatablePair(rightYTop, rightYBottom)
//            )
//        }
//        set {
//            leftYTop = newValue.first.first
//            leftYBottom = newValue.first.second
//            rightYTop = newValue.second.first
//            rightYBottom = newValue.second.second
//        }
//    }
//}
//
//// MARK: - 4. The Default Label View
///// Extracted View to handle the default look if no closure is passed
//struct DefaultSankeyLabel: View {
//    let segment: FlowSegment
//    let options: SankeyLabelOptions
//    
//    var body: some View {
//        HStack(alignment: .firstTextBaseline, spacing: 4) {
//            Text(segment.name)
//                .font(options.labelFont)
//                .foregroundColor(options.labelColor)
//            Text(segment.subTitle)
//                .font(options.subTitleFont)
//                .foregroundColor(options.subTitleColor)
//        }
//    }
//}
//
//// MARK: - 5. The Heavy Customizable Chart
//struct DailySankeyChart<LabelContent: View>: View {
//    
//    // Core Data
//    let data: [FlowSegment]
//    
//    // Visual Configuration
//    let spineWidth: CGFloat
//    let spineColor: Color
//    let rightBarWidth: CGFloat
//    let verticalSpacing: CGFloat
//    let labelOptions: SankeyLabelOptions
//    
//    // The Custom Label Builder
//    let labelBuilder: (FlowSegment) -> LabelContent
//    
//    // MARK: Generic Initializer (Custom Label)
//    init(
//        data: [FlowSegment],
//        spineWidth: CGFloat = 8,
//        spineColor: Color = .blue,
//        rightBarWidth: CGFloat = 6,
//        verticalSpacing: CGFloat = 16,
//        labelOptions: SankeyLabelOptions = .defaults,
//        @ViewBuilder labelBuilder: @escaping (FlowSegment) -> LabelContent
//    ) {
//        self.data = data
//        self.spineWidth = spineWidth
//        self.spineColor = spineColor
//        self.rightBarWidth = rightBarWidth
//        self.verticalSpacing = verticalSpacing
//        self.labelOptions = labelOptions
//        self.labelBuilder = labelBuilder
//    }
//    
//    var totalValue: Double {
//        data.map { $0.value }.reduce(0, +)
//    }
//    
//    var body: some View {
//        GeometryReader { geo in
//            let fullWidth = geo.size.width
//            let fullHeight = geo.size.height
//            
//            // Layout Math
//            let totalGapsHeight = verticalSpacing * CGFloat(data.count - 1)
//            let availableDataHeight = fullHeight - totalGapsHeight
//            let pointsPerValue = availableDataHeight / totalValue
//            
//            let leftStackTotalHeight = availableDataHeight
//            let leftStackTopOffset = (fullHeight - leftStackTotalHeight) / 2
//            
//            ZStack(alignment: .leading) {
//                
//                // --- Layer A: Left Spine ---
//                Capsule()
//                    .fill(spineColor)
//                    .frame(width: spineWidth, height: leftStackTotalHeight)
//                    .position(x: spineWidth / 2, y: fullHeight / 2)
//                
//                // --- Layer B: Ribbons & Labels ---
//                ForEach(Array(data.enumerated()), id: \.element.id) { index, segment in
//                    
//                    let segmentHeight = segment.value * pointsPerValue
//                    
//                    // Y Position Logic
//                    let previousValues = data.prefix(index).map { $0.value }.reduce(0, +)
//                    
//                    let leftYTop = leftStackTopOffset + (previousValues * pointsPerValue)
//                    let leftYBottom = leftYTop + segmentHeight
//                    
//                    let rightYTop = (previousValues * pointsPerValue) + (CGFloat(index) * verticalSpacing)
//                    let rightYBottom = rightYTop + segmentHeight
//                    
//                    let shapeWidth = fullWidth - spineWidth
//                    
//                    ZStack(alignment: .leading) {
//                        
//                        // 1. Ribbon
//                        SankeyRibbon(
//                            leftYTop: leftYTop,
//                            leftYBottom: leftYBottom,
//                            rightYTop: rightYTop,
//                            rightYBottom: rightYBottom,
//                            curvature: 0.5
//                        )
//                        .fill(segment.color.opacity(0.3))
//                        .frame(width: shapeWidth, height: fullHeight)
//                        .offset(x: spineWidth)
//                        
//                        // 2. Right Cap
//                        Capsule()
//                            .fill(segment.color)
//                            .frame(width: rightBarWidth, height: segmentHeight)
//                            .position(
//                                x: fullWidth - (rightBarWidth / 2),
//                                y: rightYTop + (segmentHeight / 2)
//                            )
//                        
//                        // 3. The Label (Custom or Default)
//                        // We wrap it in an HStack with a Spacer to force leading alignment within the ZStack context,
//                        // then calculate the precise Y center of the ribbon.
//                        HStack {
//                            labelBuilder(segment)
//                            Spacer()
//                        }
//                        .padding(.leading, spineWidth + labelOptions.horizontalPadding)
//                        .position(x: fullWidth / 2, y: leftYTop + (segmentHeight / 2))
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - 6. Convenience Extension (Default Label)
//extension DailySankeyChart where LabelContent == DefaultSankeyLabel {
//    
//    // This initializer is used when the user DOES NOT provide a closure.
//    // It uses the DefaultSankeyLabel and allows customizing options via the struct.
//    init(
//        data: [FlowSegment],
//        spineWidth: CGFloat = 8,
//        spineColor: Color = .blue,
//        rightBarWidth: CGFloat = 6,
//        verticalSpacing: CGFloat = 16,
//        labelOptions: SankeyLabelOptions = .defaults
//    ) {
//        self.init(
//            data: data,
//            spineWidth: spineWidth,
//            spineColor: spineColor,
//            rightBarWidth: rightBarWidth,
//            verticalSpacing: verticalSpacing,
//            labelOptions: labelOptions
//        ) { segment in
//            // The default "Callback" implementation
//            DefaultSankeyLabel(segment: segment, options: labelOptions)
//        }
//    }
//}
//
//// MARK: - 7. Usage Examples
//struct ContentView: View {
//    let sampleData: [FlowSegment] = [
//        FlowSegment(name: "Sleep", subTitle: "(6h 15m)", value: 6.25, color: Color(red: 0.6, green: 0.6, blue: 0.95)),
//        FlowSegment(name: "Learning", subTitle: "(3h 36m)", value: 3.6, color: Color(red: 0.85, green: 0.75, blue: 0.65)),
//        FlowSegment(name: "University", subTitle: "(5h 10m)", value: 5.16, color: Color(red: 0.6, green: 0.85, blue: 0.6)),
//        FlowSegment(name: "Gym", subTitle: "(2h)", value: 2.0, color: Color(red: 1.0, green: 0.6, blue: 0.65)),
//        FlowSegment(name: "Free Time", subTitle: "(6h 58m)", value: 6.9, color: Color(red: 0.6, green: 0.8, blue: 1.0))
//    ]
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 40) {
//                
//                // EXAMPLE 1: Default Style (Uses DefaultSankeyLabel)
//                // We just pass data and maybe tweak the spine color
//                VStack(alignment: .leading) {
//                    Text("1. Default Style").bold()
//                    DailySankeyChart(
//                        data: sampleData,
//                        spineColor: .blue,
//                        labelOptions: SankeyLabelOptions(
//                            labelFont: .caption.bold(),
//                            subTitleFont: .caption,
//                            labelColor: .black,
//                            subTitleColor: .gray,
//                            horizontalPadding: 8 // Default 16
//                        )
//                    )
//                    .frame(height: 300)
//                }
//                
//                Divider()
//
//                // EXAMPLE 2: Totally Custom ViewBuilder
//                // Here we ignore the default style and build whatever we want
//                VStack(alignment: .leading) {
//                    Text("2. Custom ViewBuilder").bold()
//                    DailySankeyChart(
//                        data: sampleData,
//                        verticalSpacing: 32,
//                        // We can still use labelOptions to control the padding of our custom view
//                        labelOptions: SankeyLabelOptions(
//                            labelFont: .body, // Ignored by custom view
//                            subTitleFont: .body, // Ignored
//                            labelColor: .clear, // Ignored
//                            subTitleColor: .clear, // Ignored
//                            horizontalPadding: 8 // Custom padding
//                        )
//                    ) { segment in
//                        // COMPLETELY CUSTOM LABEL
//                        HStack {
//                            
//                            Image(systemName: "clock")
//                                .font(.caption)
//                            
//                            Text(segment.name.uppercased())
//                                .font(.caption2)
//                                .fontWeight(.black)
//                            
//                        }
////                        .padding(6)
////                        .background(Color.white.opacity(0.6))
////                        .cornerRadius(99)
//                    }
//                    .frame(height: 350)
//                }
//            }
//            .padding()
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
