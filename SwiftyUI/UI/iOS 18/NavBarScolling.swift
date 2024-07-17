//
//  NavBarScolling.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import SwiftUI

//struct ScrollingNavBarView: View {
//    
//    struct NavProperties {
//        
//        let title: String
//        let subtitle: String?
//        let leftButtonView: AnyView?
//        let rightButtonView: AnyView?
//
//        init(title: String,
//             subtitle: String? = nil,
//             leftButtonView: AnyView? = nil,
//             rightButtonView: AnyView? = nil) {
//            
//            self.title = title
//            self.subtitle = subtitle
//            self.leftButtonView = leftButtonView
//            self.rightButtonView = rightButtonView
//            
//        }
//        
//    }
//    
//    enum NavBarStyle {
//        
//        case content(AnyView)
//        case standard(NavProperties)
//        
//    }
//    
//    let navBarStyle: NavBarStyle
//    let backgroundStyle: BackgroundStyle
//    
//    @Binding private var scrollOffset: CGFloat
//    
//    init(navBarStyle: NavBarStyle,
//         backgroundStyle: BackgroundStyle,
//         scrollOffset: Binding<CGFloat>) {
//        
//        self.navBarStyle = navBarStyle
//        self.backgroundStyle = backgroundStyle
//        self._scrollOffset = scrollOffset
//        
//    }
//    
//    init(title: String,
//         subtitle: String? = nil,
//         leftButtonView: AnyView? = nil,
//         rightButtonView: AnyView? = nil,
//         navBackgroundStyle: BackgroundStyle = .color(ThemeManager.shared.background(.primary)),
//         scrollOffset: Binding<CGFloat>) {
//        
//        self.navBarStyle = .standard(
//            .init(
//                title: title,
//                subtitle: subtitle,
//                leftButtonView: leftButtonView,
//                rightButtonView: rightButtonView
//            )
//        )
//        
//        self.backgroundStyle = navBackgroundStyle
//        self._scrollOffset = scrollOffset
//        
//    }
//    
//    var body: some View {
//        
//        Group {
//            switch navBarStyle {
//            case .content(let content):
//                applyCommonStyle(content)
//            case .standard(let navProperties):
//                applyCommonStyle(standardView(navProperties: navProperties))
//                    .clipShape(.rect)
//            }
//        }
//        .background(content: {
//            
//            switch self.backgroundStyle {
//            case .color(let color):
//                
//                color
//                    .ignoresSafeArea()
//                
//            case .material(let material):
//                
//                AnyView(Rectangle().fill(material))
//                    .ignoresSafeArea()
//                
//            case .linearGradient(let linearGradient):
//                
//                linearGradient
//                    .ignoresSafeArea()
//                
//            }
//            
//        })
//        
//    }
//    
//    @ViewBuilder
//    private func standardView(navProperties: NavProperties) -> some View {
//        
//        ZStack(alignment: .center) {
//            
//            HStack {
//                
//                // Left Button View
//                
//                Group {
//                    
//                    if let leftButtonView = navProperties.leftButtonView {
//                        leftButtonView
//                    }
//                    else {
//                        navProperties.rightButtonView
//                            .opacity(0)
//                    }
//                    
//                }
//                
//                Spacer()
//                
//                // Right Button View
//                
//                Group {
//                    
//                    if let rightButtonView = navProperties.rightButtonView {
//                        rightButtonView
//                    }
//                    else {
//                        
//                        navProperties.leftButtonView
//                            .opacity(0)
//                    }
//                    
//                }
//                
//            }
//            .frame(maxWidth: .infinity)
//            
//            // Center Title & Subtitle
//            
//            VStack {
//                
//                Text(navProperties.title)
//                    .appFont(with: .title(.t6))
//                    .fontDesign(.serif)
//                    .foregroundStyle(.black)
//                    .opacity(((self.scrollOffset * 0.5) / 50.0))
//                
//                if let subtitle = navProperties.subtitle {
//                    
//                    Text(subtitle)
//                        .appFont(with: .body(.b5))
//                        .foregroundStyle(.black)
//                    
//                }
//                
//                Text(navProperties.title)
//                    .appFont(with: .title(.t10))
//                    .fontDesign(.serif)
//                    .foregroundStyle(.black)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.top, Spacing.large.value - self.scrollOffset)
//                    .opacity(((50.0 - self.scrollOffset) / 50.0))
//                
//            }
//            .frame(maxWidth: .infinity, alignment: .center)
//            .padding(.horizontal, 48)
//            
//        }
//        
//    }
//    
//    private func applyCommonStyle<V: View>(_ view: V) -> some View {
//                
//        return view
//            .customSafeAreaPadding(
//                padding: Spacing.none.value,
//                for: .top
//            )
//            .frame(maxWidth: .infinity)
//            .padding(.horizontal, 16)
//            .padding(.bottom, 12)
//            .background(content: {
//                switch self.backgroundStyle {
//                case .color(let color):
//                    color
//                case .material(let material):
//                    AnyView(Rectangle().fill(material))
//                case .linearGradient(let linearGradient):
//                    linearGradient
//                }
//            })
//            .overlay(alignment: .bottom) {
//                
//                Rectangle()
//                    .fill(.gray.opacity(0.3))
//                    .frame(height: 1)
//                
//            }
//        
//    }
//    
//}
//
//@available(iOS 18.0, *)
//internal
//struct ScrollingNavBarViewTest: View {
//    
//    @State private var scrollOffset: CGFloat = 0
//    
//    var body: some View {
//        
//        VStack {
//            
//            ScrollingNavBarView(
//                navBarStyle: .standard(.init(title: "Title")),
//                backgroundStyle: .color(.gray),
//                scrollOffset: self.$scrollOffset
//            )
//            
//            ScrollView {
//                
//                VStack(spacing: .appLarge) {
//                    
//                    ForEach(0..<300) { index in
//                        
//                        AppCardView {
//                            
//                            Text(index, format: .number)
//                                .font(.largeTitle)
//                                .fontDesign(.monospaced)
//                                .fontWidth(.expanded)
//                                .frame(maxWidth: .infinity)
//                            
//                        }
//                        .padding(.horizontal, .large)
//                        
//                    }
//                    
//                }
//                
//            }
//            .onScrollGeometryChange(for: CGFloat.self) { geo in
//                return geo.contentOffset.y
//            } action: { oldValue, newValue in
//                self.scrollOffset = newValue
//            }
//            
//        }
//        .onChange(of: self.scrollOffset) { oldValue, newValue in
//            print(newValue)
//        }
//        
//    }
//    
//}
//
//@available(iOS 18.0, *)
//#Preview {
//    ScrollingNavBarViewTest()
//}

