//
//  SegmentedProgressView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 11/21/25.
//

import SwiftUI

struct SegmentedProgressView: View {
    // Configuration
    var progress: Double = 0.84 // 0.0 to 1.0
    var segmentCount: Int = 40  // Number of ticks
    var trackColor: Color = Color.gray.opacity(0.15)
    var progressColor: Color = Color(red: 0.8, green: 0.25, blue: 0.45) // Custom Pink
    var textColor: Color = Color(red: 0.25, green: 0.45, blue: 1.0) // Custom Blue
    
    var body: some View {
        ZStack {
            // 1. The Text in the center
//            Text("\(Int(progress * 100))%")
//                .frame(maxWidth: .infinity)
//                .font(.system(size: 50, weight: .bold, design: .default))
//                .foregroundColor(textColor)
//            
            // 2. GeometryReader to calculate exact dash sizes dynamically
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                let strokeWidth = size * 0.15 // Scale thickness relative to size
                let radius = (size - strokeWidth) / 2
                let circumference = 2 * .pi * radius
                
                // Calculate dash size to fit exactly 'segmentCount' items
                let dashLength = circumference / Double(segmentCount) * 0.6 // 60% dash
                let gapLength = circumference / Double(segmentCount) * 0.4  // 40% gap
                
                ZStack {
                    // Background Track
                    Circle()
                        .stroke(
                            trackColor,
                            style: StrokeStyle(
                                lineWidth: strokeWidth,
                                lineCap: .round,
                                dash: [dashLength, gapLength]
                            )
                        )
                    
                    // Foreground Progress
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            progressColor,
                            style: StrokeStyle(
                                lineWidth: strokeWidth,
                                lineCap: .round,
                                dash: [dashLength, gapLength]
                            )
                        )
                        .rotationEffect(.degrees(-90)) // Start from top (12 o'clock)
                }
                // Center the circles in the GeometryReader space
                .frame(width: size, height: size)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
        .padding(20) // Padding to prevent clipping
    }
}

struct ProgressPreview: View {
    
    @State var progress: Double = 0.84
    @State var progress2: Double = 0.44
    @State var progress3: Double = 0.34
    
    var body: some View {
        
        ZStack {
            
            SegmentedProgressView(progress: progress)
                .contentTransition(.numericText(value: progress))
                .frame(width: 300, height: 300)
                .onTapGesture {
                    
                    withAnimation {
                        progress = Double.random(in: 0...1)
                    }
                    
                }
            
        }
        
    }
    
}

#Preview {
    ProgressPreview()
}
