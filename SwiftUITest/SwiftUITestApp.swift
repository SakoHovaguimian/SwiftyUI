//
//  SwiftUITestApp.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/11/23.
//

import SwiftUI

@main
struct SwiftUITestApp: App {
    
    var body: some Scene {
        WindowGroup {
  
//            HomePageView()
//            SocialMediaView(image: Image("sunset"))
//            OnboardingViewCarousel()
            DevToolsView()
                .environmentObject(NavSettings())
            
        }
    }
    
}
