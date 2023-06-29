//
//  NewTikTokView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/28/23.
//

import SwiftUI

struct CurrentOffsetScrollView: View {
    
    @State private var currentOffset: CGFloat = 0
    
    var body: some View {
        
        ZStack {
            
            Text("\(currentOffset)")
                .padding(.top, 50)
                .zIndex(1000)
                .offset(y: self.currentOffset)
            
            ScrollView {
                
                ForEach(0..<100) { i in
                        RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(1).gradient)
                        .frame(maxWidth: .infinity, minHeight: 300)
                        .padding(.horizontal, 32)
                        .visualEffect { content, proxy in
                            content.blur(radius: blurAmount(for: proxy))
                        }
                }
                
            }
            
        }
        
    }

    func blurAmount(for proxy: GeometryProxy) -> Double {

        let scrollViewHeight = proxy.bounds(of: .scrollView)?.height ?? 100
        let ourCenter = proxy.frame(in: .scrollView).midY
        let distanceFromCenter = abs(scrollViewHeight / 2 - ourCenter)
        
        self.currentOffset = proxy.frame(in: .scrollView).minY // for vertical offset
//        self.currentOffset = CGFloat(Int((Double(distanceFromCenter) / 100)))
        
        return Double(distanceFromCenter) / 100
        
    }
    
}

#Preview {
    CurrentOffsetScrollView()
}
