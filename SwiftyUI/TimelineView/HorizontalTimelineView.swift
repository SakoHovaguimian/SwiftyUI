//
//  HorizontalTimelineView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/7/24.
//

import SwiftUI

public struct Step: Identifiable {
    
    public let id: String = UUID().uuidString
    public let title: String
    
    public let selectedTitleFont: Font
    public let unselectedTitleFont: Font
    
    public let selectedTitleColor: Color
    public let unselectedTitleColor: Color
    
    public let selectedFillColor: Color
    public let unselectedFillColor: Color
    
    public let image: Image
    public let imageSize: CGFloat
    public let imageFillRatio: CGFloat
    
    public init(title: String,
         selectedTitleFont: Font = .title3,
         unselectedTitleFont: Font = .body,
         selectedFillColor: Color = .green,
         unselectedFillColor: Color = .gray,
         selectedTitleColor: Color = .black,
         unselectedTitleColor: Color = .gray,
         image: Image = Image(systemName: "checkmark"),
         imageSize: CGFloat = 32,
         imageFillRatio: CGFloat = 0.45) {
        
        self.title = title
        self.selectedTitleFont = selectedTitleFont
        self.unselectedTitleFont = unselectedTitleFont
        self.selectedFillColor = selectedFillColor
        self.unselectedFillColor = unselectedFillColor
        self.selectedTitleColor = selectedTitleColor
        self.unselectedTitleColor = unselectedTitleColor
        self.image = image
        self.imageSize = imageSize
        self.imageFillRatio = imageFillRatio
        
    }
    
}

public struct HorizontalTimelineView: View {
    
    @Binding var currentStep: Int
    
    let steps: [Step]
    let circleSize: CGFloat
    let lineWidth: CGFloat
    let animationDuration: CGFloat
    
    public init(currentStep: Binding<Int>,
                steps: [Step],
                circleSize: CGFloat = 32,
                lineWidth: CGFloat = 3,
                animationDuration: CGFloat = 0.5) {
        
        self._currentStep = currentStep
        self.steps = steps
        self.circleSize = circleSize
        self.lineWidth = lineWidth
        self.animationDuration = animationDuration
        
    }
    
    public var body: some View {
        
        HStack(alignment: .center, spacing: 0) {
            
            ForEach(self.steps.indices, id: \.self) { index in
                stepView(index: index)
            }
            
        }
        
    }
    
    private func stepView(index: Int) -> some View {
        
        let currentStep = self.steps[index]
        let shouldHighlight = (self.currentStep > index)
        let imageScale = currentStep.imageSize * currentStep.imageFillRatio
        let fillColor = index < self.currentStep ? currentStep.selectedFillColor : currentStep.unselectedFillColor
        let titleColor = shouldHighlight ? currentStep.selectedTitleColor : currentStep.unselectedTitleColor
        
        return VStack(alignment: .leading) {
            
            HStack(alignment: .top, spacing: 0) {
                
                Circle()
                    .stroke(lineWidth: self.lineWidth)
                    .frame(
                        width: self.circleSize,
                        height: self.circleSize
                    )
                    .foregroundStyle(fillColor)
                
                    .overlay {
                        
                        if shouldHighlight {
                            
                            currentStep
                                .image
                                .resizable()
                                .frame(
                                    width: imageScale,
                                    height: imageScale
                                )
                                .foregroundStyle(.white)
                                .transition(.blurReplace(.downUp))
                                .background {
                                    
                                    Circle()
                                        .fill(currentStep.selectedFillColor)
                                        .frame(
                                            width: self.circleSize,
                                            height: self.circleSize
                                        )
                                    
                                }
                            
                        }
                        
                    }
                
                if index < self.steps.count - 1 {
                    
                    lineView(index: index)
                        .padding(.top, self.circleSize / 2)
                    
                }
                
            }
            
            Rectangle()
                .fill(.clear)
                .frame(width: self.circleSize, height: 10)
                .overlay {
                    
                    Text(currentStep.title)
                        .fixedSize()
                        .foregroundColor(titleColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .appFont(with: shouldHighlight ? .title(.t2) : .body(.b1))
                    
                }
            
        }
        .animation(
            .easeInOut(duration: self.animationDuration),
            value: self.currentStep
        )
        
    }
    
    private func lineView(index: Int) -> some View {
        
        let currentStep = self.steps[index]
        let shouldHighlight = index >= self.currentStep
        
        return ZStack(alignment: .leading) {
            
            Rectangle()
                .frame(height: self.lineWidth)
                .foregroundStyle(currentStep.unselectedFillColor)
            
            Rectangle()
                .frame(height: self.lineWidth)
                .frame(maxWidth: shouldHighlight ? 0 : .infinity, alignment: .leading)
                .foregroundStyle(currentStep.selectedFillColor)
            
        }
        .animation(
            .smooth(duration: self.animationDuration + 0.3).delay(0.5),
            value: self.currentStep
        )
        
    }
    
}

struct HorizontalTimelineViewTest: View {
    
