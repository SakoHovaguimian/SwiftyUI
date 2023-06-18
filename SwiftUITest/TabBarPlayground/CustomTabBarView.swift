////
////  CustomTabBarView.swift
////  SwiftUITest
////
////  Created by Sako Hovaguimian on 6/13/23.
////
//
//import SwiftUI
//
//struct AppTabBarView: View {
//    
//    // MARK: -  PROPERTY
//    
//    @State private var selection: String = "home"
//    @State private var tabSelection: TabBarItem = .home
//    
//    // MARK: -  BODY
//    
//    var body: some View {
//        
//        CustomTabBarContainerView(selection: self.$tabSelection) {
//            
//            CustomProgressBarTest()
//                .tabBarItem(tab: .home, selection: self.$tabSelection)
//            
//            SocialMediaView()
//                .tabBarItem(tab: .favorites, selection: self.$tabSelection)
//            
//            GridView()
//                .tabBarItem(tab: .profile, selection: self.$tabSelection)
//            
//            SomeView()
//                .tabBarItem(tab: .messages, selection: self.$tabSelection)
//            
//        }
//        
//    }
//}
//
//// MARK: -  PREVIEW
//
//struct AppTabBarView_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        AppTabBarView()
//    }
//    
//}
//
//enum TabBarItem: Hashable {
//    
//    case home, favorites, profile, messages, custom
//    
//    var iconName: String {
//        switch self {
//        case .home: return "house"
//        case .favorites: return "heart"
//        case .profile: return "person"
//        case .messages: return "message"
//        case .custom: return "custom"
//        }
//    }
//    
//    var title: String {
//        switch self {
//        case .home: return "Home"
//        case .favorites: return "Favorites"
//        case .profile: return "Profile"
//        case .messages: return "Messages"
//        case .custom: return "custom"
//        }
//    }
//    
//    var color: Color {
//        switch self {
//        case .home: return Color.blue
//        case .favorites: return Color.red
//        case .profile: return Color.green
//        case .messages: return Color.orange
//        case .custom: return Color.black
//        }
//    }
//}
//
//// MARK: -  Create PreferenceKey
//
//struct TabBarItemsPreferenceKey: PreferenceKey {
//    
//    static var defaultValue: [TabBarItem] = []
//    
//    static func reduce(value: inout [TabBarItem], nextValue: () -> [TabBarItem]) {
//        value += nextValue()
//    }
//    
//}
//
//// MARK: -  ViewModifier
//
//struct TabBarItemViewModifier: ViewModifier {
//    
//    let tab: TabBarItem
//    @Binding var selection: TabBarItem
//    
//    func body(content: Content) -> some View {
//        
//        content
//            .opacity(selection == tab ? 1.0 : 0.0)
//            .preference(key: TabBarItemsPreferenceKey.self, value: [tab])
//        
//    }
//    
//}
//
//// MARK: - Extenstion
//
//extension View {
//    
//    func tabBarItem(tab: TabBarItem, selection: Binding<TabBarItem>) -> some View {
//        
//        self.modifier(TabBarItemViewModifier(
//            tab: tab,
//            selection: selection
//        ))
//        
//    }
//    
//}
//
//struct CustomTabBarContainerView<Content:View>: View {
//    
//    @Binding var selection: TabBarItem
//    @State private var tabs: [TabBarItem] = []
//    
//    let content: Content
//    
//    init(selection: Binding<TabBarItem>, @ViewBuilder content: () -> Content) {
//        self._selection = selection
//        self.content = content()
//    }
//    
//    var body: some View {
//        
//        GeometryReader { geo in
//            
//            ZStack(alignment: .bottom) {
//                
//                content
////                    .frame(
////                        width: geo.size.width,
////                        height: geo.size.height
////                    )
////                    .ignoresSafeArea()
//                
//                    CustomTabBarView(
//                        tabs: self.tabs,
//                        selection: self.$selection,
//                        localSelection: self.selection
//                    )
//                
//            }
//            .ignoresSafeArea(.keyboard, edges: .bottom)
//            .onPreferenceChange(TabBarItemsPreferenceKey.self) { value in
//                self.tabs = value
//            }
//            
//        }
//        
//    }
//    
//}
//
//struct CustomTabBarContainerView_Previews: PreviewProvider {
//    
//    static let tabs: [TabBarItem] = [
//        .home, .favorites, .profile, .messages
//    ]
//    
//    static var previews: some View {
//        CustomTabBarContainerView(selection: .constant(tabs.first!)) {
//            Color.red
//        }
//    }
//}
//
//// MARK: -  VIEW
//struct CustomTabBarView: View {
//    
//    // MARK: -  PROPERTY
//    
//    let tabs: [TabBarItem]
//    
//    @Binding var selection: TabBarItem
//    @Namespace private var namespace
//    @State var localSelection: TabBarItem
//    
//    // MARK: - BODY
//    
//    var body: some View {
//        
//        self.tabBarView
//            .onChange(of: selection) { newValue in
//                withAnimation(.easeInOut) {
//                    self.localSelection = newValue
//                }
//            }
//    }
//    
//    private func switchToTab(tab: TabBarItem) {
//        self.selection = tab
//    }
//    
//}
//
//// MARK: -  PREVIEW
//struct CustomTabBarView_Previews: PreviewProvider {
//    
//    static let tabs: [TabBarItem] = [
//        .home, .favorites, .profile
//    ]
//    static var previews: some View {
//        VStack {
//            Spacer()
//            CustomTabBarView(tabs: tabs, selection: .constant(tabs.first!), localSelection: tabs.first!)
//        }
//    }
//}
//
//// tabBarVersion2
//extension CustomTabBarView {
//    
//    private func buildTabItemView(tab: TabBarItem) -> some View {
//        
//        VStack {
//            Image(systemName: tab.iconName)
//                .font(.subheadline)
//            Text(tab.title)
//                .font(.system(size: 10, weight: .semibold, design: .rounded))
//        } //: VSTACK
//        .foregroundColor(localSelection == tab ? tab.color : Color.gray)
//        .padding(.vertical, 8)
//        .frame(maxWidth: .infinity)
//        .background(
//            ZStack {
//                if localSelection == tab {
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(tab.color.opacity(0.2))
//                        .matchedGeometryEffect(id: "background_rectangle", in: namespace)
//                }
//            } //: ZSTACK
//        )
//    }
//    
//    private var tabBarView: some View {
//        HStack {
//            ForEach(tabs, id: \.self) { tab in
//                buildTabItemView(tab: tab)
//                    .onTapGesture {
//                        switchToTab(tab: tab)
//                    }
//            }
//        } //: HSTACK
//        .padding(6)
//        .background(Color.white.ignoresSafeArea(edges: .bottom))
//        .cornerRadius(10)
//        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
//        .padding(.horizontal)
//    }
//    
//}
//
