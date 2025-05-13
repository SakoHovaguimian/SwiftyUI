//
//  SegmentedCircleView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 5/12/25.
//


import SwiftUI

public struct SegmentedCirclePathView: View {
    
    public struct Item {
        
        /// `percentage` range is 0-100
        let percentage: Double
        let color: Color
        
    }
    
    let items: [Item]
    let lineWidth: CGFloat
    let rotationAngle: Angle
    
    public init(items: [Item],
                lineWidth: CGFloat = 12,
                rotationAngle: Angle = .degrees(-90)) {
        
        self.items = items
        self.lineWidth = lineWidth
        self.rotationAngle = rotationAngle
        
    }
    
    public var body: some View {
        
        GeometryReader { geo in
            
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(
                x: geo.size.width / 2,
                y: geo.size.height / 2
            )
            let radius = (size - lineWidth) / 2
            
            ZStack {
                
                // Background
                
                Path { path in
                    
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360),
                        clockwise: false
                    )
                    
                }
                .stroke(
                    Color.gray.opacity(1),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .butt
                    )
                )
                
                // Segments
                
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    
                    let (startDeg, endDeg) = angles[index]
                    
                    Path { path in
                        
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: .degrees(startDeg),
                            endAngle: .degrees(endDeg),
                            clockwise:  false
                        )
                        
                    }
                    .stroke(
                        item.color,
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .butt
                        )
                    )
                    .zIndex(Double(index))
                    
                }
                
            }
            
            // rotate so “0%” begins at 12‑o’clock
            .phaseAnimator([false, true], trigger: self.rotationAngle) { view, bool in
                view.rotationEffect(self.rotationAngle)
            } animation: { bool in
                return .bouncy(duration: 3)
            }
            
        }
        
    }
    
    /// Precompute each segment’s start/end angles in degrees (0…360)
    private var angles: [(start: Double, end: Double)] {
        
        var result: [(Double,Double)] = []
        var cursor: Double = 0
        
        for item in items {
            
            let sweep = item.percentage / 100 * 360
            result.append((cursor, cursor + sweep))
            cursor += sweep
            
        }
        
        return result
        
    }
    
}

#Preview {
    
    SegmentedCirclePathView(
        items: [
            .init(
                percentage: 25,
                color: .red
            ),
            .init(
                percentage: 25,
                color: .green
            ),
            .init(
                percentage: 50,
                color: .blue
            )
        ]
    )
    .frame(height: 240)
    .padding(.horizontal, .xLarge)
    
}
