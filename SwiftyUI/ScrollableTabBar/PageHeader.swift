//
//  PageHeader.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/5/25.
//


import SwiftUI

public struct PageHeader {
    
    public enum Style {
        
        case title
        case icon
        case titleIcon
        
    }
    
    private(set) var title: String
    private(set) var icon: String
    private(set) var selectedColor: Color
    private(set) var unselectedColor: Color
    
    public init(title: String,
                icon: String,
                selectedColor: Color,
                unselectedColor: Color) {
        
        self.title = title
        self.icon = icon
        self.selectedColor = selectedColor
        self.unselectedColor = unselectedColor
        
    }
    
}

public struct HeaderPageScrollView<Pages: View>: View {

    private let pageHeaders: [PageHeader]
    private let pageHeaderStyle: PageHeader.Style
    private let pageHeaderDividerColor: Color
    private let pageHeaderDividerWidth: CGFloat
    private let pageHeaderSelectedColor: Color
    private let pages: Pages
    private let backgroundColor: Color
    
    public init(pageHeaders: [PageHeader],
                pageHeaderStyle: PageHeader.Style = .title,
                pageHeaderDividerColor: Color = .gray,
                pageHeaderDividerWidth: CGFloat = 60,
                pageHeaderSelectedColor: Color = .mint,
                backgroundColor: Color = .white,
                @ViewBuilder pages: @escaping () -> Pages) {
        
        self.pageHeaderStyle = pageHeaderStyle
        self.pageHeaderDividerColor = pageHeaderDividerColor
        self.pageHeaderDividerWidth = pageHeaderDividerWidth
        self.pageHeaderSelectedColor = pageHeaderSelectedColor
        
        self.pages = pages()
        self.pageHeaders = pageHeaders
        
        self.backgroundColor = backgroundColor
        
        let count = self.pageHeaders.count
        self._scrollPositions = .init(initialValue: .init(repeating: .init(), count: count))
        self._scrollGeometries = .init(initialValue: .init(repeating: .init(), count: count))
        
    }
    
    // View Properties
    
    @State private var activeTab: String?
    @State private var scrollGeometries: [ScrollGeometry]
    @State private var scrollPositions: [ScrollPosition]
    
    // Scroll Properties
    
    @State private var mainScrollDisabled: Bool = false
    @State private var mainScrollPhase: SwiftUICore.ScrollPhase = .idle
    @State private var mainScrollGeometry: ScrollGeometry = .init()
    
