//
//  NuemorphicProgressCircleView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/6/23.
//

import SwiftUI

struct NuemorphicProgressCircleView: View {
    
    @State var timerManager = TimerManager()
    
    @Binding var progress: Double
    @Binding var displayText: String?
    
    var size: CGFloat = 300
    var lineWidth: CGFloat = 20
    
    init(progress: Binding<Double>,
         displayText: Binding<String?> = .constant(nil),
         size: CGFloat,
         lineWidth: CGFloat) {
        
        self._progress = progress
        self._displayText = displayText
        self.size = size
        self.lineWidth = lineWidth

    }
    
    var body: some View {
        
        ZStack {
            
            ZStack{
                
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: self.lineWidth))
                    .frame(
                        width: self.size,
                        height: self.size
                    )
                    .foregroundColor (.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 10, y: 10)
                
//                Circle()
//                    .stroke(style: StrokeStyle(lineWidth: 0))
//                    .frame(
//                        width: size,
//                        height: size
//                    )
//                    .foregroundStyle(LinearGradient(
//                        gradient: Gradient(
//                            colors: [.black.opacity(0.3), .clear]
//                        ),
//                        startPoint: .bottomTrailing,
//                        endPoint: .topLeading
//                    ))
//                    .overlay {
//                        
//                        Circle()
//                            .stroke(.black.opacity(0.1), lineWidth: 2)
//                            .blur(radius: 5)
//                            .mask {
//                                Circle()
//                                    .foregroundStyle(LinearGradient(
//                                        gradient: Gradient(colors: [.black,.clear]),
//                                        startPoint: .topLeading, endPoint: .bottomTrailing
//                                    ))
//                                
//                            }
//                    }
                
                Circle()
                    .trim(
                        from: 0,
                        to: self.timerManager.value
                    )
                    .stroke(style: StrokeStyle(
                        lineWidth: self.lineWidth,
                        lineCap: .round
                    ))
                    .frame(
                        width: self.size,
                        height: self.size
                    )
                    .foregroundColor(Color.green)
                
                Circle()
                    .trim(
                        from: 0,
                        to: self.timerManager.value
                    )
                    .stroke(style: StrokeStyle(
                        lineWidth: self.lineWidth,
                        lineCap: .round
                    ))
                    .frame(
                        width: self.size,
                        height: self.size
                    )
                    .foregroundColor(Color.green)
                    .blur (radius: 15)
                
            }
            .rotationEffect(.degrees (-90))
            
            NumValue(
                displayedValue: self.timerManager.displayedValue,
                color: AppColor.charcoal
            )
            
        }
        .ignoresSafeArea()
        .onTapGesture {
            
            withAnimation(.spring()) {
                
                let newValue = Double.random(in: 0...1)
                self.progress = newValue
                
                self.timerManager
                    .setValue(newValue)
                
                self.timerManager
                    .startTimer()
                
            }
            
        }
        .onAppear {
            
            self.timerManager
                .setValue(self.progress)
            
            self.timerManager
                .displayedValue = self.progress
            
        }
        
    }
    
}


#Preview {
    
    NuemorphicProgressCircleView(
        progress: .constant(0),
        size: 200,
        lineWidth: 15
    )
    
}
