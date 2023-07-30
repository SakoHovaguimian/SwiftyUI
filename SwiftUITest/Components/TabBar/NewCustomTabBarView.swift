//
//  NewCustomTabBarView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/14/23.
//

// Line: 91 Bookmark for custom tab bar icons like images or whatever

import SwiftUI

/// Customizable TabBar
//let floatingTabBar = TabBarDefaultView(
//    tabs: self.tabs,
//    selection: self.$selection,
//    badges: self.badges,
//    accentColor: .black,
//    defaultColor: .gray,
//    backgroundColor: .white,
//    font: .system(size: 10, weight: .medium),
//    iconSize: 18,
//    spacing: 2,
//    horizontalInsetPadding: 2,
//    verticalInsetPadding: 16,
//    outerPadding: 24,
//    cornerRadius: 11, // 99 for full corner raidus
//    shadowRadius: 23
//)
//
//let standardTabBar = TabBarDefaultView(
//    tabs: self.tabs,
//    selection: self.$selection,
//    badges: self.badges,
//    accentColor: .black,
//    defaultColor: .gray,
//    backgroundColor: .white,
//    font: .system(size: 10, weight: .medium),
//    iconSize: 18,
//    spacing: 4,
//    horizontalInsetPadding: 16,
//    verticalInsetPadding: 25,
//    outerPadding: 0,
//    cornerRadius: 0
//)

public struct TabBarDefaultView: View {
    
    let tabs: [TabBarStruct]
    @Binding var selection: TabBarItem
    private var badges: [Int] = []
    let accentColor: Color
    let defaultColor: Color
    let backgroundColor: Color?
    let font: Font
    let iconSize: CGFloat
    let spacing: CGFloat
    let horizontalInsetPadding: CGFloat
    let verticalInsetPadding: CGFloat
    let outerPadding: CGFloat
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let tabBarAction: (TabBarOption) -> ()
    
    @State var localSelection: TabBarItem
    var shouldHideTabBar: Bool = false
    
    public init(
        tabs: [TabBarStruct],
        selection: Binding<TabBarItem>,
        shouldHideTabBar: Bool = false,
        badges: [Int] = [],
        accentColor: Color = .blue,
        defaultColor: Color = .gray,
        backgroundColor: Color? = nil,
        font: Font = .caption,
        iconSize: CGFloat = 20,
        spacing: CGFloat = 2,
        horizontalInsetPadding: CGFloat = 10,
        verticalInsetPadding: CGFloat = 10,
        outerPadding: CGFloat = 0,
        cornerRadius: CGFloat = 0,
        shadowRadius: CGFloat = 0,
        tabBarAction: @escaping (TabBarOption) -> ()
    ) {
        self._selection = selection
        self.tabs = tabs
        self.shouldHideTabBar = shouldHideTabBar
        self.badges = badges
        self.accentColor = accentColor
        self.defaultColor = defaultColor
        self.backgroundColor = backgroundColor
        self.font = font
        self.iconSize = iconSize
        self.spacing = spacing
        self.verticalInsetPadding = verticalInsetPadding
        self.horizontalInsetPadding = horizontalInsetPadding
        self.outerPadding = outerPadding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.tabBarAction = tabBarAction
        
        self.localSelection = selection.wrappedValue
    }
    
    @Namespace private var namespace
    
    public var body: some View {
        
        let tabs = self.tabs.map({ $0.tabBarOption })
        
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                
                // MARK: - Having this code here let's us make custom properties in tabBar
                //                if tab.title == "Discover" {
                //
                ////                    VStack {
                //                        Image(systemName: "plus.circle.fill")
                //                            .tint(Color.white)
                //                            .frame(maxWidth: .infinity, minHeight: 48)
                //                            .background(Color.teal)
                //                            .clipShape(RoundedRectangle(cornerRadius: 12))
                //                            .padding(16)
                //                            .onTapGesture {
                //                                switchToTab(tab: tab)
                //                            }
                ////                    }
                //
                //                }
                //                else {
                
                let indexForTab = self.tabs.firstIndex(where: { $0.tabBarOption == tab })
                let badgeCountForTab = self.badges[indexForTab ?? 0]
                
                tabView(tab.tabBarItem, badgeCount: badgeCountForTab)
                    .background(Color.black.opacity(0.001))
                    .onTapGesture {
                        
                        self.tabBarAction(tab)
                        switchToTab(tab: tab.tabBarItem)
                        
                    }
                
            }
            
        }
        .padding(.horizontal, self.horizontalInsetPadding)
        .background(
            ZStack {
                if let backgroundColor = self.backgroundColor {
                    backgroundColor
                        .shadow(radius: self.shadowRadius)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color.clear
                }
            }
        )
        .cornerRadiusIfNeeded(cornerRadius: self.cornerRadius)
        .padding(self.outerPadding)
        .shadow(radius: self.shadowRadius)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: self.selection) { _, newTabSelection in
            withAnimation(.easeIn(duration: 0.3)) {
                self.localSelection = newTabSelection
            }
        }
        .offset(y: self.shouldHideTabBar ? 100 : 0)
        .animation(.bouncy, value: self.shouldHideTabBar)
        
    }
    
    private func switchToTab(tab: TabBarItem) {
        self.selection = tab
    }
    
}

