//
//  SwiftyUIApp.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/3/24.
//

import SwiftUI

@main
struct SwiftyUIApp: App {
    
    @State private var homeViewModel = HomeViewModel()
    @State private var envService = EnvService()
    
    var body: some Scene {
        
        WindowGroup {
            
//            HomeView(homeViewModel: self.homeViewModel)
//                .environment(self.envService)
//                .environment(self.homeViewModel)
            
            SomeTestView2()
            
        }
        
    }
    
}
