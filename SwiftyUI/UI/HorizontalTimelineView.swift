//
//  HorizontalTimelineView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/7/24.
//

import SwiftUI

struct Step {
    var title: String
}

struct HorizontalTimelineView: View {
    
    let steps: [Step]
    
    @Binding var currentStep: Int
    
    var activeColor: Color = .green
    var inactiveColor: Color = .gray
    var textColor: Color = .black
    
    var iconSize: CGFloat = 32
    var lineWidth: CGFloat = 3
    
    var animationDuration: CGFloat = 0.8
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 0) {
            
            ForEach(self.steps.indices, id: \.self) { index in

                circleView(index: index)
                
                if index < self.steps.count - 1 {
                    
                    lineView(index: index)
                        .padding(.top, self.iconSize / 2)
                    
                }
                
            }
            
        }
        
    }
    
    private func circleView(index: Int) -> some View {
        
        let shouldHighlight = self.currentStep > index
        
        return VStack {
            
            Circle()
                .stroke(lineWidth: self.lineWidth)
                .frame(width: self.iconSize, height: self.iconSize)
                .foregroundStyle(index < self.currentStep ? self.activeColor : self.inactiveColor)
            
                .overlay {
                    
                    VStack {
                        
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: self.iconSize, height: self.iconSize)
                            .foregroundStyle(self.activeColor)
                            .scaleEffect(shouldHighlight ? 1 : 0)
                            .offset(y: shouldHighlight ? 0 : 30)
                            .opacity(shouldHighlight ? 1 : 0)
                        
                    }
                    
                }
            
            VStack {
                
                Rectangle()
                    .fill(.clear)
                    .frame(width: self.iconSize, height: 10)
                    .overlay {
                        
                        Text(self.steps[index].title)
                            .fixedSize()
                            .foregroundColor(self.textColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .appFont(with: shouldHighlight ? .title(.t2) : .body(.b1))
                        
                    }
                
            }
            
        }
        .animation(
            .easeInOut(duration: self.animationDuration),
            value: self.currentStep
        )
        
    }
    
    private func lineView(index: Int) -> some View {
        
        ZStack(alignment: .leading) {
            
            Rectangle()
                .frame(height: self.lineWidth)
                .foregroundStyle(self.inactiveColor)
                .transition(.move(edge: .leading))
            
            if index <= self.currentStep {
                
                Rectangle()
                    .frame(height: self.lineWidth)
                    .frame(maxWidth: index >= self.currentStep ? 0 : .infinity, alignment: .leading)
                    .foregroundStyle(self.activeColor)
                    .transition(.move(edge: .leading))
                
            }
            
        }
        .animation(.smooth(duration: self.animationDuration + 0.3), value: self.currentStep)
        
    }
    
}

fileprivate struct HorizontalTimelineViewTest: View {
    
    @State private var currentStep = 0
    
    let steps: [Step] = [
        Step(title: "Step 1"),
        Step(title: "Step 2"),
        Step(title: "Step 3"),
        Step(title: "Step 4")
    ]
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            HorizontalTimelineView(
                steps: steps,
                currentStep: $currentStep,
                activeColor: .green,
                inactiveColor: .gray,
                textColor: .black
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

#Preview {
    HorizontalTimelineViewTest()
}
