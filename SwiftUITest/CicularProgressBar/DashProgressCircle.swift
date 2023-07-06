//
//  DashProgressCircleView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/6/23.
//

import SwiftUI

// Passing values to and from TimerManger up to parent
/// Probably going to have to store 2 variables and onChange pass the new one back up to the parent.

// Remove Text From circle, Dev should add it in ZStack themselves...
// Let displayText be bindable for Dev to use

struct DashProgressCircleView: View {
    
    @State var timerManager = TimerManager()
    
    @Binding var progress: Double
    @Binding var displayText: String?
    
    var size: CGFloat = 300
    var lineWidth: CGFloat = 20
    var dashes: [CGFloat] = [4.5]
    
    init(progress: Binding<Double>,
         displayText: Binding<String?> = .constant(nil),
         size: CGFloat,
         lineWidth: CGFloat,
         dashes: [CGFloat]) {
        
        self._progress = progress
        self._displayText = displayText
        self.size = size
        self.lineWidth = lineWidth
        self.dashes = dashes
    }
    
    var body: some View {
        
        ZStack {
            
            AppColor.charcoal
                .opacity(1)
            
            ZStack{
                
                Circle()
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: self.lineWidth,
                            dash: self.dashes
                        ))
                    .frame(
                        width: self.size,
                        height: self.size
                    )
                
                Circle()
                    .trim(
                        from: 0,
                        to: self.timerManager.value
                    )
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: self.lineWidth,
                            dash: self.dashes
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
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: self.lineWidth,
                            dash: self.dashes
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
                color: .white
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
    
    DashProgressCircleView(
        progress: .constant(0.5),
        size: 280,
        lineWidth: 20,
        dashes: [5]
    )
    
}

struct NumValue: View {
    
    var displayedValue : CGFloat
    var color : Color
    var body: some View {
        
        Text ("\(Int(self.displayedValue * 100))%")
            .bold()
            .font (.largeTitle)
            .foregroundColor (self.color)
        
    }
    
}
