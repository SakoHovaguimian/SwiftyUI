//
//  ProductionTabBarContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/15/23.
//

import SwiftUI

// Refactor all placeholder code
// Check if current selection has badges and remove them if you do
// Find a way to bind the badges to the tab object so they can live as one

// Clean up newCustomTabBarView file...
// Support custom in Enum...
// Custom should take in Content as a param

public class TabBarStruct: Identifiable {
    
    var tabBarOption: TabBarOption
    var badgeCount: Int = 0
    
    init(tabBarOption: TabBarOption, badgeCount: Int) {
        
        self.tabBarOption = tabBarOption
        self.badgeCount = badgeCount
        
    }
    
}

public enum TabBarOption: Int, CaseIterable, Hashable {
    
    case home = 0
    case browse
    case discover
    case profile
    
    var tabBarItem: TabBarItem {
        
        switch self {
        case .home: return TabBarItem(title: "Home", iconName: "heart.fill", color: .pink)
        case .browse: return TabBarItem(title: "Browse", iconName: "magnifyingglass", color: .green)
        case .discover: return TabBarItem(title: "Discover", iconName: "globe", color: .orange)
        case .profile: return TabBarItem(title: "Profile", iconName: "person.fill", color: .indigo)
        }
        
    }
    
}

struct ProductionTabBarContentView: View {
    
    // MainCoordinator should pass these @State objects in for selection && shouldHideTabBar that way it can manage it
    // Navigation Service should receive a Binding<Bool> for shouldHideTabBarView so it could do it's thing...
    // NOTE: If we nest this tab bar in a navStack will the fullScreenCover be topLevel or the tabbar?

    @State private var tabs: [TabBarStruct] = TabBarOption.allCases.map({ .init(tabBarOption: $0, badgeCount: 0) })
    @State private var badges: [Int] = [0,0,0,0]
    @State var selection = TabBarOption.home.tabBarItem
    @State private var shouldHideTabBar: Bool = false
    
    var body: some View {
        
        TabBarViewBuilder(style: .zStack) {
            
            ForEach(self.tabs) { tab in
                
//                RoundedRectangle(cornerRadius: 0) // This is where the view goes
                
//                switch tab.tabBarOption {
//                case .home: print("TEST")
//                default: print("OTHER")
//                }
                MeshGradientView(colors: [
                    .yellow,
                    .red,
                    .pink,
                    .cyan
                ])
//                WStackExamplesView()
//                PhotoPickerTestView()
//                SideMenuTestView()
                    .tabBarItem(tab: tab.tabBarOption.tabBarItem, selection: selection)
//                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        resetBadgeCount(index: 0)
                    }
                
            }
            
        } tabBar: {
            
            TabBarDefaultView(
                tabs: self.tabs,
                selection: self.$selection,
                shouldHideTabBar: self.shouldHideTabBar,
                badges: self.badges,
                accentColor: .black,
                defaultColor: .gray,
                backgroundColor: .white,
                font: .system(size: 10, weight: .medium), // Pass Custom Font
                iconSize: 18,
                spacing: 2,
                horizontalInsetPadding: 2,
                verticalInsetPadding: 16,
                outerPadding: 24,
                cornerRadius: 11,
                shadowRadius: 23, tabBarAction: { tab in
                    
                    // Handle Tab Bar Tap Here
                    
//                    badges[0] = 1
//                    badges[1] = 3
//                    badges[2] = 7
//                    badges[3] = 9
                    Haptics.shared.vibrate(option: .heavy)
                    print("TAPPING THE TAB BAR")
                    
                }
            )
            
        }
        .onChange(of: self.selection) { _, newValue in
            
            // MARK: - This just resets badge count, doesn't need to be here
        
            let indexForTab = self.tabs
                .firstIndex(where: { $0.tabBarOption.tabBarItem == newValue })
            
            resetBadgeCount(index: indexForTab ?? 0)
            
        }
        
    }
    
    private func resetBadgeCount(index: Int) {
        self.badges[index] = 0
    }
    
}

struct ProductionTabBarContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ProductionTabBarContentView()
    }
    
}
