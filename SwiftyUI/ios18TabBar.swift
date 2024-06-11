//
//  ios18TabBar.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/11/24.
//

// Won't Compile. Blaming BETA

//import SwiftUI
//
//enum SomeDestination: Hashable {
//    case home
//    case search
//    case settings
//    case trends
//}
//
//struct NewTabBar: View {
//
//    @State private var selection: SomeDestination = .home
//    
//    var body: some View {
//        
//        // Should we bind to selection?
//        
//        TabView {
//            
//            Tab("home", systemImage: "home", value: ) {
//                TabViewHomeView()
//            }
//            
//            Tab("search", systemImage: "search", value: .search) {
//                TabViewSearchView()
//            }
//            
//            TabSection("Other") {
//                
//                Tab("trends", systemImage: "trends", value: .trends) {
//                    TabViewTrendsView()
//                }
//                Tab("settings", systemImage: "settings", value: .settings) {
//                    TabViewSettingsView()
//                }
//                
//            }
//            .tabViewStyle(.sidebarAdaptable)
//        }
//        
//    }
//    
//}
//
//struct TabViewHomeView: View {
//    
//    var body: some View {
//        
//        ZStack {
//            
//            Color.darkBlue
//                .ignoresSafeArea()
//            
//        }
//        
//    }
//    
//}
//
//struct TabViewSearchView: View {
//    
//    var body: some View {
//        
//        ZStack {
//            
//            Color.darkGreen
//                .ignoresSafeArea()
//            
//        }
//        
//    }
//    
//}
//
//struct TabViewTrendsView: View {
//    
//    var body: some View {
//        
//        ZStack {
//            
//            Color.darkPurple
//                .ignoresSafeArea()
//            
//        }
//        
//    }
//    
//}
//
//struct TabViewSettingsView: View {
//    
//    var body: some View {
//        
//        ZStack {
//            
//            Color.darkYellow
//                .ignoresSafeArea()
//            
//        }
//        
//    }
//    
//}
//
//#Preview {
//    NewTabBar()
//}
