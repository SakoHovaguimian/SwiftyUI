//
//  AppProgressBar.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 11/16/24.
//

import SwiftUI

struct AppProgressBar: View {
    
    private var trackStyle: AppForegroundStyle
    private var fillStyle: AppForegroundStyle
    private var thumbStyle: AppForegroundStyle
    private var thumbCircleStyle: AppForegroundStyle
    
    @Binding var value: Double
    
    private var thumbRadius: CGFloat = 15
    
    init(value: Binding<Double>,
         trackStyle: AppForegroundStyle,
         fillStyle: AppForegroundStyle,
         thumbStyle: AppForegroundStyle = .color(.white),
         thumbCircleStyle: AppForegroundStyle = .color(.brandGreen)) {
        
        self._value = value
        self.trackStyle = trackStyle
        self.fillStyle = fillStyle
        self.thumbStyle = thumbStyle
        self.thumbCircleStyle = thumbCircleStyle
        
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .leading) {

                track(geometry: geometry)
                fill(geometry: geometry)
                thumb(geometry: geometry)
                    
                .gesture(
                    DragGesture( minimumDistance: 0)
                        .onChanged { gesture in
                            
                            updateValue(
                                with: gesture,
                                in: geometry
                            )
                            
                        }
                )
            }
            
        }
        .frame(maxHeight: 40)
        
    }
    
    private func track(geometry: GeometryProxy) -> some View {
        
        self.trackStyle
            .viewStyle()
            .frame(
                width: geometry.size.width,
                height: 10
            )
            .cornerRadius(5)
        
    }
    
    private func fill(geometry: GeometryProxy) -> some View {
        
        self.fillStyle
            .viewStyle()
            .frame(
                width: geometry.size.width * CGFloat(value),
                height: 10
            )
            .cornerRadius(5)
        
    }
    
    private func thumb(geometry: GeometryProxy) -> some View {
        
        ZStack {
            
            ZStack {
                
                Circle()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(self.thumbStyle.foregroundStyle())
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Circle()
                    .stroke(self.thumbStyle.foregroundStyle(), lineWidth: 1)
                    .frame(width: 32, height: 32)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                
            }
            .offset(x: CGFloat(value) * geometry.size.width - self.thumbRadius)
            
            Circle()
                .fill(self.thumbCircleStyle.foregroundStyle())
                .frame(width: 10, height: 10)
                .offset(x: CGFloat(value) * geometry.size.width - self.thumbRadius)
            
        }
        
    }
    
    private func updateValue(with gesture: DragGesture.Value,
                             in geometry: GeometryProxy) {
        
        let newValue = gesture.location.x / geometry.size.width
        value = min(max(Double(newValue), 0), 1)
        
    }
    
    private func circleOffset(x: CGFloat,
                              y: CGFloat) -> (x: CGFloat, y: CGFloat) {
        
        let thumbRadius: CGFloat = 15
        let circleRadius: CGFloat = 5
        let angle = 2 * CGFloat.pi * CGFloat(value)
        let x = (thumbRadius - circleRadius) * cos(angle)
        let y = (thumbRadius - circleRadius) * sin(angle)
        return (x: x, y: y)
        
    }
    
}

#Preview {
    
    @Previewable @State var progress: Double = 0.0
    
    Text("\(progress, format: .percent.precision(.fractionLength(2)))")
    
    VStack {
        
        AppProgressBar(
            value: $progress,
            trackStyle: .color(Color(UIColor.systemGray6)),
            fillStyle: .color(.brandGreen)
        )
        .frame(maxWidth: .infinity)
        
        AppProgressBar(
            value: $progress,
            trackStyle: .color(Color(uiColor: .charcoal)),
            fillStyle: .linearGradient(.linearGradient(
                colors: [
                    .indigo,
                    .purple
                ],
                startPoint: .leading,
                endPoint: .trailing
            )),
            thumbStyle: .linearGradient(.linearGradient(
                colors: [
                    .indigo,
                    .purple
                ],
                startPoint: .leading,
                endPoint: .trailing
            )),
            thumbCircleStyle: .color(.white)
        )
        .frame(maxWidth: .infinity)
        
        AppProgressBar(
            value: $progress,
            trackStyle: .color(Color(uiColor: .lightGray).opacity(0.2)),
            fillStyle: .linearGradient(.linearGradient(
                colors: [
                    .green,
                    .mint
                ],
                startPoint: .leading,
                endPoint: .trailing
            )),
            thumbStyle: .color(.mint),
            thumbCircleStyle: .color(.white)
        )
        .frame(maxWidth: .infinity)
        
    }
    .padding(.horizontal, .large)

    
}
