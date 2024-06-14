//
//  ios18TabBar.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/11/24.
//

import SwiftUI

enum Pages: Hashable {
    
    case home
    case search
    case settings
    case trends
    
}

struct NewTabBar: View {

    @State private var selection: Pages = .home
    
    var body: some View {
        
        // Should we bind to selection?
        
        TabView(selection: self.$selection) {
            
            Tab("home", systemImage: "house.fill", value: .home) {
                TabViewHomeView()
            }
            
            Tab("search", systemImage: "magnifyingglass", value: .search) {
                TabViewSearchView()
            }
            
            Tab("trends", systemImage: "circle.fill", value: .trends) {
                TabViewTrendsView()
            }
            
            Tab("settings", systemImage: "gear", value: .settings) {
                TabViewSettingsView()
            }
            
        }
        .tabViewStyle(.sidebarAdaptable)
        
    }
    
}

struct TabViewHomeView: View {
    
    var body: some View {
        
        ZStack {
            
            Color.darkBlue
                .ignoresSafeArea()
            
        }
        
    }
    
}

struct TabViewSearchView: View {
    
    var body: some View {
        
        ZStack {
            
            Color.darkGreen
                .ignoresSafeArea()
            
        }
        
    }
    
}

struct TabViewTrendsView: View {
    
    var body: some View {
        
        ZStack {
            
            Color.darkPurple
                .ignoresSafeArea()
            
        }
        
    }
    
}

struct TabViewSettingsView: View {
    
    var body: some View {
        
        ZStack {
            
            Color.darkYellow
                .ignoresSafeArea()
            
        }
        
    }
    
}

#Preview {
    NewTabBar()
}
