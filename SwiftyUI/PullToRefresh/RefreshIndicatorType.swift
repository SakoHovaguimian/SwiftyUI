//
//  RefreshIndicatorType.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 5/12/25.
//

import SwiftUI

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
    
    @ViewBuilder
    public func view(progress: CGFloat,
                     offset: CGFloat,
                     isRefreshing: Bool) -> some View {
        
        switch self {
        case .system:
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .frame(width: 32, height: 32)
                .transition(.opacity)
            
        case .arrow:
            
            ArrowView(
                progress: progress,
                isRefreshing: isRefreshing
            )
            
        case .segmentedColorShape(let height, let lineWidth, let items):
            
            SegmentedCirclePathView(
                items: items,
                lineWidth: lineWidth,
                rotationAngle: .degrees(isRefreshing ? 30000 : offset),
            )
            .frame(height: height)
            
        case .custom(let view):
            
            AnyView(view.transition(.opacity))
        }
        
    }
    
}

fileprivate struct ArrowView: View {
    
    let progress: CGFloat
    let isRefreshing: Bool
    
    var body: some View {
        scrollingView()
    }
    
    private func scrollingView() -> some View {
        
        VStack {
            
            ProgressCircle(progress: self.progress)
                .frame(width: 48)
                .overlay {
                    
                    Image(systemName: self.isRefreshing ? "progress.indicator" : "arrow.down")
                        .contentTransition(.symbolEffect(.replace))
                        .aspectRatio(contentMode: .fit)
                        .phaseAnimator([false, true], trigger: self.isRefreshing) { view, bool in
                            view.rotationEffect(.degrees(bool ? 3000 : 0))
                        } animation: { bool in
                            return .bouncy(duration: 1)
                        }
                        .clipped()
                    
                }
            
            if !self.isRefreshing {
                
                Text("Pull to refresh")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .transition(.opacity)
                
            }
            
        }
        
    }
    
    private func loadingView() -> some View {
        
        ProgressView()
            .controlSize(.large)
            .padding(8)
            .background(
                .gray.opacity(0.15),
                in: .rect(cornerRadius: 12)
            )
            .transition(.opacity)
        
    }
    
}
