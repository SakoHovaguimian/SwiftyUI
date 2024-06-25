//
//  ViewModelTest.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/15/24.
//

import SwiftUI

class User {
    var name: String?
}

class AuthService: ObservableObject {
    @Published var currentUser: User? // Example user property
    // Other properties and methods
}

class FirebaseService: ObservableObject {
    @Published var user: User? // Example user property
    // Other properties and methods
}

class AnalyticsService: ObservableObject {
    // Properties and methods
}

class GentlePathAPIService: ObservableObject {
    // Properties and methods
}

class MainViewModel: ObservableObject {
    @Published private(set) var apiService: GentlePathAPIService
    @Published private(set) var firebaseService: FirebaseService
    @Published private(set) var analyticsService: AnalyticsService
    @Published private(set) var authService: AuthService
    
    var shouldShowWelcomeScreen: Bool {
        return (self.authService.currentUser != nil && self.firebaseService.user != nil)
    }
    
    init(apiService: GentlePathAPIService,
         firebaseService: FirebaseService,
         analyticsService: AnalyticsService,
         authService: AuthService) {
        
        self.apiService = apiService
        self.firebaseService = firebaseService
        self.analyticsService = analyticsService
        self.authService = authService
                
        // Additional setup if needed
    }
    
    deinit {
        print("DE-INIT View Model")
    }
    
    func track() {
//        self.analyticsService.track(screen: .launch)
        print("Tracking The MainViewModel")
    }
}

struct MainView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var firebaseService: FirebaseService
    @EnvironmentObject private var analyticsService: AnalyticsService
    @EnvironmentObject private var apiService: GentlePathAPIService
    
    @StateObject private var mainViewModel: MainViewModel
    
    init() {
        let apiService = GentlePathAPIService()
        let firebaseService = FirebaseService()
        let analyticsService = AnalyticsService()
        let authService = AuthService()
        _mainViewModel = StateObject(wrappedValue: MainViewModel(apiService: apiService,
                                                                 firebaseService: firebaseService,
                                                                 analyticsService: analyticsService,
                                                                 authService: authService))
    }
        
    var body: some View {
        ZStack(alignment: .top) {
            ThemeManager
                .shared
                .background(.primary)
                .ignoresSafeArea()
            
            Color.darkRed
                .ignoresSafeArea()
            
            // Login / SignUp Flow
            
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .errorHandler(error: Bindable(self.authService).error, alertStyle: .simpleError(
//            message: "We couldn't log you in please try again!",
//            action: {
//                Task { try await self.authService.logout() }
//            }))
//        .animation(.easeInOut(duration: 1), value: self.userDefaultsService.didCompleteOnboarding)
//        .animation(.easeInOut(duration: 1), value: self.authService.currentUser)
    }
}

#Preview {
    MainView()
        .environmentObject(AuthService())
        .environmentObject(FirebaseService())
        .environmentObject(AnalyticsService())
        .environmentObject(GentlePathAPIService())
//        .environmentObject(UserDefaultsService())
}


#Preview {
    
    NavigationStack {
        
        NavigationLink("Something") {
            MainView()
        }
        
    }
    
}