    public var body: some View {
        
        GeometryReader {
            
            let size = $0.size
            
            ScrollView(.horizontal) {
                
                HStack(spacing: 0) {
                    pages(size: size)
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $activeTab)
            .scrollIndicators(.hidden)
            .scrollDisabled(mainScrollDisabled)
            
            /// Disabling Interaction when scroll view is animating to avoid unintentional taps!
            .allowsHitTesting(self.mainScrollPhase == .idle)
            
            .onScrollPhaseChange { oldPhase, newPhase in
                self.mainScrollPhase = newPhase
            }
            
            .onScrollGeometryChange(for: ScrollGeometry.self) { geo in
                return geo
            } action: { oldValue, newValue in
                mainScrollGeometry = newValue
            }

            .mask {
                
                Rectangle()
                    .fill(self.backgroundColor)
                    .ignoresSafeArea(.all, edges: .bottom)
                
            }

            .onAppear {
                
                /// Setting up Initial Tab Value
                guard activeTab == nil else { return }
                activeTab = pageHeaders.first?.title
                
            }
            
        }
        .background(self.backgroundColor)
        
    }
    
    func pages(size: CGSize) -> some View {
        
        Group(subviews: pages) { collection in

            ForEach(pageHeaders, id: \.title) { header in
                contentScrollView(header: header, size: size, collection: collection)
            }
            
        }
        
    }
    
    @ViewBuilder
    func contentScrollView(header: PageHeader,
                           size: CGSize,
                           collection: SubviewsCollection) -> some View {
        
        let index = pageHeaders.firstIndex(where: { $0.title == header.title }) ?? 0
        
        ScrollView(.vertical) {
            
            LazyVStack(spacing: 0,
                       pinnedViews: [.sectionHeaders]) {
                
                Section {
                    collection[index] // Pins header to top
                } header: {
                    
                    pageHeader()
                        .visualEffect { content, proxy in
                            
                            content
                                .offset(x: -proxy.frame(in: .scrollView(axis: .horizontal)).minX)
                            
                        }
                        .simultaneousGesture(self.horizontalScrollDisableGesture)
                        .opacity(self.activeTab == header.title ? 1 : 0)
                        .animation(.easeInOut(duration: 0.0), value: self.activeTab)
                    
                }
                
            }
            
        }
        .onScrollGeometryChange(for: ScrollGeometry.self) { geo in
            return geo
        } action: { _, newValue in
            
            self.scrollGeometries[index] = newValue
            
            if newValue.offsetY < 0 {
                resetScrollViews(header)
            }
            
        }
        .onScrollPhaseChange { oldPhase, newPhase in
            
            /// Fail-Safe
            if newPhase == .idle && mainScrollDisabled {
                self.mainScrollDisabled = false
            }
            
        }
        .scrollPosition(self.$scrollPositions[index])
        .frame(width: size.width)
        .scrollClipDisabled()
        .zIndex(self.activeTab == header.title ? 1000 : 0)
        
    }
    
    @ViewBuilder
    func pageHeader() -> some View {
        
        let min = min(self.mainScrollGeometry.offsetX / self.mainScrollGeometry.containerSize.width, CGFloat(self.pageHeaders.count - 1))
        let progress = max(min, 0)
        
        VStack(alignment: .leading, spacing: 5) {
            
            HStack(spacing: 0) {
                
                ForEach(self.pageHeaders, id: \.title) { header in
                    
                    Group {
                        
                        switch self.pageHeaderStyle {
                        case .title:
                            
                            Text(header.title)
                            
                        case .icon:
                            
                            Image(systemName: header.icon)
                            
                        case .titleIcon:
                            
                            Label(header.title, systemImage: header.icon)
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(self.activeTab == header.title ? header.selectedColor : header.unselectedColor)
                    .onTapGesture {
                        
                        withAnimation(.easeInOut(duration: 0.25)) {
                            activeTab = header.title
                        }
                        
                    }
                    
                }
                
            }
            .frame(maxHeight: .infinity)
            
            ZStack(alignment: .leading) {
                
                Rectangle()
                    .fill(self.pageHeaderDividerColor)
                    .frame(height: 1)
                
                Capsule()
                    .fill(self.pageHeaderSelectedColor)
                    .frame(width: self.pageHeaderDividerWidth, height: 4)
                    .containerRelativeFrame(.horizontal) { value, _ in
                        return value / CGFloat(self.pageHeaders.count)
                    }
                    .visualEffect { content, proxy in
                        
                        content
                            .offset(x: proxy.size.width * progress, y: -1)
                        
                    }
            }
            
        }
        .frame(height: 40)
        .background(self.backgroundColor)
        
    }
    
    @ViewBuilder private func emptyView() -> some View {
        
        Rectangle()
            .foregroundStyle(.clear)
            .frame(height: 40)
        
    }
    
    var horizontalScrollDisableGesture: some Gesture {
        
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                mainScrollDisabled = true
            }.onEnded { _ in
                mainScrollDisabled = false
            }
        
    }
    
    /// Reset's Page ScrollView to it's Initial Position
    func resetScrollViews(_ from: PageHeader) {
        
        for index in pageHeaders.indices {
            
            let label = pageHeaders[index]
            
            if label.title != from.title {
                scrollPositions[index].scrollTo(y: 0)
            }
            
        }
        
    }
    
}

fileprivate extension ScrollGeometry {
    
    init() {
        self.init(contentOffset: .zero, contentSize: .zero, contentInsets: .init(.zero), containerSize: .zero)
    }
    
    var offsetY: CGFloat {
        contentOffset.y + contentInsets.top
    }
    
    var offsetX: CGFloat {
        contentOffset.x + contentInsets.leading
    }
    
}

#Preview {
    PageHeaderPreviewTest()
}
