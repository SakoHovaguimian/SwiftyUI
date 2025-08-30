//
//  Shapes.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/5/25.
//

import SwiftUI

struct Star: Shape {
    
    let corners: Int
    let smoothness: Double
    
    func path(in rect: CGRect) -> Path {
        
        guard corners >= 2 else { return Path() }
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        var currentAngle = -CGFloat.pi / 2
        let angleAdjustment = .pi * 2 / CGFloat(self.corners * 2)
        let innerRadius = rect.width / 4 * self.smoothness
        let outerRadius = rect.width / 2
        
        var path = Path()
        
        for corner in 0..<self.corners * 2 {
            let radius = (corner % 2 == 0) ? outerRadius : innerRadius
            let x = center.x + CGFloat(cos(currentAngle)) * radius
            let y = center.y + CGFloat(sin(currentAngle)) * radius
            
            if corner == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            currentAngle += angleAdjustment
        }
        
        path.closeSubpath()
        return path
        
    }
    
}

struct Heart: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width / 2, y: height / 4))
        
        path.addCurve(to: CGPoint(x: 0, y: height / 2.5),
                      control1: CGPoint(x: width / 2, y: 0),
                      control2: CGPoint(x: 0, y: height / 5))
        
        path.addCurve(to: CGPoint(x: width / 2, y: height),
                      control1: CGPoint(x: 0, y: height * 0.6),
                      control2: CGPoint(x: width / 2, y: height * 0.8))
        
        path.addCurve(to: CGPoint(x: width, y: height / 2.5),
                      control1: CGPoint(x: width / 2, y: height * 0.8),
                      control2: CGPoint(x: width, y: height * 0.6))
        
        path.addCurve(to: CGPoint(x: width / 2, y: height / 4),
                      control1: CGPoint(x: width, y: height / 5),
                      control2: CGPoint(x: width / 2, y: 0))
        
        path.closeSubpath()
        return path
        
    }
    
}
