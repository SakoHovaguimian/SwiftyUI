//
//  SplashScreenView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/2/23.
//

import SwiftUI

struct SplashScreenView: View {
    
    @State private var isLoading: Bool = true
    
    @Environment(LaunchScreenService.self) private var launchScreenService
    
    var body: some View {
        
        SplashScreenItem(isLoading: self.$isLoading)
        .onChange(of: self.isLoading) { oldValue, newValue in
            
            if !newValue {
                
                self.launchScreenService
                    .setDidCompleteLaunching(true)
                
            }
            
        }
        
    }
    
}

#Preview {
    SplashScreenView()
}
