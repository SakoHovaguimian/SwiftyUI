//
//  ParticleDrag.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/3/25.
//

import SwiftUI

struct ParticleDrag: View {
    
    @State private var spikes: [CGPoint] = []
    @GestureState private var mangetPosition: CGPoint? = nil
    
    var body: some View {
        
        canvas()
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating(self.$mangetPosition, body: { value, state, _ in
                        state = value.location
                    })
            )
        
    }
    
    private func canvas() -> some View {
        
        Canvas { context, size in
            
            if let mangetPosition {
                
                let stride = stride(
                    from: 0,
                    to: CGFloat.pi * 2,
                    by: CGFloat.pi / 16
                )
                
                for angle in stride {
                 
                    pathForStride(
                        context: context,
                        angle: angle,
                        mangetPosition: mangetPosition
                    )
                    
                }
                
            }
            
        }
        
    }
    
    private func pathForStride(context: GraphicsContext,
                               angle: CGFloat,
                               mangetPosition: CGPoint) {
        
        let distance = CGFloat.random(in: 50...100)
        let spike = CGPoint(
            x: mangetPosition.x + cos(angle) * distance,
            y: mangetPosition.y + sin(angle) * distance
        )
        let path = Path { path in
            
            path.move(to: mangetPosition)
            path.addLine(to: spike)
            
        }
        
        context.stroke(
            path,
            with: .color(.darkBlue.opacity(0.5)),
            lineWidth: 1
        )
        
    }
    
}

#Preview {
    
    ParticleDrag()
    
}
