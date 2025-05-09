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
    
    public enum RefreshIndicatorType {
        
        case system
        case arrow
        case custom(AnyView)
        
        static func custom<T: View>(_ view: T) -> RefreshIndicatorType {
            RefreshIndicatorType.custom(AnyView(view))
        }
        
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
            return -CGFloat(geo.contentOffset.y + geo.contentInsets.top + 12)
        } action: { oldValue, newValue in
            
            withAnimation(.smooth(duration: 0.3)) {
                self.offset = self.isRefreshing ? self.threshold : newValue
            }
            
            if self.offset > self.threshold {
                handleRefreshTrigger(newValue: self.offset)
            }
            
        }
        
    }
    
    private var refreshIndicatorView: some View {
        
        Group {
            
            switch refreshIndicator {
            case .system:
                return AnyView(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 32, height: 32)
                        .transition(.opacity)
                )
                
            case .arrow:
                return AnyView(
                    Group {
                        
                        if isRefreshing {
                            
                            ProgressView()
                                .controlSize(.large)
                                .padding(8)
                                .background(
                                    .gray.opacity(0.15),
                                    in: .rect(cornerRadius: 12)
                                )
                                .transition(.opacity)
                            
                        } else {
                            
                            Image(systemName: "arrow.down")
                                .aspectRatio(contentMode: .fit)
                                .rotationEffect(.degrees(progress >= 0.80 ? 540 : 0))
//                                .rotationEffect(.degrees(progress * 500))
                                .transition(.opacity)
                                .padding(16)
                                .background(
                                    .gray.opacity(0.15),
                                    in: .rect(cornerRadius: 12)
                                )
                                .transition(.opacity)
                            
                        }
                        
                    }
                )
                
            case .custom(let view):
                return AnyView(view.transition(.opacity))
            }
            
        }
        .offset(y: computeIndicatorOffset())
        .opacity(computeIndicatorOpacity())
        .zIndex(1)
        .onGeometryChange(for: CGSize.self) { geo in
            return geo.size
        } action: { newValue in
            self.refreshIndicatorSize = newValue
        }
        
    }
    
    // MARK: - Private Methods
    
    private func handleRefreshTrigger(newValue: CGFloat) {
        
        withAnimation(.smooth(duration: 0.3)) {
                        
            let minContentOffset: CGFloat = 50
            let dynamicContentOffset: CGFloat = self.refreshIndicatorSize.height
            self.contentOffset = max(dynamicContentOffset, minContentOffset)
            
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
                return max(0, self.offset - 30)
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
    
}

// MARK: - View Extension

extension View {
    
    func customPullToRefresh(offset: Binding<CGFloat>,
                             isRefreshing: Binding<Bool>,
                             threshold: CGFloat = 100,
                             refreshIndicator: PullToRefreshModifier.RefreshIndicatorType = .system,
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

// MARK: - Example Usage

struct PullToRefreshExample: View {
    
    @State private var pullOffset: CGFloat = 0
    @State private var isRefreshing = false
    @State private var items = Array(0..<20)
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            // Background color for a better visual effect
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView {
                
                VStack(spacing: 16) {
                    
                    ForEach(items, id: \.self) { item in
                        
                        Text("Item \(item)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        
                    }
                    
                }
                .padding()
                
            }
            .customPullToRefresh(
                offset: $pullOffset,
                isRefreshing: $isRefreshing,
                threshold: 150,
                refreshIndicator: .arrow,
                refreshStyle: .sticky,
                onRefresh: {
                    
                    // Simulate network request
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        
                        // Update the data
                        let newItems = Array(items.count..<items.count + 5)
                        items = newItems + items
                        
                        // End the refreshing state
                        endRefreshing(
                            $isRefreshing,
                            offset: $pullOffset
                        )
                    }
                    
                }
            )
            
        }
        
    }
    
}

#Preview {
    PullToRefreshExample()
}
