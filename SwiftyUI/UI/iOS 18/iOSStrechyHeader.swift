//
//  iOSStrechyHeader.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/12/24.
//

import SwiftUI

struct iOSStrechyHeader: View {
    
    @State private var offset: CGFloat = 0
    
    private var imageHeight: CGFloat {
        return 300 + self.offset
    }
    
    var body: some View {
        
        ScrollView {
        
            Image(.image1)
                .resizable()
//                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .frame(height: self.imageHeight)
                .offset(y: -offset)
                
            
            Rectangle()
                .background(.red)
                .frame(height: 500)
            
        }
        .scrollBounceBehavior(.always)
        .ignoresSafeArea([.container])
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            
            return abs(min(geometry.contentOffset.y, 0))
            
        } action: { oldValue, newValue in
            
            self.offset = newValue
            
        }
        
    }
    
}

#Preview {
    
    iOSStrechyHeader()
    
}

// Building a better strechyView
// Using this new view, I want to embed my content to have it work

//struct StretchyView<Content: View>: View {
//
//    private let content: Content
//
//    @State private var headerFrame: CGRect = .zero
//    @State private var shouldReadFrameSize: Bool = true
//
//    init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }
//
//    var body: some View {
//
//            self.content
//                .readingFrame { frame in
//
//                    guard self.shouldReadFrameSize else { return }
//                    self.headerFrame = frame
//
//                }
//                .frame(maxWidth: .infinity)
//                .frame(
//                    height: self.headerFrame.height,
//                    alignment: .center
//                )
//                .asStretchyHeader(
//                    startingHeight: self.headerFrame.height,
//                    coordinateSpace: .global
//                )
//
//        .onScrollPhaseChange { _, newPhase in
//
//            switch newPhase {
//            case .idle: self.shouldReadFrameSize = true
//            case .tracking,
//                 .interacting,
//                 .decelerating,
//                 .animating: self.shouldReadFrameSize = false
//            }
//
//        }
//
//    }
//
//}
//

//import SwiftUI
//
//struct BaseStretchyHeaderView<StretchyHeaderContent: View,
//                              ScrollViewContent: View>: View {
//    
//    private let alignment: Alignment
//    private let backgroundStyle: AppBackgroundStyle
//    private let stretchyHeaderContent: StretchyHeaderContent
//    private let scrollViewContent: ScrollViewContent
//    
//    private var horizontalPadding: Spacing = .medium
//    @State private var headerHeight: CGFloat = 0
//    
//    public init(alignment: Alignment = .top,
//                horizontalPadding: Spacing = .medium,
//                backgroundStyle: AppBackgroundStyle = .color(.clear),
//                @ViewBuilder stretchyHeaderContent: () -> StretchyHeaderContent,
//                @ViewBuilder scrollViewContent: () -> ScrollViewContent) {
//        
//        self.alignment = alignment
//        self.backgroundStyle = backgroundStyle
//        self.horizontalPadding = horizontalPadding
//        self.stretchyHeaderContent = stretchyHeaderContent()
//        self.scrollViewContent = scrollViewContent()
//        
//    }
//    
//    var body: some View {
//        AppBaseView(alignment: self.alignment) {
//            
//            VStack(spacing: Spacing.none.value) {
//
//                ScrollView {
//                    
//                    self.stretchyHeaderContent
//                        .stretchyHeader()
//
//                    self.scrollViewContent
//                        .padding(.top, .large)
//                        .padding(.horizontal, horizontalPadding)
//                    
//                }
//                .scrollIndicators(.hidden)
//                
//            }
//            
//        }
//        .navigationBarBackButtonHidden()
//        
//    }
//    
//}
//
//#Preview {
//    
//    BaseStretchyHeaderView {
//        
//        VStack {
//            
//            Text("Header")
//                .font(.title)
//                .foregroundColor(.black)
//            
//            VStack {
//                
//                Text("Subtitle")
//                    .font(.subheadline)
//                    .foregroundColor(.black)
//                
//            }
//            
//            Text("Header")
//                .font(.title)
//                .foregroundColor(.black)
//            
////            Spacer()
//            
//        }
//        .padding(.top, .xLarge)
//        .frame(maxWidth: .infinity)
//        .background(.blue)
//        
//    } scrollViewContent: {
//        
//        VStack {
//            
//            Rectangle()
//                .fill(.brandGray.opacity(0.4))
//                .frame(height: 180)
//            
//            Rectangle()
//                .fill(.brandGray.opacity(0.4))
//                .frame(height: 180)
//            
//            Rectangle()
//                .fill(.brandGray.opacity(0.4))
//                .frame(height: 180)
//            
//            Rectangle()
//                .fill(.brandGray.opacity(0.4))
//                .frame(height: 180)
//            
//            Rectangle()
//                .fill(.brandGray.opacity(0.4))
//                .frame(height: 180)
//            
//        }
//        
//    }
//
//}
//
//struct StretchyHeaderModifier: ViewModifier {
//    @State private var headerHeight: CGFloat = 0
//    
//    func body(content: Content) -> some View {
//        GeometryReader { geo in
//            let offset = geo.frame(in: .global).minY
//            content
//                .frame(height: max(headerHeight + (offset > 0 ? offset : 0), headerHeight))
//                .background(.blue)
//                .offset(y: offset > 0 ? -offset : 0)
//                .onAppear {
//                    self.headerHeight = geo.size.height
//                }
//        }
//        .frame(height: headerHeight)
//    }
//}
//
//extension View {
//    func stretchyHeader() -> some View {
//        self.modifier(StretchyHeaderModifier())
//    }
//}
//
