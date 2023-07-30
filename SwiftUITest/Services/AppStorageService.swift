//
//  AppStorageService.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/29/23.
//

import SwiftUI

// Maybe have more services

// 1. user settings
// 2. app states
// 3. remote config things

enum Setting: String {
    
    case theme
    case email
    case token
    case didCompleteOnboarding
    
}

enum Theme: String, CaseIterable {
    
    case light
    case dark
    case custom
    
}

@MainActor
class AppStorageService: ObservableObject {
    
    @AppStorage(Setting.theme.rawValue) private(set) var theme: Theme = .light
    @AppStorage(Setting.email.rawValue) private(set) var email: String = "email"
    @AppStorage(Setting.token.rawValue) private(set) var token: String = "token"
    @AppStorage(Setting.didCompleteOnboarding.rawValue) private(set) var didCompleteOnboarding: Bool = false
    
    func set(theme: Theme) {
        self.theme = theme
    }
    
    func set(email: String) {
        self.email = email
    }
    
    func set(token: String) {
        self.token = token
    }
    
    func set(didCompleteOnboarding: Bool) {
        self.didCompleteOnboarding = didCompleteOnboarding
    }
    
}

struct AppStorageTestView: View {
    
    @ObservedObject private var appStorageService = AppStorageService()
    
    var body: some View {
        
        Text(self.appStorageService.theme.rawValue)
            .onTapGesture {
                
                self.appStorageService.set(didCompleteOnboarding: !self.appStorageService.didCompleteOnboarding)
                self.appStorageService.set(theme: Theme.allCases.randomElement()!)
                
            }
        
        if self.appStorageService.didCompleteOnboarding {
            
            Text(self.appStorageService.email)
                .onTapGesture {
                    self.appStorageService.set(email: "Custom Stored Email")
                }
            
            Text(self.appStorageService.token)
                .onTapGesture {
                    self.appStorageService.set(token: "Custom Stored Token")
                }
            
        }
        
        
    }
    
}

#Preview {
    AppStorageTestView()
}
