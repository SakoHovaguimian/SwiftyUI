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

public class TabBarStruct {
    
    var tabBarOption: TabBarOption
    var badgeCount: Int = 0
    
    init(tabBarOption: TabBarOption, badgeCount: Int) {
        
        self.tabBarOption = tabBarOption
        self.badgeCount = badgeCount
        
    }
    
}

public enum TabBarOption: CaseIterable {
    
    case home
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

    @State private var tabs: [TabBarStruct] = TabBarOption.allCases.map({ .init(tabBarOption: $0, badgeCount: 0) })
    @State private var badges: [Int] = [0,0,0,0]
    @State var selection = TabBarOption.home.tabBarItem
    
    var body: some View {
        
        TabBarViewBuilder(style: .zStack) {
            
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.pink)
                .tabBarItem(tab: tabs[0].tabBarOption.tabBarItem, selection: selection)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    badges[0] = 1
                    badges[1] = 3
                    badges[2] = 7
                    badges[3] = 9
                    Haptics.shared.vibrate(option: .heavy)
                }
                .onAppear {
//                    resetBadgeCount(index: 0)
                }
            //                            .ignoresSafeArea()
            
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.green)
                .onAppear {
//                    resetBadgeCount(index: 1)
                }
                .tabBarItem(tab: tabs[1].tabBarOption.tabBarItem, selection: selection)
                .edgesIgnoringSafeArea(.all)
            
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.orange)
                .onAppear {
//                    resetBadgeCount(index: 2)
                }
                .tabBarItem(tab: tabs[2].tabBarOption.tabBarItem, selection: selection)
                .edgesIgnoringSafeArea(.all)
            
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.indigo)
                .onAppear {
//                    resetBadgeCount(index: 3)
                }
                .tabBarItem(tab: tabs[3].tabBarOption.tabBarItem, selection: selection)
                .edgesIgnoringSafeArea(.all)
            
        } tabBar: {
            TabBarDefaultView(
                tabs: self.tabs,
                selection: self.$selection,
                badges: self.badges,
                accentColor: .black,
                defaultColor: .gray,
                backgroundColor: .white,
                font: .system(size: 10, weight: .medium),
                iconSize: 18,
                spacing: 2,
                horizontalInsetPadding: 2,
                verticalInsetPadding: 16,
                outerPadding: 24,
                cornerRadius: 11, // 99 for full corner raidus
                shadowRadius: 23)
        }
        .onChange(of: self.selection) { newValue in
        
            let indexForTab = self.tabs.firstIndex(where: { $0.tabBarOption.tabBarItem == newValue })
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
