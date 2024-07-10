//
//  CenterContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/2/23.
//

import SwiftUI

struct SpotifyCollectionLayoutView: View {
    
    @State var currentViewIndex: Int? = 0
    var hSpacing: CGFloat = 32
    
    let colors: [Color] = [
        .red,
        .orange,
        .yellow,
        .green,
        .cyan,
        .blue,
        .purple
    ]
    
    var body: some View {
        
//        GeometryReader { proxy in
            
            ScrollView(.horizontal) {
                
                LazyHStack(spacing: 16) {
                    
                    ForEach (self.colors, id: \.self) { color in
                        
                        RoundedRectangle (cornerRadius: 25.0)
                            .fill(color .gradient)
                            .containerRelativeFrame(.horizontal)
                            .frame(height: 300)
                            .appShadow(style: .card)
                        
                    }
                    
                }
                .scrollTargetLayout()
                
            }
            .scrollIndicators(.hidden)
            .safeAreaPadding(.horizontal, self.hSpacing)
//        }
        .scrollTargetBehavior(.viewAligned)
        
    }
    
}

#Preview {
    SpotifyCollectionLayoutView()
}
