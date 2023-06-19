//
//  SuperCustomTabBarView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/13/23.
//

import SwiftUI

struct SuperAppTabBarView: View {
    
    // MARK: -  PROPERTY
    
    @State private var selection: String = "home"
    @State private var tabSelection: SuperTabBarItem = .home
    
    // MARK: -  BODY
    
    var body: some View {
        
        SuperCustomTabBarContainerView(selection: self.$tabSelection) {
            
            CustomProgressBarTest()
                .superTabBarItem(tab: .home, selection: self.$tabSelection)
            
            SocialMediaView()
                .superTabBarItem(tab: .favorites, selection: self.$tabSelection)
            
            FirstPlaygroundView()
//                .ignoresSafeArea()
                .superTabBarItem(tab: .custom, selection: self.$tabSelection)
            
            GridView()
                .superTabBarItem(tab: .profile, selection: self.$tabSelection)
            
            WildButtonView()
                .superTabBarItem(tab: .messages, selection: self.$tabSelection)
            
        }
        
    }
}

// MARK: -  PREVIEW

struct SuperAppTabBarView_Previews: PreviewProvider {
    
    static var previews: some View {
        SuperAppTabBarView()
    }
    
}

enum SuperTabBarItem: Hashable {
    
    case home, favorites, custom, profile, messages
    
    var iconName: String {
        switch self {
        case .home: return "house"
        case .favorites: return "heart"
        case .profile: return "person"
        case .messages: return "message"
        case .custom: return ""
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .favorites: return "Favorites"
        case .profile: return "Profile"
        case .messages: return "Messages"
        case .custom: return ""
        }
    }
    
    var color: Color {
        switch self {
        case .home: return Color.blue
        case .favorites: return Color.red
        case .profile: return Color.green
        case .messages: return Color.orange
        case .custom: return Color.teal
        }
    }
}

// MARK: -  Create PreferenceKey

struct SuperTabBarItemsPreferenceKey: PreferenceKey {
    
    static var defaultValue: [SuperTabBarItem] = []
    
    static func reduce(value: inout [SuperTabBarItem], nextValue: () -> [SuperTabBarItem]) {
        value += nextValue()
    }
    
}

// MARK: -  ViewModifier

struct SuperTabBarItemViewModifier: ViewModifier {
    
    let tab: SuperTabBarItem
    @Binding var selection: SuperTabBarItem
    
    func body(content: Content) -> some View {
        
        content
            .opacity(selection == tab ? 1.0 : 0.0)
            .preference(key: SuperTabBarItemsPreferenceKey.self, value: [tab])
        
    }
    
}

// MARK: - Extenstion

extension View {

    func superTabBarItem(tab: SuperTabBarItem, selection: Binding<SuperTabBarItem>) -> some View {

        self.modifier(SuperTabBarItemViewModifier(
            tab: tab,
            selection: selection
        ))

    }

}

struct SuperCustomTabBarContainerView<Content:View>: View {
    
    @Binding var selection: SuperTabBarItem
    @State private var tabs: [SuperTabBarItem] = []
    
    let content: Content
    
    init(selection: Binding<SuperTabBarItem>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack(alignment: .bottom) {
                
                content
//                    .frame(
//                        width: geo.size.width,
//                        height: geo.size.height
//                    )
//                    .ignoresSafeArea()
                
                    SuperCustomTabBarView(
                        tabs: self.tabs,
                        selection: self.$selection,
                        localSelection: self.selection
                    )
                
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onPreferenceChange(SuperTabBarItemsPreferenceKey.self) { value in
                self.tabs = value
            }
            
        }
        
    }
    
}

struct SuperCustomTabBarContainerView_Previews: PreviewProvider {
    
    static let tabs: [SuperTabBarItem] = [
        .home, .favorites, .custom, .profile, .messages
    ]
    
    static var previews: some View {
        SuperCustomTabBarContainerView(selection: .constant(tabs.first!)) {
            Color.red
        }
    }
    
}

// MARK: -  VIEW
struct SuperCustomTabBarView: View {
    
    // MARK: -  PROPERTY
    
    let tabs: [SuperTabBarItem]
    
    @Binding var selection: SuperTabBarItem
    @Namespace private var namespace
    @State var localSelection: SuperTabBarItem
    
    // MARK: - BODY
    
    var body: some View {
        
        self.tabBarView
            .onChange(of: selection) { newValue in
                withAnimation(.easeInOut) {
                    self.localSelection = newValue
                }
            }
    }
    
    private func switchToTab(tab: SuperTabBarItem) {
        self.selection = tab
    }
    
}

// MARK: -  PREVIEW
struct SuperCustomTabBarView_Previews: PreviewProvider {
    
    static let tabs: [SuperTabBarItem] = [
        .home, .favorites, .profile
    ]
    static var previews: some View {
        VStack {
            Spacer()
            SuperCustomTabBarView(tabs: tabs, selection: .constant(tabs.first!), localSelection: tabs.first!)
        }
    }
}

// tabBarVersion2
extension SuperCustomTabBarView {
    
    private func buildTabItemView(tab: SuperTabBarItem) -> some View {
        
        VStack {
            Image(systemName: tab.iconName)
                .font(.subheadline)
            Text(tab.title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
        } //: VSTACK
        .foregroundColor(localSelection == tab ? tab.color : Color.gray)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                if localSelection == tab {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(tab.color.opacity(0.2))
                        .matchedGeometryEffect(id: "background_rectangle", in: namespace)
                }
            } //: ZSTACK
        )
    }
    
    private var tabBarView: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                
                if tab == .custom {
                    
                    Image(systemName: "plus.circle.fill")
                        .tint(Color.white)
                        .frame(width: 32, height: 32)
                        .background(Color.teal)
                        .clipShape(Circle())
                        .onTapGesture {
                            switchToTab(tab: tab)
                        }
                    
                    
                }
                else {
                    
                    buildTabItemView(tab: tab)
                        .onTapGesture {
                            switchToTab(tab: tab)
                        }
                    
                }

            }
        } //: HSTACK
        .padding(6)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
}