struct ScrollPhase: View {
    @State private var isScrolling = false
    
    var body: some View {
        ScrollView {
            ForEach(1..<100, id: \.self) { item in
                Text(verbatim: item.formatted())
            }
            .redacted(reason: isScrolling ? .placeholder : [])
        }
        .onScrollPhaseChange { oldPhase, newPhase in
            isScrolling = newPhase.isScrolling
        }
    }
}

#Preview {
    ScrollPhase()
}

struct ScrollPhaseEnum: View {
    var body: some View {
        ScrollView {
            ForEach(1..<100, id: \.self) { item in
                Text(verbatim: item.formatted())
            }
        }
        .onScrollPhaseChange { oldPhase, newPhase, context in
            guard oldPhase != newPhase else {
                return
            }
            print(context.geometry.visibleRect)
            print(newPhase)
        }
    }
}

#Preview {
    ScrollPhaseEnum()
}

struct ScrollOffsetView: View {
    struct ScrollData: Equatable {
        let size: CGSize
        let visible: CGRect
    }
    
    @State private var scrollPosition = ScrollPosition(y: 0)
    @State private var scrollData = ScrollData(size: .zero, visible: .zero)
    
    var body: some View {
        ScrollView {
            ForEach(1..<100, id: \.self) { number in
                Text(verbatim: number.formatted())
                    .id(number)
            }
        }
        .scrollPosition($scrollPosition)
        .onScrollGeometryChange(for: ScrollData.self) { geometry in
            ScrollData(size: geometry.contentSize, visible: geometry.visibleRect)
        } action: { oldValue, newValue in
            if oldValue != newValue {
                scrollData = newValue
            }
        }
        .onChange(of: scrollData) {
            print(scrollData)
        }
    }
}

#Preview {
    ScrollOffsetView()
}

//struct ScrollPosition: View {
//    @State private var position = ScrollPosition(edge: .top)
//    
//    var body: some View {
//        ScrollView {
//            Button("Scroll to offset") {
//                position.scrollTo(point: CGPoint(x: 0, y: 100))
//            }
//            
//            ForEach(1..<100) { index in
//                Text(verbatim: index.formatted())
//                    .id(index)
//            }
//        }
//        .scrollPosition($position)
//        .animation(.default, value: position)
//    }
//}
//
//#Preview {
//    ScrollPosition()
//}