extension View {
    
    @ViewBuilder func cornerRadiusIfNeeded(cornerRadius: CGFloat) -> some View {
        if cornerRadius > 0 {
            self
                .cornerRadius(cornerRadius)
        } else {
            self
        }
    }
    
}

private extension TabBarDefaultView {
    
    private func tabView(_ tab: TabBarItem, badgeCount: Int? = 0) -> some View {
        
        let tabItem = tab
        
        return VStack(spacing: self.spacing) {
            
            if let icon = tabItem.iconName {
                
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: self.iconSize, height: self.iconSize)
                    .foregroundColor(self.localSelection == tabItem ? tabItem.color : self.defaultColor)
                    .scaleEffect(self.localSelection == tabItem ? 1.2 : 1)
                    .animation(.easeIn, value: self.localSelection)
                
            }
            
            if let image = tabItem.image {
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(self.localSelection == tabItem ? tabItem.color : self.defaultColor)
                    .frame(width: self.iconSize, height: self.iconSize)
                    .scaleEffect(self.localSelection == tabItem ? 1.2 : 1)
                    .animation(.easeIn, value: self.localSelection)
                
            }
            
            if let title = tabItem.title {
                
                Text(title)
                    .scaleEffect(self.localSelection == tabItem ? 1.2 : 1)
                    .animation(.easeIn, value: self.localSelection)
                    .foregroundColor(self.localSelection == tabItem ? tabItem.color : self.defaultColor)
                
            }
            
        }
        .font(self.font)
        .foregroundColor(self.selection == tabItem ? self.accentColor : self.defaultColor)
        .frame(maxWidth: .infinity)
        .padding(.vertical, self.verticalInsetPadding)
        .overlay(
            
            ZStack {
                
                if let count = badgeCount, count > 0 {
                    
                    Text("\(count)")
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding(5)
                        .background(.red)
                        .clipShape(Circle())
                        .offset(x: self.iconSize * 0.9, y: -self.iconSize * 0.9)
                    
                }
                
            }
            
        )
        .background(
            
            ZStack {
                
                if self.localSelection == tabItem {
                    
                    RoundedRectangle(cornerRadius: 7)
                        .fill(self.localSelection.color?.opacity(0.2) ?? .yellow.opacity(0.2))
                        .matchedGeometryEffect(id: "background_rectangle", in: namespace)
                    
                }
                
            }
            .padding(8)
        )
        
    }
    
}

import Foundation
import UIKit

public struct TabBarItem: Hashable {
    
    public let title: String?
    public let iconName: String?
    public let image: UIImage?
    public let color: Color?
    public private(set) var badgeCount: Int?
    
    public init(title: String?,
                iconName: String? = nil,
                image: UIImage? = nil,
                badgeCount: Int? = 0,
                color: Color? = .blue) {
        
        self.title = title
        self.iconName = iconName
        self.image = image
        self.badgeCount = badgeCount
        self.color = color
        
    }
    
    public mutating func updateBadgeCount(to count: Int) {
        badgeCount = count
    }
    
}

struct TabBarItemsPreferenceKey: PreferenceKey {
    
    static var defaultValue: [AnyHashable] = []
    
    static func reduce(value: inout [AnyHashable], nextValue: () -> [AnyHashable]) {
        value += nextValue()
    }
    
}

struct TabBarItemViewModifer: ViewModifier {
    
    @State private var didLoad: Bool = false
    let tab: AnyHashable
    let selection: AnyHashable
    
    func body(content: Content) -> some View {
        ZStack {
            if didLoad || selection == tab {
                content
                    .preference(key: TabBarItemsPreferenceKey.self, value: [tab])
                    .opacity(selection == tab ? 1 : 0)
                    .onAppear {
                        didLoad = true
                    }
            }
        }
    }
    
}

public extension View {
    
    /// Tag a View with a value. Use selection to determine which tab is currently displaying.
    func tabBarItem(tab: AnyHashable, selection: AnyHashable) -> some View {
        modifier(TabBarItemViewModifer(tab: tab, selection: selection))
    }
    
}

/// Tabs are loaded lazily, as they are selected. Each tab's .onAppear will only be called on first appearance. Set DisplayStyle to .vStack to position TabBar vertically below the Content. Use .zStack to put the TabBar in front of the Content .
public struct TabBarViewBuilder<Content:View, TabBar: View>: View {
    
    public enum DisplayStyle {
        case vStack
        case zStack
    }
    
    let style: DisplayStyle
    let content: Content
    let tabBar: TabBar
    
    public init(
        style: DisplayStyle = .vStack,
        @ViewBuilder content: () -> Content,
        @ViewBuilder tabBar: () -> TabBar) {
            self.style = style
            self.content = content()
            self.tabBar = tabBar()
        }
    
    public var body: some View {
        layout
    }
    
    @ViewBuilder var layout: some View {
        switch style {
        case .vStack:
            VStack(spacing: 0) {
                ZStack {
                    content
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                tabBar
                    .offset(y: 24)
            }
        case .zStack:
            ZStack(alignment: .bottom) {
                
                Color.clear
                    .ignoresSafeArea()
                
                content
                Spacer()
                tabBar
                    .offset(y: 24)
            }
            .background(Color.clear)
        }
    }
}

