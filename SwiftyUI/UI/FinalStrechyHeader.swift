//
//  FinalStrechyHeader.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/6/24.
//

import SwiftUI

struct SafeAreaInsetsKey: PreferenceKey {
    
    static let defaultValue = EdgeInsets()
    
    static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
        value = nextValue()
    }
    
}

extension View {
    
    /// The scroll offset for the scroll view this modifier is attached to.
    /// - Parameter offset: The current offset needed to support stretching. Positive values are ignored and returned as 0 as we only need negative values (scrolling up beyond the top).
    func scrollOffset(_ offset: Binding<CGFloat>) -> some View {
        
        onScrollGeometryChange(for: CGFloat.self) { geo in
            min(0, geo.contentOffset.y)
        } action: { oldValue, newValue in
            offset.wrappedValue = newValue
        }
        
    }
    
}

extension View {
    
    /// Get the safe area insets for the view this modifier is attached to.
    /// - Parameter safeInsets: The safe area insets for this view.
    func getSafeAreaInsets(_ safeInsets: Binding<EdgeInsets>) -> some View {
        
        background(
            
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SafeAreaInsetsKey.self, value: proxy.safeAreaInsets)
                
            }
            .onPreferenceChange(SafeAreaInsetsKey.self) { value in
                safeInsets.wrappedValue = value
            }
        )
    }
}

public struct StretchyHeaderScrollView<Content: View, Header: View, HeaderBackground: View>: View {
    
    /// The scroll view content following the header view.
    @ViewBuilder public var content: Content
    
    /// The header background.
    @ViewBuilder public var headerBackground: HeaderBackground
    
    /// The header content layered above `headerBackground`.
    @ViewBuilder public var headerContent: Header
    
    @State private var topOffset: CGFloat = 0
    @State private var safeAreaInsets: EdgeInsets = .init()
    
    public init(@ViewBuilder content: () -> Content,
                @ViewBuilder headerBackground: () -> HeaderBackground,
                @ViewBuilder headerContent: () -> Header) {
        
        self.content = content()
        self.headerBackground = headerBackground()
        self.headerContent = headerContent()
        
    }
    
    public var body: some View {
        
        ScrollView {
            
            VStack(spacing: 0) {
                
                HeaderContainer(topOffset: -topOffset, safeAreaTop: safeAreaInsets.top) {
                    headerContent
                } headerBackground: {
                    headerBackground
                }
                
                content
                    .frame(maxWidth: .infinity)
                    .offset(y: topOffset)
                
            }
            
        }
        .ignoresSafeArea()
        .scrollOffset($topOffset)
        .getSafeAreaInsets($safeAreaInsets)
        
    }
    
}

fileprivate struct HeaderContainer<Content: View, HeaderBackground: View>: View {
    
    let topOffset: CGFloat
    let safeAreaTop: CGFloat
    
    var content: () -> Content
    var headerBackground: () -> HeaderBackground
    
    private var scaleFactor: CGFloat {
        print(1 + (topOffset / 4000))
        return max(1, 1 + (topOffset / 4000)) // Adjust 200 to control scaling sensitivity
    }
    
    var body: some View {
        
        VStack(spacing: Spacing.none.value) {
            
            Spacer(minLength: topOffset + safeAreaTop)
            content()
            
        }
        .background(
            
            headerBackground()
                .scaleEffect(scaleFactor, anchor: .center)
                .frame(maxWidth: .infinity)
            
        )
        .clipped()
        .offset(y: -topOffset)
        
    }
    
}

#Preview {
    
    StretchyHeaderScrollView {
        
        ForEach(0..<10) { _ in
            
            RoundedRectangle(cornerRadius: .appSmall)
                .fill(.indigo)
                .frame(height: 100)
                .padding(.horizontal, .large)
                .asButton {
                    
                }
            
        }
        
    } headerBackground: {
        
        Image(.image3)
            .resizable()
//        
//        LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
        
    } headerContent: {
        
        Text("Some Text")
            .frame(maxWidth: .infinity)
            .padding(.bottom, .xLarge)
            .frame(height: 200)
        
    }
    
}

#Preview {
    
    StretchyHeaderScrollView {
        
        VStack(spacing: .appLarge) {
            
            ForEach(0..<10) { _ in
                
                RoundedRectangle(cornerRadius: .appSmall)
                    .fill(.indigo)
                    .frame(height: 100)
                    .padding(.horizontal, .large)
                    .asButton {
                        
                    }
                
            }
            
        }
        .padding(.top, .appMedium)
        
    } headerBackground: {
        
        Image(.image3)
            .resizable()
            .scaledToFill()
            .padding(.bottom, 200)
        

//        LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
        
    } headerContent: {
        
        VStack {
            
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: 24,
                    bottomTrailing: 24,
                    topTrailing: 0
                )
            )
                .fill(.green)
                .frame(height: 200)
                .opacity(0.8)
                .overlay {
                    
                    Text("Some Text")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .appFont(with: .title(.t5))
                    
                }
            
        }
        .padding(.top, 225)
        
    }
    
}
