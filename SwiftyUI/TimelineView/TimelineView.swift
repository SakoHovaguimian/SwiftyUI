////
////  TimelineView.swift
////  SwiftyUI
////
////  Created by Sako Hovaguimian on 9/8/24.
////
//
//import SwiftUI
//
//// TODO: - Style for highlight trim before fill
//
//public struct TimelineView: View {
//    
//    public enum Direction {
//        
//        case horizontal
//        case vertical
//        
//    }
//    
//    public enum FillStyle {
//        
//        case trimToFill(delay: CGFloat = 0.3)
//        case solid
//        
//        var isTrimToFill: Bool {
//            switch self {
//            case .trimToFill: return true
//            case .solid: return false
//            }
//        }
//        
//        var delay: CGFloat {
//            switch self {
//            case .trimToFill(delay: let delay): return delay
//            case .solid: return 0
//            }
//        }
//        
//    }
//    
//    @Binding private var currentStepIndex: Int
//    
//    private let direction: Direction
//    private let steps: [Step]
//    private let circleSize: CGFloat
//    private let lineWidth: CGFloat
//    private let animationDuration: CGFloat
//    private let fillStyle: FillStyle
//    
//    public init(currentStepIndex: Binding<Int>,
//                direction: Direction,
//                steps: [Step],
//                fillStyle: Self.FillStyle = .solid,
//                circleSize: CGFloat = 32,
//                lineWidth: CGFloat = 3,
//                animationDuration: CGFloat = 0.5) {
//        
//        self._currentStepIndex = currentStepIndex
//        self.direction = direction
//        self.steps = steps
//        self.fillStyle = fillStyle
//        self.circleSize = circleSize
//        self.lineWidth = lineWidth
//        self.animationDuration = animationDuration
//        
//    }
//    
//    public var body: some View {
//        
//        switch self.direction {
//        case .horizontal:
//            
//            HorizontalTimelineView(
//                currentStep: self.$currentStepIndex,
//                steps: self.steps,
//                circleSize: self.circleSize,
//                lineWidth: self.lineWidth,
//                animationDuration: self.animationDuration,
//                fillStyle: self.fillStyle
//            )
//        
//        case .vertical:
//            
//            VerticalTimelineView(
//                currentStep: self.$currentStepIndex,
//                steps: self.steps,
//                circleSize: self.circleSize,
//                lineWidth: self.lineWidth,
//                animationDuration: self.animationDuration,
//                fillStyle: self.fillStyle
//            )
//        }
//        
//    }
//    
//}
//
//public struct Step: Identifiable {
//    
//    public let id: String = UUID().uuidString
//    public let title: String
//    
//    public let selectedTitleFont: Font
//    public let unselectedTitleFont: Font
//    
//    public let selectedTitleColor: Color
//    public let unselectedTitleColor: Color
//    
//    public let selectedFillColor: Color
//    public let unselectedFillColor: Color
//    
//    public let image: Image
//    public let imageSize: CGFloat
//    public let imageFillRatio: CGFloat
//    
//    public init(title: String,
//         selectedTitleFont: Font = .title3,
//         unselectedTitleFont: Font = .body,
//         selectedFillColor: Color = .green,
//         unselectedFillColor: Color = .gray,
//         selectedTitleColor: Color = .black,
//         unselectedTitleColor: Color = .gray,
//         image: Image = Image(systemName: "checkmark"),
//         imageSize: CGFloat = 32,
//         imageFillRatio: CGFloat = 0.45) {
//        
//        self.title = title
//        self.selectedTitleFont = selectedTitleFont
//        self.unselectedTitleFont = unselectedTitleFont
//        self.selectedFillColor = selectedFillColor
//        self.unselectedFillColor = unselectedFillColor
//        self.selectedTitleColor = selectedTitleColor
//        self.unselectedTitleColor = unselectedTitleColor
//        self.image = image
//        self.imageSize = imageSize
//        self.imageFillRatio = imageFillRatio
//        
//    }
//    
//}
//
//fileprivate struct HorizontalTimelineView: View {
//    
//    @Binding var currentStep: Int
//    
//    let steps: [Step]
//    let circleSize: CGFloat
//    let lineWidth: CGFloat
//    let animationDuration: CGFloat
//    let fillStyle: TimelineView.FillStyle
//    
//    public init(currentStep: Binding<Int>,
//                steps: [Step],
//                circleSize: CGFloat = 32,
//                lineWidth: CGFloat = 3,
//                animationDuration: CGFloat = 0.5,
//                fillStyle: TimelineView.FillStyle = .trimToFill(delay: 0.3)) {
//        
//        self._currentStep = currentStep
//        self.steps = steps
//        self.circleSize = circleSize
//        self.lineWidth = lineWidth
//        self.animationDuration = animationDuration
//        self.fillStyle = fillStyle
//        
//    }
//    
//    public var body: some View {
//        
//        HStack(alignment: .center, spacing: 0) {
//            
//            ForEach(self.steps.indices, id: \.self) { index in
//                stepView(index: index)
//            }
//            
//        }
//        
//    }
//    
//    private func stepView(index: Int) -> some View {
//        
//        let currentStep = self.steps[index]
//        let shouldHighlight = (self.currentStep > index)
//        let imageScale = currentStep.imageSize * currentStep.imageFillRatio
//        let fillColor = index < self.currentStep ? currentStep.selectedFillColor : currentStep.unselectedFillColor
//        let titleColor = shouldHighlight ? currentStep.selectedTitleColor : currentStep.unselectedTitleColor
//        
//        let fillStyleIsTrimToFill = fillStyle.isTrimToFill
//        let fillStyleDelay = self.fillStyle.delay
//        
//        return VStack(alignment: .leading) {
//            
//            HStack(alignment: .top, spacing: 0) {
//                
//                ZStack {
//                    
//                    // Background
//                    
//                    Circle()
//                        .stroke(lineWidth: self.lineWidth)
//                        .frame(
//                            width: self.circleSize,
//                            height: self.circleSize
//                        )
//                        .foregroundStyle(fillStyleIsTrimToFill ? currentStep.unselectedFillColor : fillColor)
//                    
//                    if fillStyleIsTrimToFill {
//                        
//                        // Trim
//                        
//                        Circle()
//                            .trim(from: 0, to: shouldHighlight ? 1 : 0)
//                            .stroke(fillColor, lineWidth: self.lineWidth)
//                            .frame(
//                                width: self.circleSize,
//                                height: self.circleSize
//                            )
//                            .rotationEffect(.degrees(-90))
//                            .animation(
//                                .easeInOut(duration: self.animationDuration),
//                                value: self.currentStep
//                            )
//                        
//                    }
//                    
//                    // Fill
//                    
//                    Circle()
//                        .fill(currentStep.selectedFillColor)
//                        .frame(
//                            width: self.circleSize,
//                            height: self.circleSize
//                        )
//                        .foregroundStyle(fillColor)
//                        .overlay {
//                            
//                            if shouldHighlight {
//                                
//                                currentStep
//                                    .image
//                                    .resizable()
//                                    .frame(
//                                        width: imageScale,
//                                        height: imageScale
//                                    )
//                                    .foregroundStyle(.white)
//                                    .transition(.scale.combined(with: .opacity))
//                                
//                            }
//                            
//                        }
//                        .opacity(shouldHighlight ? 1 : 0)
//                        .animation(
//                            .easeInOut(duration: self.animationDuration).delay(fillStyleDelay),
//                            value: self.currentStep
//                        )
//                    
//                }
//                
//                if index < self.steps.count - 1 {
//                    
//                    lineView(index: index)
//                        .padding(.top, self.circleSize / 2)
//                    
//                }
//                
//            }
//            
//            Rectangle()
//                .fill(.clear)
//                .frame(width: self.circleSize, height: 10)
//                .overlay {
//                    
//                    Text(currentStep.title)
//                        .fixedSize()
//                        .foregroundColor(titleColor)
//                        .multilineTextAlignment(.center)
//                        .lineLimit(2)
//                        .font(shouldHighlight ? currentStep.selectedTitleFont : currentStep.unselectedTitleFont)
//                        .animation(
//                            .easeInOut(duration: self.animationDuration).delay(fillStyleDelay),
//                            value: self.currentStep
//                        )
//                    
//                }
//                .animation(
//                    .easeInOut(duration: self.animationDuration).delay(fillStyleDelay),
//                    value: self.currentStep
//                )
//            
//        }
//        
//    }
//    
//    private func lineView(index: Int) -> some View {
//        
//        let currentStep = self.steps[index]
//        let shouldHighlight = index >= self.currentStep
//        
//        return ZStack(alignment: .leading) {
//            
//            Rectangle()
//                .frame(height: self.lineWidth)
//                .foregroundStyle(currentStep.unselectedFillColor)
//            
//            Rectangle()
//                .frame(height: self.lineWidth)
//                .frame(maxWidth: shouldHighlight ? 0 : .infinity, alignment: .leading)
//                .foregroundStyle(currentStep.selectedFillColor)
//            
//        }
//        .animation(
//            .smooth(duration: self.animationDuration + 0.3).delay(0.5),
//            value: self.currentStep
//        )
//        
//    }
//    
//}
//
//fileprivate struct VerticalTimelineView: View {
//    
//    @Binding var currentStep: Int
//    
//    let steps: [Step]
//    let circleSize: CGFloat
//    let lineWidth: CGFloat
//    let animationDuration: CGFloat
//    let fillStyle: TimelineView.FillStyle
//    
//    public init(currentStep: Binding<Int>,
//                steps: [Step],
//                circleSize: CGFloat = 32,
//                lineWidth: CGFloat = 3,
//                animationDuration: CGFloat = 0.5,
//                fillStyle: TimelineView.FillStyle = .trimToFill(delay: 0.3)) {
//        
//        self._currentStep = currentStep
//        self.steps = steps
//        self.circleSize = circleSize
//        self.lineWidth = lineWidth
//        self.animationDuration = animationDuration
//        self.fillStyle = fillStyle
//        
//    }
//    
//    public var body: some View {
//        
//        VStack(alignment: .leading, spacing: 0) {
//            
//            ForEach(self.steps.indices, id: \.self) { index in
//                stepView(index: index)
//            }
//            
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        
//    }
//    
//    private func stepView(index: Int) -> some View {
//        
//        let currentStep = self.steps[index]
//        let shouldHighlight = (self.currentStep > index)
//        let imageScale = currentStep.imageSize * currentStep.imageFillRatio
//        let fillColor = index < self.currentStep ? currentStep.selectedFillColor : currentStep.unselectedFillColor
//        let titleColor = shouldHighlight ? currentStep.selectedTitleColor : currentStep.unselectedTitleColor
//        
//        let fillStyleIsTrimToFill = fillStyle.isTrimToFill
//        let fillStyleDelay = self.fillStyle.delay
//        
//        return HStack(alignment: .top) {
//            
//            VStack(alignment: .leading, spacing: 0) {
//                
//                HStack {
//                    
//                    ZStack {
//                        
//                        // Background
//                        
//                        Circle()
//                            .stroke(lineWidth: self.lineWidth)
//                            .frame(
//                                width: self.circleSize,
//                                height: self.circleSize
//                            )
//                            .foregroundStyle(fillStyleIsTrimToFill ? currentStep.unselectedFillColor : fillColor)
//                        
//                        // Trim
//                        
//                        if fillStyleIsTrimToFill {
//                            
//                            Circle()
//                                .trim(from: 0, to: shouldHighlight ? 1 : 0)
//                                .stroke(fillColor, lineWidth: self.lineWidth)
//                                .frame(
//                                    width: self.circleSize,
//                                    height: self.circleSize
//                                )
//                                .rotationEffect(.degrees(-90))
//                                .animation(
//                                    .easeInOut(duration: self.animationDuration),
//                                    value: self.currentStep
//                                )
//                            
//                        }
//                        
//                        // Fill
//                        
//                        Circle()
//                            .fill(currentStep.selectedFillColor)
//                            .frame(
//                                width: self.circleSize,
//                                height: self.circleSize
//                            )
//                            .foregroundStyle(fillColor)
//                        
//                            .overlay {
//                                
//                                if shouldHighlight {
//                                    
//                                    currentStep
//                                        .image
//                                        .resizable()
//                                        .frame(
//                                            width: imageScale,
//                                            height: imageScale
//                                        )
//                                        .foregroundStyle(.white)
//                                        .transition(.scale.combined(with: .opacity))
//                                    
//                                }
//                                
//                            }
//                            .opacity(shouldHighlight ? 1 : 0)
//                            .animation(
//                                .easeInOut(duration: self.animationDuration).delay(fillStyleDelay),
//                                value: self.currentStep
//                            )
//                        
//                    }
//                    
//                    Text(currentStep.title)
//                        .fixedSize()
//                        .foregroundColor(titleColor)
//                        .multilineTextAlignment(.center)
//                        .lineLimit(2)
//                        .font(shouldHighlight ? currentStep.selectedTitleFont : currentStep.unselectedTitleFont)
//                        .animation(
//                            .easeInOut(duration: self.animationDuration).delay(fillStyleDelay),
//                            value: self.currentStep
//                        )
//                    
//                }
//                .frame(height: self.circleSize)
//                
//                if index < self.steps.count - 1 {
//                    
//                    lineView(index: index)
//                        .padding(.leading, self.circleSize / 2 - 1.5)
//                    
//                }
//                
//            }
//            
//        }
//        
//    }
//    
//    private func lineView(index: Int) -> some View {
//        
//        let currentStep = self.steps[index]
//        let shouldHighlight = self.currentStep > index
//        
//        return ZStack(alignment: .top) {
//            
//            Rectangle()
//                .frame(width: self.lineWidth)
//                .foregroundStyle(currentStep.unselectedFillColor)
//            
//            Rectangle()
//                .frame(width: self.lineWidth)
//                .frame(height: shouldHighlight ? .infinity : 0)
//                .foregroundStyle(currentStep.selectedFillColor)
//            
//        }
//        .animation(
//            .smooth(duration: self.animationDuration + 0.3).delay(self.fillStyle.delay),
//            value: self.currentStep
//        )
//        
//    }
//    
//}
//
//#Preview("Vertical") {
//    
//    @Previewable @State var currentStep = 0
//    
//    let steps: [Step] = [
//        .init(
//            title: "Step 1",
//            selectedFillColor: .indigo,
//            image: Image(systemName: "person.fill"),
//            imageFillRatio: 0.50
//        ),
//        .init(
//            title: "Step 2",
//            selectedFillColor: .darkRed,
//            image: Image(systemName: "house.fill"),
//            imageFillRatio: 0.50
//        ),
//        .init(
//            title: "Step 3"
//        ),
//        .init(
//            title: "Step 4",
//            selectedFillColor: .darkBlue,
//            image: Image(systemName: "house.fill"),
//            imageFillRatio: 0.50
//        )
//    ]
//    
//    VStack(spacing: 32) {
//        
//        HStack(spacing: 32) {
//            
//            TimelineView(
//                currentStepIndex: $currentStep,
//                direction: .vertical,
//                steps: steps,
//                fillStyle: .trimToFill(delay: 1)
//            )
//            
//            TimelineView(
//                currentStepIndex: $currentStep,
//                direction: .vertical,
//                steps: steps,
//                fillStyle: .trimToFill(delay: 0.3)
//            )
//            .frame(height: 450)
//            
//            TimelineView(
//                currentStepIndex: $currentStep,
//                direction: .vertical,
//                steps: steps,
//                fillStyle: .solid
//            )
//            .frame(height: 250)
//            
//        }
//        
//        Button {
//            
//            currentStep += 1
//            
//        } label: {
//            
//            Text("Next Step")
//            
//        }
//        
//    }
//    .padding()
//    
//}
//
//#Preview("Horizontal") {
//    
//    @Previewable @State var currentStep = 0
//    
//    let steps: [Step] = [
//        .init(
//            title: "Step 1",
//            selectedTitleFont: .caption,
//            selectedFillColor: .indigo,
//            image: Image(systemName: "person.fill"),
//            imageFillRatio: 0.50
//        ),
//        .init(
//            title: "Step 2",
//            selectedTitleFont: .caption,
//            selectedFillColor: .red,
//            image: Image(systemName: "house.fill"),
//            imageFillRatio: 0.50
//        ),
//        .init(
//            title: "Step 3",
//            selectedTitleFont: .caption,
//        ),
//        .init(
//            title: "Step 4",
//            selectedTitleFont: .caption,
//            selectedFillColor: .pink,
//            image: Image(systemName: "house.fill"),
//            imageFillRatio: 0.50
//        )
//    ]
//    
//    VStack(spacing: 32) {
//        
//        TimelineView(
//            currentStepIndex: $currentStep,
//            direction: .horizontal,
//            steps: steps,
//            fillStyle: .trimToFill(delay: 0.6)
//        )
//        
//        TimelineView(
//            currentStepIndex: $currentStep,
//            direction: .horizontal,
//            steps: steps,
//            fillStyle: .trimToFill(delay: 0.5)
//        )
//        .frame(width: 280)
//        
//        TimelineView(
//            currentStepIndex: $currentStep,
//            direction: .horizontal,
//            steps: steps,
//            fillStyle: .solid
//        )
//        .frame(width: 220)
//        
//        Button {
//            
//            currentStep += 1
//            
//        } label: {
//            
//            Text("Next Step")
//            
//        }
//        
//    }
//    .padding()
//    
//}
