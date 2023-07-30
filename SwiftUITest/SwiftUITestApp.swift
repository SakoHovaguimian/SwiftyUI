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
    
    @StateObject var appStorageService = AppStorageService()
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
            
            let homeNavigationService = NavigationService()
            let searchNavigationService = NavigationService()
            let discoverNavigationService = NavigationService()
            let profileNavigationService = NavigationService()
            
            let finalNavBarTestView = FinalNavTabTest(
                homeNavigationService: homeNavigationService,
                searchNavigationService: searchNavigationService,
                discoverNavigationService: discoverNavigationService,
                profileNavigationService: profileNavigationService
            )
                            
            ZStack {
                
                // STEPS
                
                // MARK: - MainView
                // MARK: - Login // Check for user... user = opacity for this view... if not the transition is slide and opacity to MainView
                // MARK: - Onboarding // Check for appStorage flag
                // MARK: - SplashScreen // Every Launch
                                    
                    
                    finalNavBarTestView
                    .opacity(self.appStorageService.didCompleteOnboarding ? 1 : 0)
                    .animation(.easeIn(duration: 0.3), value: self.appStorageService.didCompleteOnboarding)
                
                // Do custom iris transitions
                // https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-custom-transition
                
                if !self.appStorageService.didCompleteOnboarding {
                    
                    ZStack {
                        Color.green
                            .ignoresSafeArea()
                            .opacity(self.appStorageService.didCompleteOnboarding ? 0 : 1)
                            .animation(.easeIn(duration: 0.3), value: self.appStorageService.didCompleteOnboarding)
                    }
                    
                }
//                
                Button(action: {
                    
                    DispatchQueue.main.async {
                        withAnimation {
                    self.appStorageService.set(didCompleteOnboarding: !self.appStorageService.didCompleteOnboarding)
                        }
                    }
                    
                }, label: {
                    Text("Press me")
                })
//                
                                SplashScreenView()
                                    .opacity(self.opacity)
                                    .animation(.easeIn(duration: 0.3), value: self.opacity)
                                    .environment(self.launchService)
                                    .onChange(of: self.launchService.didFinishLaunching) { _, didFinishNewValue in
                                        self.opacity = didFinishNewValue ? 0 : 1
                                    }
                
            }
//            .ignoresSafeArea()
            .animation(.easeIn(duration: 0.3), value: self.appStorageService.didCompleteOnboarding)

//            }
//            .animation(.bouncy(duration: 3), value: self.appStorageService.didCompleteOnboarding)
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
            
//            MeshGradientView()
//            SegmentedControlTestView()
            
        }
    }
    
}
