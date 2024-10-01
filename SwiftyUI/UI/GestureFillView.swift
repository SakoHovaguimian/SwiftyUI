//
//  GestureFillView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/28/24.
//

import SwiftUI

enum GestureFillStyle {
    
    case vertical
    case horizontal
    
}

struct GestureFillContainerView: View {
    
    @Binding var currentValue: Int
    var style: GestureFillStyle
    var filledColor: Color = .darkBlue
    var backgroundColor: Color = Color(uiColor: .background3)
    
    init(currentValue: Binding<Int>,
         style: GestureFillStyle,
         filledColor: Color = .darkBlue,
         backgroundColor: Color = Color(uiColor: .background3)) {
        
        self._currentValue = currentValue
        self.style = style
        self.filledColor = filledColor
        self.backgroundColor = backgroundColor
        
    }
    
    var body: some View {
        
        switch style {
        case .vertical:
            
            VerticalGestureFillView(
                currentValue: self.$currentValue,
                filledColor: filledColor,
                backgroundColor: backgroundColor
            )
            
        case .horizontal:
            
            HorizontalGestureFillView(
                currentValue: self.$currentValue,
                filledColor: filledColor,
                backgroundColor: backgroundColor
            )
        }
        
    }
    
}

fileprivate struct VerticalGestureFillView: View {
    
    @Binding var currentValue: Int
    @State var height: CGFloat = 0
    @State var dragOffset: CGFloat = 0
    
    var filledColor: Color
    var backgroundColor: Color
    
    var body: some View {
        
        ZStack(alignment:.bottom) {
            
            Rectangle()
                .frame(
                    width: 60,
                    height: 150
                )
                .foregroundColor(self.backgroundColor)
            
            Rectangle()
                .frame(
                    width: 60,
                    height: min(150, max(0, self.height + self.dragOffset))
                )
                .foregroundStyle(self.filledColor)
            
        }
        .gesture(
            DragGesture()
                .onChanged({ value in
                    
                    withAnimation {
                        
                        self.dragOffset = -value.translation.height * 1.2
                        let newHeight = min(150, max(0, self.height + self.dragOffset))
                        self.currentValue = Int((newHeight / 150) * 100)
                        
                    }
                    
                })
                .onEnded({ value in
                    
                    let maxValue = self.height + self.dragOffset
                    self.height = min(150, max(0, maxValue))
                    self.dragOffset = 0
                    
                })
            
        )
        .clipShape(.rect(cornerRadius: 20))
        .frame(height: 150)
        .overlay {
            
            Text("\(self.currentValue)%")
                .font(.title3)
                .foregroundStyle(.white)
                .contentTransition(.numericText())
            
        }
        
    }
}

fileprivate struct HorizontalGestureFillView: View {
    
    @Binding var currentValue: Int
    @State var width: CGFloat = 0
    @State var dragOffset: CGFloat = 0
    
    var filledColor: Color
    var backgroundColor: Color
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            Rectangle()
                .frame(
                    width: 150,
                    height: 60
                )
                .foregroundColor(self.backgroundColor)
            
            Rectangle()
                .frame(
                    width: min(150, max(0, self.width + self.dragOffset)),
                    height: 60
                )
                .foregroundStyle(self.filledColor)
            
        }
        .gesture(
            DragGesture()
                .onChanged({ value in
                    
                    withAnimation {
                        
                        self.dragOffset = value.translation.width * 1.2
                        let newWidth = min(150, max(0, self.width + self.dragOffset))
                        self.currentValue = Int((newWidth / 150) * 100)
                        
                    }
                    
                })
                .onEnded({ value in
                    
                    let maxValue = self.width + self.dragOffset
                    self.width = min(150, max(0, maxValue))
                    self.dragOffset = 0
                    
                })
            
        )
        .clipShape(.rect(cornerRadius: 20))
        .frame(width: 150)
        .overlay {
            
            Text("\(self.currentValue)%")
                .font(.title3)
                .foregroundStyle(.white)
                .contentTransition(.numericText())
            
        }
        
    }
}

#Preview {
    
    @Previewable @State var verticalCurrentValue: Int = 0
    @Previewable @State var horizontalCurrentValue: Int = 0
    
    ZStack {
        
        Color.background1
            .ignoresSafeArea()
        
        VStack(spacing: 64) {
            
            VStack(alignment: .leading) {
                
                Text("Vertical: \(verticalCurrentValue)")
                    .foregroundStyle(.brandGreen)
                    .font(.title)
                    .fontWeight(.ultraLight)
                    .fontDesign(.monospaced)
                    .contentTransition(.numericText(value: Double(verticalCurrentValue)))
                
                Text("Horiztonal: \(horizontalCurrentValue)")
                    .foregroundStyle(.brandGreen)
                    .font(.title)
                    .fontWeight(.ultraLight)
                    .fontDesign(.monospaced)
                    .contentTransition(.numericText(value: Double(horizontalCurrentValue)))
                
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            GestureFillContainerView(currentValue: $horizontalCurrentValue, style: .horizontal)
            GestureFillContainerView(currentValue: $verticalCurrentValue, style: .vertical)
            
        }
        
    }
    
}
