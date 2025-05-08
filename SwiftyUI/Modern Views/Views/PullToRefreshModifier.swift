//
//  PullToRefreshModifier.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 5/7/25.
//

import SwiftUI

struct PullToRefreshModifier: ViewModifier {
        
    @Binding var offset: CGFloat
    @Binding var isRefreshing: Bool
    
    @State private var contentOffset: CGFloat = 0
    
    var threshold: CGFloat
    var refreshTriggerOffset: CGFloat
    var refreshIndicator: RefreshIndicatorType
    var onRefresh: () -> Void
    var onRefreshCompleted: (() -> Void)?
            
    func body(content: Content) -> some View {
        
        ZStack(alignment: .top) {
            
            if self.offset > 0 || self.isRefreshing {
                
                self.refreshIndicatorView
                    .offset(y: computeIndicatorOffset())
                    .opacity(computeIndicatorOpacity())
                    .zIndex(1)
                
            }
            
            content
                .safeAreaPadding(.top, self.isRefreshing ? self.threshold / 2 : 0)
            
        }
        .onScrollGeometryChange(for: CGFloat.self) { geo in
            
            return -CGFloat(geo.contentOffset.y + geo.contentInsets.top + 32)
            
        } action: { oldValue, newValue in
            
            withAnimation(.smooth(duration: 0.3)) {
                self.offset = self.isRefreshing ? self.threshold : newValue
            }
            
            if self.offset > self.threshold {
                handleRefreshTrigger(newValue: newValue)
            }
            
        }
        
    }
    
    // MARK: - Private Methods
    
    private func handleRefreshTrigger(newValue: CGFloat) {
        
        withAnimation(.smooth(duration: 0.3)) {
            
            self.offset = refreshTriggerOffset
            self.contentOffset = refreshTriggerOffset
            self.isRefreshing = true
            onRefresh()
            
        }
        
    }
    
    private var refreshIndicatorView: some View {
        
        Group {
            
            switch refreshIndicator {
            case .system:
                return AnyView(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 24, height: 24)
                        .padding(.bottom, 8)
                        .transition(.opacity)
                )
                
            case .arrow:
                return AnyView(
                    Image(systemName: isRefreshing ? "arrow.2.circlepath" : "arrow.down")
                        .rotationEffect(.degrees(offset >= threshold ? 180 : 0))
                        .padding(.bottom, 8)
                        .frame(width: 24, height: 24)
                        .transition(.opacity)
                )
                
            case .custom(let view):
                return AnyView(view.transition(.opacity))
            }
            
        }
        
    }
    
    private func computeIndicatorOffset() -> CGFloat {
        
        // Offset is based on pull progress
        
        if isRefreshing {
            return self.refreshTriggerOffset - 30
        } else {
            return max(0, self.offset - 30)
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

// MARK: - Refresh Indicator Type

enum RefreshIndicatorType {
    
    case system
    case arrow
    case custom(AnyView)
    
    static func custom<T: View>(_ view: T) -> RefreshIndicatorType {
        RefreshIndicatorType.custom(AnyView(view))
    }
    
}

// MARK: - View Extension

extension View {
    
    func customPullToRefresh(offset: Binding<CGFloat>,
                             isRefreshing: Binding<Bool>,
                             threshold: CGFloat = 100,
                             refreshTriggerOffset: CGFloat = 100,
                             refreshIndicator: RefreshIndicatorType = .system,
                             onRefresh: @escaping () -> Void,
                             onRefreshCompleted: (() -> Void)? = nil) -> some View {
        
        modifier(PullToRefreshModifier(
            offset: offset,
            isRefreshing: isRefreshing,
            threshold: threshold,
            refreshTriggerOffset: refreshTriggerOffset,
            refreshIndicator: refreshIndicator,
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

// MARK: - Custom Refresh Indicator Example

struct CustomRefreshIndicator: View {
    
    @Binding var progress: CGFloat
    var isRefreshing: Bool
    
    var body: some View {
        
        VStack(spacing: 4) {
            
            if isRefreshing {
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                
                Text("Refreshing...")
                    .font(.caption)
                
            } else {
                
                Image(systemName: "arrow.down")
                    .rotationEffect(.degrees(progress >= 1.0 ? 180 : 0))
                    .animation(.easeOut, value: progress)
                
                Text(progress >= 1.0 ? "Release to refresh" : "Pull to refresh")
                    .font(.caption)
                
            }
            
        }
        .padding(.vertical, 8)
        
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
                threshold: 100,
                refreshTriggerOffset: 50,
//                refreshIndicator: .custom(
//                    CustomRefreshIndicator(
//                        progress: .init(get: { min(pullOffset / 80, 1.0) }, set: { _ in }),
//                        isRefreshing: isRefreshing
//                    )
//                ),
                refreshIndicator: .arrow,
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

// For demonstration purposes only - replace with your actual implementation
extension Color {
    static var systemBackground: Color {
        return Color(UIColor.systemBackground)
    }
}

#Preview {
    PullToRefreshExample()
}
