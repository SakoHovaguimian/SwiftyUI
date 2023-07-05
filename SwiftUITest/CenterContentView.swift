//
//  CenterContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/2/23.
//

import SwiftUI

struct SpotifyCollectionLayoutView: View {
    
    @State var currentViewIndex: Int? = 0
    var hSpacing: CGFloat = 24
    
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
        
        let itemWidth: CGFloat = UIScreen.main.bounds.width - (self.hSpacing * 2)
        
        GeometryReader { proxy in
            
            ScrollView(.horizontal) {
                
                LazyHStack(spacing: self.hSpacing / 2) {
                    
                    ForEach (self.colors, id: \.self) { color in
                        
                        RoundedRectangle (cornerRadius: 25.0)
                            .fill(color .gradient)
                            .frame(width: itemWidth, height: 400)
                    }
                    
                }
                
            }
            .scrollIndicators(.hidden)
            .safeAreaPadding(.horizontal, (proxy.size.width - itemWidth) / 2)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        
    }
    
}

#Preview {
    SpotifyCollectionLayoutView()
}
