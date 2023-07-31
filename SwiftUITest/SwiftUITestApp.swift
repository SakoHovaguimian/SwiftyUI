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
    
    let homeNavigationService = NavigationService()
    let searchNavigationService = NavigationService()
    let discoverNavigationService = NavigationService()
    let profileNavigationService = NavigationService()
    
    init() {
        FirebaseApp.configure()
    }
    
    @State var codeInputText: String = ""
    @State private var debouncedText = ""
    
    @State var materialUIText = ""
    @State var materialUIPlaceholder = "Password"
    
    var body: some Scene {
        
        WindowGroup {
            TestBaseView()
//            mainViewStack
        }
        
    }
    
    var mainViewStack: some View {
        
        ZStack {
            
            // MARK: - NOTES
            // When you use a background color instead of a view in a V / ZStack the aniamtion is volitile
            // Try adding transitions again and seeing if this fixes it using built views
            
            // MARK: - MainView // Onboarding
             
            // Add a new conidtional to be the first one that checks if the user is signed in or not... then else if the rest
            if self.appStorageService.didCompleteOnboarding {
                tabBarView
            }
            else {
                onboaringView
            }
            
            // MARK: - Login // Check for user... user = opacity for this view... if not the transition is slide and opacity to MainView
            
            // MARK: - SplashScreen // Every Launch
            splashScreenView
  
//             TEMP BUTTON TO TOGGLE STATES

            Button(action: {

                DispatchQueue.main.async {
                    withAnimation {
                        self.appStorageService.set(didCompleteOnboarding: !self.appStorageService.didCompleteOnboarding)
                    }
                }

            }, label: {
                Text("Press me")
            })
            
        }
        .animation(.easeIn(duration: 0.3), value: self.appStorageService.didCompleteOnboarding)
        
    }
    
    var splashScreenView: some View {
        
        SplashScreenView()
            .opacity(self.opacity)
            .animation(.easeIn(duration: 0.3), value: self.opacity)
            .environment(self.launchService)
            .onChange(of: self.launchService.didFinishLaunching) { _, didFinishNewValue in
                self.opacity = didFinishNewValue ? 0 : 1
            }
        
    }
    
    var onboaringView: some View {
        
        ZStack {
            
            OnboardingViewCarousel()
                .opacity(self.appStorageService.didCompleteOnboarding ? 0 : 1)
                .animation(.easeIn(duration: 0.3), value: self.appStorageService.didCompleteOnboarding)
            
        }
        
    }
    
    var tabBarView: some View {
        
        FinalNavTabTest(
            homeNavigationService: self.homeNavigationService,
            searchNavigationService: self.searchNavigationService,
            discoverNavigationService: self.discoverNavigationService,
            profileNavigationService: self.profileNavigationService
        )
        .opacity(self.appStorageService.didCompleteOnboarding ? 1 : 0)
        .animation(.easeIn(duration: 0.3), value: self.appStorageService.didCompleteOnboarding)
        
        // Do custom iris transitions
        // https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-custom-transition
        
    }
    
}

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
