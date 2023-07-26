//
//  SwiftUITestApp.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/11/23.
//

import SwiftUI
import Observation
import FirebaseCore

@main
struct SwiftUITestApp: App {
        
    @State private var launchService = LaunchScreenService()
    @State private var opacity: Double = 1
    
    @StateObject var navigationService = NavigationService()
    
    init() {
        FirebaseApp.configure()
    }
    
    @State var codeInputText: String = ""
    @State private var debouncedText = ""
    
    @State var materialUIText = ""
    @State var materialUIPlaceholder = "Password"
    
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

//            ArcMenuButtonView()
//            CodeInputView(codeInput: $codeInputText)
//            FirebaseTestView(
//                firebaseService: FirebaseService(),
//                navigationService: self.navigationService
//            )
            
//            CoordinatorTestView(
//                firebaseService: FirebaseService(),
//                navigationService: self.navigationService
//            )
            
//            BaseCardView()
//            TransitionTestView()
//            MatchedGeoView()
//            PresentationHeightContentView()
//            WaterFillView()
//            SuperFormContentView()
//            MaterialUITextField(
//                text: self.materialUIText,
//                placeholder: self.materialUIPlaceholder,
//                isSecureEntry: true
//            )
//            .padding(.horizontal, 32)
//            BoomView()
//            
//            DemoFitnessCardView()
//            WStackExamplesView()
            
//            GradientCardView()
            
//            ProductionTabBarContentView()
            
            MeshGradientView()
            
        }
    }
    
}
