//
//  ZigZagShape.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/25.
//

import SwiftUI

struct ZigZagBottom: Shape {
    
    var depth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        
        var p = Path()

        // Draw the top border
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))

        // Draw the right border
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        // Draw the bottom border with zigzag or straight line if depth is 0
        if depth == 0 {
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        } else {
            
            drawZigzag(
                path: &p,
                from: CGPoint(
                    x: rect.maxX,
                    y: rect.maxY
                ),
                to: CGPoint(
                    x: rect.minX,
                    y: rect.maxY
                ),
                height: depth
            )
            
        }

        // Draw the left border
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        p.closeSubpath()

        return p
        
    }

    private func drawZigzag(path: inout Path,
                            from start: CGPoint,
                            to end: CGPoint,
                            height: CGFloat) {
        
        let length = start.x - end.x
        let numberOfZigzags = Int(length / (height * 2))
        let zigzagLength = length / CGFloat(numberOfZigzags * 2)

        for i in 0..<numberOfZigzags {
            
            let offset = CGFloat(i * 2)
            let point1 = CGPoint(x: start.x - offset * zigzagLength, y: start.y)
            let point2 = CGPoint(x: start.x - (offset + 1) * zigzagLength, y: start.y - height)
            let point3 = CGPoint(x: start.x - (offset + 2) * zigzagLength, y: start.y)

            path.addLine(to: point1)
            path.addLine(to: point2)
            path.addLine(to: point3)
            
        }

        path.addLine(to: end)
        
    }
    
}

//usage
#Preview("Image") {
    
    @Previewable @State var zigZagDepth: CGFloat = 0
    
    VStack {
        
        Image(.image1)
            .resizable()
            .scaledToFill()
            .frame(height: 300)
            .mask {
                
                ZigZagBottom(depth: zigZagDepth)
                    .fill(.black)
                    .frame(width: .infinity, height: .infinity)
                    .animation(.smooth, value: zigZagDepth)
                
            }

        Spacer()

        Text("Zig Zag border in SwiftUI")
            .font(.largeTitle)
            .bold().multilineTextAlignment(.center)
            .padding()
        
        Slider(value: $zigZagDepth, in: 0...24)
            .padding(.horizontal, .large)

        Spacer()
        
    }
    .ignoresSafeArea(.all)
    
}