    @State private var currentStep = 0
    
    let steps: [Step] = [
        .init(title: "Step 1", selectedFillColor: .indigo, image: Image(systemName: "person.fill"), imageFillRatio: 0.50),
        .init(title: "Step 2", selectedFillColor: .darkRed, image: Image(systemName: "house.fill"), imageFillRatio: 0.50),
        .init(title: "Step 3"),
        .init(title: "Step 4")
    ]
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            HorizontalTimelineView(
                currentStep: $currentStep,
                steps: steps
            )
            
            Button {
                
                currentStep += 1
                
            } label: {
                
                Text("Next Step")
                
            }
            
        }
        .padding()
        
    }
    
}

#Preview("Horiztonal") {
    HorizontalTimelineViewTest()
}

public struct VerticalTimelineView2: View {
    
    @Binding var currentStep: Int
    
    let steps: [Step]
    let circleSize: CGFloat
    let lineWidth: CGFloat
    let animationDuration: CGFloat
    
    public init(currentStep: Binding<Int>,
                steps: [Step],
                circleSize: CGFloat = 32,
                lineWidth: CGFloat = 3,
                animationDuration: CGFloat = 0.5) {
        
        self._currentStep = currentStep
        self.steps = steps
        self.circleSize = circleSize
        self.lineWidth = lineWidth
        self.animationDuration = animationDuration
        
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            ForEach(self.steps.indices, id: \.self) { index in
                stepView(index: index)
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func stepView(index: Int) -> some View {
        
        let currentStep = self.steps[index]
        let shouldHighlight = (self.currentStep > index)
        let imageScale = currentStep.imageSize * currentStep.imageFillRatio
        let fillColor = index < self.currentStep ? currentStep.selectedFillColor : currentStep.unselectedFillColor
        let titleColor = shouldHighlight ? currentStep.selectedTitleColor : currentStep.unselectedTitleColor
        
        return HStack(alignment: .top) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                HStack {
                    
                    Circle()
                        .stroke(lineWidth: self.lineWidth)
                        .foregroundStyle(fillColor)
                    
                        .overlay {
                            
                            if shouldHighlight {
                                
                                currentStep
                                    .image
                                    .resizable()
                                    .frame(
                                        width: imageScale,
                                        height: imageScale
                                    )
                                    .foregroundStyle(.white)
                                    .transition(.blurReplace(.downUp))
                                    .background {
                                        
                                        Circle()
                                            .fill(currentStep.selectedFillColor)
                                            .frame(
                                                width: self.circleSize,
                                                height: self.circleSize
                                            )
                                        
                                    }
                                
                            }
                            
                        }
                    
                    
                    Text(currentStep.title)
                        .fixedSize()
                        .foregroundColor(titleColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .font(shouldHighlight ? currentStep.selectedTitleFont : currentStep.unselectedTitleFont)
                    
                }
                .frame(height: self.circleSize)
                
                if index < self.steps.count - 1 {
                    
                    lineView(index: index)
                        .padding(.leading, self.circleSize / 2 - 1.5)
                    
                }
                
            }
            
        }
        .animation(
            .easeInOut(duration: self.animationDuration),
            value: self.currentStep
        )
        
    }
    
    private func lineView(index: Int) -> some View {
        
        let currentStep = self.steps[index]
        let shouldHighlight = self.currentStep > index
        
        return ZStack(alignment: .top) {
            
            Rectangle()
                .frame(width: self.lineWidth)
                .foregroundStyle(currentStep.unselectedFillColor)
            
            Rectangle()
                .frame(width: self.lineWidth)
                .frame(height: shouldHighlight ? .infinity : 0)
                .foregroundStyle(currentStep.selectedFillColor)
            
        }
        .animation(
            .smooth(duration: self.animationDuration + 0.3).delay(0.5),
            value: self.currentStep
        )
        
    }
    
}

struct VerticalTimelineViewTest: View {
    
    @State private var currentStep = 0
    
    let steps: [Step] = [
        .init(title: "Step 1", selectedFillColor: .indigo, image: Image(systemName: "person.fill"), imageFillRatio: 0.50),
        .init(title: "Step 2", selectedFillColor: .darkRed, image: Image(systemName: "house.fill"), imageFillRatio: 0.50),
        .init(title: "Step 3"),
        .init(title: "Step 4")
    ]
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            HStack(spacing: 32) {
                
                VerticalTimelineView2(
                    currentStep: $currentStep,
                    steps: steps
                )
                
                VerticalTimelineView2(
                    currentStep: $currentStep,
                    steps: steps
                )
                .frame(height: 450)
                
                VerticalTimelineView2(
                    currentStep: $currentStep,
                    steps: steps
                )
                .frame(height: 250)
                
            }
            
            Button {
                
                currentStep += 1
                
            } label: {
                
                Text("Next Step")
                
            }
            
        }
        .padding()
        
    }
    
}

#Preview("Vertical") {
    VerticalTimelineViewTest()
}
