//
//  ScrollViewPagingAPI.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/23/23.
//

import SwiftUI

// Basic Paged Scrolling
struct ScrollViewPagingAPI: View {
    
    var hSpacing: CGFloat = 16
    
    var body: some View {
        
        let contentMarginHorizontalSpacing: CGFloat = self.hSpacing * 2
        
        ZStack {
            
            AppColor.charcoal.opacity(1)
                .ignoresSafeArea()

            ScrollView(.horizontal) {
                
                LazyHStack(spacing: self.hSpacing) {
                    ForEach (0...10, id: \.self) { palette in
                        Image(.sunset)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width - 64)
                            .cornerRadius(23)
                            .shadow(radius: 23)
                        
                        /// THIS WAS THE ORIGINAL COMPONENT TO TEST WITH
    //                    RoundedRectangle(cornerRadius: 23)
    //                        .frame(minWidth: UIScreen.main.bounds.width - 64, maxHeight: 500)
                    }
                }
            }
            .contentMargins(.horizontal, contentMarginHorizontalSpacing)
        .scrollTargetBehavior(.paging)
        }
        
    }
}

#Preview {
    ScrollViewPagingAPI()
}

// This safeAreaPadding modifier make it not clip to edges
// This view is pushed up to the top, remove this for subview implementation
struct ScrollViewSafeAreaPadding: View {
    
    var hSpacing: CGFloat = 16
    var alignment: VerticalAlignment = .top
    
    var body: some View {
                
        ScrollView(.horizontal) {
            
            LazyHStack(alignment: self.alignment, spacing: self.hSpacing) {
                
                ForEach (0...10, id: \.self) { palette in
                    
                    SomeScrollViewItem(cornerRadius: 33)
                        .containerRelativeFrame(
                            .horizontal,
                            count: 1,
                            span: 1,
                            spacing: self.hSpacing
                        )
                    
                }
                
            }
            
        }
        .safeAreaPadding(self.hSpacing)
        
    }
}

#Preview {
    ScrollViewSafeAreaPadding()
}

struct SomeScrollViewItem: View {
    
    var cornerRadius: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .fill(.purple)
            .aspectRatio(3.0 / 2.0, contentMode: .fit)
            .cornerRadius(self.cornerRadius)
    }
    
}
