//
//  File.swift
//
//
//  Created by Nick Sarno on 2/10/24.
//

import Foundation
import SwiftUI

struct StetchyHeaderViewModifier: ViewModifier {
    
    private var startingHeight: CGFloat = 300
    private var coordinateSpace: CoordinateSpace = .global
    private var shouldScaleOnStrech: Bool = false
    
    init(startingHeight: CGFloat,
         coordinateSpace: CoordinateSpace = .global,
         shouldScaleOnStrech: Bool = false) {
        
        self.startingHeight = startingHeight
        self.coordinateSpace = coordinateSpace
        self.shouldScaleOnStrech = shouldScaleOnStrech
        
    }
    
    func body(content: Content) -> some View {
        
        GeometryReader(content: { geometry in
            
            let diff = (stretchedHeight(geometry) / startingHeight)
            
            content
                .frame(width: geometry.size.width, height: stretchedHeight(geometry))
                .clipped()
                .offset(y: stretchedOffset(geometry))
                .scaleEffect(self.shouldScaleOnStrech ? diff : 1)
            
        })
        .frame(height: startingHeight)
    }
    
    private func yOffset(_ geo: GeometryProxy) -> CGFloat {
        geo.frame(in: coordinateSpace).minY
    }
    
    private func stretchedHeight(_ geo: GeometryProxy) -> CGFloat {
        let offset = yOffset(geo)
        return offset > 0 ? (startingHeight + offset) : startingHeight
    }
    
    private func stretchedOffset(_ geo: GeometryProxy) -> CGFloat {
        let offset = yOffset(geo)
        return offset > 0 ? -offset : 0
    }
}

public extension View {
    
    func asStretchyHeader(startingHeight: CGFloat,
                          shouldScaleOnStrech: Bool = false) -> some View {
        modifier(StetchyHeaderViewModifier(
            startingHeight: startingHeight,
            shouldScaleOnStrech: shouldScaleOnStrech
        ))
        
    }
    
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        
        ScrollView {
            VStack {
                Rectangle()
                    .fill(Color.green)
                    .overlay(
                        ZStack {
                            AsyncImage(url: URL(string: "https://picsum.photos/800/800"))
                                .aspectRatio(contentMode: .fit)
                        }
                        //                        Image(systemName: "heart.fill")
                        //                            .resizable()
                        //                            .scaledToFill()
                        //                            .padding(100)
                    )
                    .asStretchyHeader(startingHeight: 300, shouldScaleOnStrech: true)
                
                Rectangle()
                    .fill(Color.green)
                    .frame(height: 500)
            }
        }
    }
}
