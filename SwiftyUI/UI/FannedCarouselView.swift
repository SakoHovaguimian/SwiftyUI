//
//  file.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 10/10/24.
//

import SwiftUI

struct FannedCarouselView: View {
    
    var images: [ImageModel]
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let size = geometry.size
            
            ScrollView(.horizontal) {
                
                LazyHStack(spacing: 0) {
                    
                    ForEach(images) { image in
                        
                        image.image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 220, maxHeight: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                
                                content
//                                    .blur(radius: phase == .identity ? 0 : 2, opaque: false)
                                    .scaleEffect(phase == .identity ? 1 : 0.9, anchor: .bottom)
                                    .offset(y: phase == .identity ? 0 : 35)
                                    .rotationEffect(.init(degrees: phase == .identity ? 0 : phase.value * 15), anchor: .bottom)
                                
                            }
                        
                    }
                    
                }
                .scrollTargetLayout()
                .scrollClipDisabled()
                .safeAreaPadding(.horizontal, (size.width - 220) / 2)
                
            }
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .frame(height: 330)
            
        }
        .padding(.top, 64)
        
    }
    
}

struct ImageModel: Identifiable {
    
    var id = UUID()
    var image: Image // Replace with ImageResource
    
}

#Preview {
    
    FannedCarouselView(images: [
        ImageModel(image: Image(.image1)),
        ImageModel(image: Image(.image4)),
        ImageModel(image: Image(.image3))
    ])
    
}
