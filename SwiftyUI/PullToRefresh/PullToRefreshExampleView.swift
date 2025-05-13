//
//  Exa.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 5/12/25.
//

import SwiftUI

struct PullToRefreshExample: View {
    
    @State private var pullOffset: CGFloat = 0
    @State private var isRefreshing = false
    @State private var items = Array(0..<20)
    var style: RefreshIndicatorType
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            Color(.systemBackground).ignoresSafeArea()
            
            scrollView()
                .customPullToRefresh(
                    offset: self.$pullOffset,
                    isRefreshing: self.$isRefreshing,
                    threshold: 120,
                    refreshIndicator: self.style,
                    refreshStyle: .sticky,
                    onRefresh: {
                        onRefresh()
                    }
                )
            
        }
        
    }
    
    private func scrollView() -> some View {
        
        ScrollView {
            
            VStack(spacing: 16) {
                
                ForEach(self.items, id: \.self) { item in
                    
                    Text("Item \(item)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    
                }
                
            }
            
        }
        .safeAreaPadding(.horizontal, .appMedium)
        .safeAreaPadding(.top, .appSmall)
        
    }
    
    private func onRefresh() {
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            
            // Update the data
            let newItems = Array(items.count..<items.count + 5)
            self.items = newItems + items
            
            // End the refreshing state
            endRefreshing(
                self.$isRefreshing,
                offset: self.$pullOffset
            )
        }
        
    }
    
}

#Preview("Arrow") {
    PullToRefreshExample(style: .arrow)
}

#Preview("Segmented Circle") {
    
    PullToRefreshExample(style: .segmentedColorShape(
        height: 50,
        lineWidth: 6,
        items: [
            .init(percentage: 50, color: .red),
            .init(percentage: 25, color: .blue),
            .init(percentage: 25, color: .green),
        ]))
    
}

#Preview("Banner") {
    
    PullToRefreshExample(style: RefreshIndicatorType.custom(
        Rectangle()
            .fill(.blue)
            .ignoresSafeArea()
            .overlay {
                Text("Some CoolText")
            }
            .frame(height: 60)
    ))
    
}

#Preview("Text") {
    
    PullToRefreshExample(style: RefreshIndicatorType.custom(
        AnyView(Text("PLEASE PULL ME DADDY"))
    ))
    
}
