//
//  PullToRefreshModifier.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 5/7/25.
//

import SwiftUI

public struct PullToRefreshModifier: ViewModifier {
    
    public enum RefreshStyle {
        
        case sticky
        case offset
        
    }
        
    @Binding var offset: CGFloat
    @Binding var isRefreshing: Bool
    
    @State private var contentOffset: CGFloat = 0
    @State private var refreshIndicatorSize: CGSize = .zero
    
    private var threshold: CGFloat
    private var refreshIndicator: RefreshIndicatorType
    private var refreshStyle: RefreshStyle
    private var onRefresh: () -> Void
    private var onRefreshCompleted: (() -> Void)?
    
    private var progress: CGFloat {
        return min(offset / threshold, 1.0)
    }
    
    public init(offset: Binding<CGFloat>,
                isRefreshing: Binding<Bool>,
                threshold: CGFloat,
                refreshIndicator: RefreshIndicatorType,
                refreshStyle: RefreshStyle = .sticky,
                onRefresh: @escaping () -> Void,
                onRefreshCompleted: (() -> Void)? = nil) {
        
        self._offset = offset
        self._isRefreshing = isRefreshing
        
        self.threshold = threshold
        self.refreshIndicator = refreshIndicator
        self.refreshStyle = refreshStyle
        
        self.onRefresh = onRefresh
        self.onRefreshCompleted = onRefreshCompleted
        
    }
    
    public func body(content: Content) -> some View {
        
        ZStack(alignment: .top) {
            
            if self.offset > 0 || self.isRefreshing {
                
                self.refreshIndicatorView
                
            }
            
            content
                .contentMargins(.top, self.isRefreshing ? self.contentOffset : 0)
            
        }
        .onScrollGeometryChange(for: CGFloat.self) { geo in
            return -CGFloat(geo.contentOffset.y + geo.contentInsets.top)
        } action: { oldValue, newValue in
            trackScrolloffset(newValue)
        }
        .onChange(of: self.isRefreshing) { oldValue, newValue in
            
            withAnimation(.smooth(duration: 0.3)) {
                if !newValue {
                    contentOffset = 0
                }
            }
            
        }
        
    }
    
    // MARK: - Private Methods
    
    private func trackScrolloffset(_ value: CGFloat) {
        
        guard !self.isRefreshing else { return }
        
        withAnimation(.smooth(duration: 0.3)) {
            self.offset = value
        }
                    
        if self.offset >= self.threshold {
            handleRefreshTrigger(newValue: self.offset)
        }
        
    }
    
    private func handleRefreshTrigger(newValue: CGFloat) {
        
        withAnimation(.smooth(duration: 0.3)) {
            
            self.contentOffset = self.refreshIndicatorSize.height
            
            self.isRefreshing = true
            onRefresh()
            
        }
        
    }
    
    private func computeIndicatorOffset() -> CGFloat {
                
        switch self.refreshStyle {
        case .sticky:
            return 0
            
        case .offset:
            
            if isRefreshing {
                return 0
            } else {
                return max(0, self.offset - self.refreshIndicatorSize.height / 1.2)
            }
        }

    }
    
    private func computeIndicatorOpacity() -> Double {
        
        // Fade in based on pull progress
        
        if self.offset < self.threshold / 2 {
            return Double(self.offset / (self.threshold / 2))
        } else {
            return 1.0
        }
        
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var refreshIndicatorView: some View {
        
        self.refreshIndicator.view(
            progress: self.progress,
            offset: self.offset,
            isRefreshing: self.isRefreshing
        )
        .offset(y: computeIndicatorOffset())
        .opacity(computeIndicatorOpacity())
        .zIndex(0) // 1 for on top context
        .onGeometryChange(for: CGSize.self) { geo in
            return geo.size
        } action: { newValue in
            self.refreshIndicatorSize = newValue
        }
  
/// Working on making this a nice animation
//        .transition(.asymmetric(
//            insertion: .move(edge: .top).combined(with: .opacity),
//            removal: .opacity
//        ))
        
    }
    
}
