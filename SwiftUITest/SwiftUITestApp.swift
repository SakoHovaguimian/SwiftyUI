//
//  SwiftUITestApp.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/11/23.
//

import SwiftUI
import Observation

@main
struct SwiftUITestApp: App {
    
    @State private var launchService = LaunchScreenService()
    @State private var opacity: Double = 1
    
    @State private var debouncedText = ""
    
    var body: some Scene {
        WindowGroup {
  
//            HomePageView()
//            SocialMediaView(image: Image("sunset"))
//            OnboardingViewCarousel()
            
//            OnKeyPressContentView()
//            DevToolsView()
//                .environmentObject(NavSettings())
            
            
//            BlurRepresentableView(
//                dismissAction: {
//                    print("DISMISS ACTION")
//                },
//                successAction: {
//                    print("SUCCESS ACTION")
//                })
//            TestActivityIndicatorView()
            
//            CustomObservorTextFieldView(debouncedText: debouncedText)
            
//            ZStack {
//                
//                // MARK: Replace this with initial ContentView
//                DevToolsView()
//                    .environmentObject(NavSettings())
//                
//                SplashScreenView()
//                    .opacity(self.opacity)
//                    .animation(.easeIn(duration: 0.3), value: self.opacity)
//                    .environment(self.launchService)
//                    .onChange(of: self.launchService.didFinishLaunching) { _, didFinishNewValue in
//                        self.opacity = didFinishNewValue ? 0 : 1
//                    }
//                
//            }
            
//            ProductionTabBarContentView()
            
        }
    }
    
}
