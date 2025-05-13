//
//  Ext+View.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 5/12/25.
//

import SwiftUI

extension View {
    
    func customPullToRefresh(offset: Binding<CGFloat>,
                             isRefreshing: Binding<Bool>,
                             threshold: CGFloat = 100,
                             refreshIndicator: RefreshIndicatorType = .system,
                             refreshStyle: PullToRefreshModifier.RefreshStyle = .sticky,
                             onRefresh: @escaping () -> Void,
                             onRefreshCompleted: (() -> Void)? = nil) -> some View {
        
        modifier(PullToRefreshModifier(
            offset: offset,
            isRefreshing: isRefreshing,
            threshold: threshold,
            refreshIndicator: refreshIndicator,
            refreshStyle: refreshStyle,
            onRefresh: onRefresh,
            onRefreshCompleted: onRefreshCompleted
        ))
        .onChange(of: isRefreshing.wrappedValue) { oldValue, newValue in
            
            // When refresh completes (changes from true to false)
            if oldValue && !newValue {
                
                withAnimation(.easeOut(duration: 0.3)) {
                    offset.wrappedValue = 0
                }

                if let completion = onRefreshCompleted {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        completion()
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func endRefreshing(_ isRefreshing: Binding<Bool>,
                       offset: Binding<CGFloat>,
                       completion: (() -> Void)? = nil) {
        
        withAnimation(.easeOut(duration: 0.3)) {
            
            isRefreshing.wrappedValue = false
            offset.wrappedValue = 0
            
        }
        
        if let completion = completion {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                completion()
            }
            
        }
        
    }
    
}
