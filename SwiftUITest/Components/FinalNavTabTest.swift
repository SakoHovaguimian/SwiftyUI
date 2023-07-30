//
//  FinalNavTabTest.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/29/23.
//

import SwiftUI

// TODO
// 1. There is no way to know when views are dismissed
// We can add onChange to all the paths from the services, but we have no way to know the last view that was presented...

struct FinalNavTabTest: View {
    
    @ObservedObject var homeNavigationService: NavigationService
    @ObservedObject var searchNavigationService: NavigationService
    @ObservedObject var discoverNavigationService: NavigationService
    @ObservedObject var profileNavigationService: NavigationService
    
    @State private var tabs: [TabBarStruct] = TabBarOption.allCases.map({ .init(tabBarOption: $0, badgeCount: 0) })
    @State private var badges: [Int] = [0,0,0,0]
    @State var selection = TabBarOption.home.tabBarItem
    @State private var shouldHideTabBar: Bool = false
    
    var body: some View {
        
        TabBarViewBuilder(style: .zStack) {
            
            // MARK: - HOME
            
            NavigationStack(path: self.$homeNavigationService.pathItems) {
                
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.red.opacity(0.5).gradient)
                    .ignoresSafeArea()
                    .onTapGesture {
                        self.homeNavigationService.push(.redView)
                    }
                    .withNavigationDestination()
                    .withSheetDestination(self.$homeNavigationService.sheet)
                    .withFullScreenCover(self.$homeNavigationService.fullScreenCover)
                
            }
            .tabBarItem(
                tab: TabBarOption.home.tabBarItem,
                selection: self.selection
            )
            .edgesIgnoringSafeArea(.all)
            .environmentObject(self.homeNavigationService)
            
            // MARK: - SEARCH
            
            NavigationStack(path: self.$searchNavigationService.pathItems) {
                
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.blue.opacity(0.5).gradient)
                    .ignoresSafeArea()
                    .onTapGesture {
                        self.searchNavigationService.push(.blueView)
                    }
                    .withNavigationDestination()
                    .withSheetDestination(self.$searchNavigationService.sheet)
                    .withFullScreenCover(self.$searchNavigationService.fullScreenCover)
                
            }
            .tabBarItem(
                tab: TabBarOption.browse.tabBarItem,
                selection: self.selection
            )
            .edgesIgnoringSafeArea(.all)
            .environmentObject(self.searchNavigationService)
            
            // MARK: - DISCOVER
            
            NavigationStack(path: self.$discoverNavigationService.pathItems) {
                
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.orange.opacity(0.5).gradient)
                    .ignoresSafeArea()
                    .onTapGesture {
                        self.discoverNavigationService.push(.redView)
                    }
                    .withNavigationDestination()
                    .withSheetDestination(self.$discoverNavigationService.sheet)
                    .withFullScreenCover(self.$discoverNavigationService.fullScreenCover)
                
            }
            .tabBarItem(
                tab: TabBarOption.discover.tabBarItem,
                selection: self.selection
            )
            .edgesIgnoringSafeArea(.all)
            .environmentObject(self.discoverNavigationService)
            
            // MARK: - PROFILE
            
            NavigationStack(path: self.$profileNavigationService.pathItems) {
                
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.indigo.opacity(0.5).gradient)
                    .ignoresSafeArea()
                    .onTapGesture {
                        self.profileNavigationService.sheet = .purpleView
                    }
                    .withNavigationDestination()
                    .withSheetDestination(self.$profileNavigationService.sheet)
                    .withFullScreenCover(self.$profileNavigationService.fullScreenCover)
                
            }
            .tabBarItem(
                tab: TabBarOption.profile.tabBarItem,
                selection: self.selection
            )
            .edgesIgnoringSafeArea(.all)
            .environmentObject(self.profileNavigationService)
            
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
                shadowRadius: 23,
                tabBarAction: { tab in
                    
                    Haptics.shared.vibrate(option: .heavy)
                    print("TAPPING THE TAB BAR")
                    
                })
            
        }
        .onAppear(perform: {
            
            self.homeNavigationService.bindTabBarVisibility(self.$shouldHideTabBar)
            self.searchNavigationService.bindTabBarVisibility(self.$shouldHideTabBar)
            self.discoverNavigationService.bindTabBarVisibility(self.$shouldHideTabBar)
            self.profileNavigationService.bindTabBarVisibility(self.$shouldHideTabBar)
            
        })
        
    }
    
}
