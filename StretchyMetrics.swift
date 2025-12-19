//
//  StretchyMetrics.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/18/25.
//

import SwiftUI

public extension View {
    
    func stretchy(axis: Axis = .vertical,
                  uniform: Bool = false) -> some View {

        self.visualEffect { effect, geometry in

            let frame = geometry.frame(in: .scrollView)

            let offset: CGFloat
            let currentLength: CGFloat

            switch axis {
            case .vertical:
                
                offset = frame.minY
                currentLength = geometry.size.height
                
            case .horizontal:
                
                offset = frame.minX
                currentLength = geometry.size.width
            }

            let positiveOffset = max(0, offset)
            let safeLength = max(currentLength, 0.0001)
            let scale = (currentLength + positiveOffset) / safeLength

            let anchor: UnitPoint = (axis == .vertical)
                ? .bottom
                : .trailing

            if uniform {
                
                return effect.scaleEffect(
                    x: scale,
                    y: scale,
                    anchor: anchor
                )
                
            } else {
                
                return effect.scaleEffect(
                    x: (axis == .horizontal) ? scale : 1,
                    y: (axis == .vertical) ? scale : 1,
                    anchor: anchor
                )
                
            }
            
        }
        
    }
    
}

#Preview {
    
    struct HorizontalView: View {
        
        @State private var size: CGSize = .init(width: 200, height: 200)
        
        var body: some View {
            
            ScrollView(.horizontal) {
                
                HStack {
                    
                    ZStack {
                        
                        Rectangle()
                            .fill(.purple.opacity(0.5))
                        
                        Rectangle()
                            .fill(Color.purple.opacity(0.4))
                            .blur(radius: 3)
                            .padding(4)
                        
                        Text("Header")
                            .foregroundColor(.white)
                            .padding(50)
                        
                    }
                    .frame(height: size.height)
                    .stretchy(axis: .horizontal, uniform: true)
                    
                    ForEach(0...30, id: \.self) { _ in
                        
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: size.width, height: size.height)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    return HorizontalView()
    
}

#Preview {
    
    struct VerticalView: View {

        var body: some View {
            
            ScrollView(.vertical) {
                
                VStack {
                    
                    ZStack {
                        
                        Image(.image3)
                            .resizable()
                        
                        Text("Header")
                            .foregroundColor(.white)
                            .padding(50)
                        
                    }
                    .frame(height: 300)
                    .stretchy(axis: .vertical, uniform: true)
                    
                    ForEach(0...30, id: \.self) { _ in
                        
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .frame(height: 150)
                        
                    }
                    
                }
                
            }
            .ignoresSafeArea(edges: [.top])
            
        }
        
    }
    
    return VerticalView()
    
}
