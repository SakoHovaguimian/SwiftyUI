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
        case segmentedColorShape(height: CGFloat,
                                 lineWidth: CGFloat = 8,
                                 items: [SegmentedCirclePathView.Item])
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
                    .zIndex(0)
//                    .transition(.asymmetric(
//                        insertion: .move(edge: .top).combined(with: .opacity),
//                        removal: .opacity
//                    ))
                
            }
            
            content
                .contentMargins(.top, self.isRefreshing ? self.contentOffset : 0)
            
        }
        .onScrollGeometryChange(for: CGFloat.self) { geo in
            return -CGFloat(geo.contentOffset.y + geo.contentInsets.top)
        } action: { oldValue, newValue in
            
            guard !self.isRefreshing else { return }
            
            withAnimation(.smooth(duration: 0.3)) {
                self.offset = newValue
            }
                        
            if self.offset >= self.threshold {
                handleRefreshTrigger(newValue: self.offset)
            }
            
        }
        .onChange(of: self.isRefreshing) { oldValue, newValue in
            
            withAnimation(.smooth(duration: 0.3)) {
                if !newValue {
                    contentOffset = 0
                }
            }
            
        }
        
    }
    
    @ViewBuilder
    private var refreshIndicatorView: some View {
        
        Group {
            
            switch refreshIndicator {
            case .system:
                AnyView(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 32, height: 32)
                        .transition(.opacity)
                )
                
            case .arrow:
                AnyView(
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
                            
                            //                            Image(systemName: "arrow.down")
                            //                                .aspectRatio(contentMode: .fit)
                            //                                .rotationEffect(.degrees(progress >= 0.80 ? 540 : 0))
                            ////                                .rotationEffect(.degrees(progress * 500))
                            //                                .transition(.opacity)
                            //                                .padding(16)
                            //                                .background(
                            //                                    .gray.opacity(0.15),
                            //                                    in: .rect(cornerRadius: 12)
                            //                                )
                            //                                .transition(.opacity)
                            //
                            //                        }
                            
                            VStack {
                                
                                ProgressCircle(progress: progress)
                                    .frame(width: 48)
                                    .overlay {
                                        
                                        Image(systemName: "arrow.down")
                                            .aspectRatio(contentMode: .fit)
                                        
                                    }
                                
                                Text("Pull To Refresh")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                
                            }
                        }
                        
                        
                    }
                )
                
            case .segmentedColorShape(let height, let lineWidth, let items):
                
                SegmentedCirclePathView(
                    items: items,
                    lineWidth: lineWidth,
                    rotationAngle: .degrees(isRefreshing ? 3000 : offset),
                    animation: isRefreshing ? .smooth(duration: 2) : .smooth
                )
                .frame(height: height)
                
            case .custom(let view):
                AnyView(view.transition(.opacity))
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
                threshold: 120,
                refreshIndicator: .segmentedColorShape(
                    height: 50,
                    lineWidth: 6,
                    items: [
                        .init(percentage: 50, color: .red),
                        .init(percentage: 25, color: .blue),
                        .init(percentage: 25, color: .green),
                    ]),
//                refreshIndicator: .arrow,
//                refreshIndicator: PullToRefreshModifier.RefreshIndicatorType.custom(AnyView(Text("PLEASE PULL ME DADDY"))),
//                refreshIndicator: PullToRefreshModifier.RefreshIndicatorType.custom(AnyView(
//                    Rectangle()
//                        .fill(.blue)
//                        .ignoresSafeArea()
//                        .overlay {
//                            Text("Some CoolText")
//                        }
//                )                        .frame(maxHeight: 80)),
                refreshStyle: .offset,
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
