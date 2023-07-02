//
//  SplashScreenView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/2/23.
//

import SwiftUI

struct SplashScreenView: View {
    
    @State private var size = 0.5
    @State private var opacity = 0.5
    @State private var textOpacity = 1.0

    @Environment(LaunchScreenService.self) private var launchScreenService
    
    var body: some View {
        
        ZStack {
            
            AppColor
                .eggShell
                .opacity(1)
                .ignoresSafeArea()
            
            Image(.pattern)
                .resizable()
                .ignoresSafeArea()
                .opacity(0.2)
            
            VStack {
                
                VStack(spacing: 16) {
                    
                    Image(systemName: "hare.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.gray)
                    
                    Text("Hopper")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(.black.opacity(0.80))
                        .opacity(self.textOpacity)
                    
                }
                .scaleEffect(self.size)
                .opacity(self.opacity)
                .onAppear {
                    
                    withAnimation(.easeIn(duration: 1.2)) {
                        
                        self.size = 1
                        self.opacity = 1
                        
                    }
                    
                }
                
            }
            
        }
        .onAppear {
            
            Task {
                
                try? await Task.sleep(for: Duration.seconds(0.8))
                withAnimation(.easeIn) {
                    self.textOpacity = 0
                    self.size = 1.3
                }
                
                try? await Task.sleep(for: Duration.seconds(0.3))
                withAnimation(.easeIn) {
                    self.size = 100
                }
                
                self.launchScreenService
                    .setDidCompleteLaunching(true)
                
            }
            
        }
        
    }
    
}

#Preview {
    SplashScreenView()
}
