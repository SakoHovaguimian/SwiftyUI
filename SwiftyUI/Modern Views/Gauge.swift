//
//  Gauge.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 4/24/25.
//

import SwiftUI

struct GagueViewTest: View {
    
    @State var value: CGFloat
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Text("Gauge")
                .font(.largeTitle)
            
            ProgressCircle(
                progress: self.value,
                lineWidth: 24
            )
            .frame(width: 128)
            .overlay {
                
                Text("24%")
                    .font(.title3)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.3)
                    .padding(.horizontal, 16)
                
            }
            
            Button("Random Value") {
                
                withAnimation(.linear(duration: 1)) {
                    self.value = Double.random(in: 0...1)
                }

            }
            .buttonStyle(.borderedProminent)
            
        }
        
    }
    
}

#Preview {
    GagueViewTest(value: 0.8)
}

fileprivate struct ProgressCircle: View {
    
    var progress: CGFloat
    var inactiveColor: AppForegroundStyle
    var activeColor: AppForegroundStyle
    var lineWidth: CGFloat
    
    init(progress: CGFloat,
         inactiveColor: AppForegroundStyle = .color(.pink.opacity(0.5)),
         activeColor: AppForegroundStyle = .color(.pink),
         lineWidth: CGFloat = 4) {
        
        self.progress = progress
        self.inactiveColor = inactiveColor
        self.activeColor = activeColor
        self.lineWidth = lineWidth
        
    }
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .stroke(
                    self.inactiveColor.foregroundStyle(),
                    lineWidth: self.lineWidth
                )
            
            Circle()
                .trim(
                    from: 0.0,
                    to: self.progress
                )
                .stroke(
                    self.activeColor.foregroundStyle(),
                    style: StrokeStyle(
                        lineWidth: self.lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(Angle(degrees: -90))
            
        }
        
    }
    
}
