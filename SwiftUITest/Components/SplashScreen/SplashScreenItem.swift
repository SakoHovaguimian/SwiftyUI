//
//  SplashScreenItem.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/2/23.
//

import SwiftUI

struct SplashScreenItem: View {
    
    @Binding var isLoading: Bool
    
    @State private var size = 0.5
    @State private var opacity = 0.5

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
                    
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 120))
                        .symbolRenderingMode(.multicolor)
                        .foregroundStyle(AppColor.charcoal)
                    
                    Text("SwiftyUI")
                        .font(.system(size: 64, weight: .heavy, design: .rounded))
                        .foregroundColor(.black.opacity(0.80))
                    
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
                    self.size = 1.3
                }
                
                try? await Task.sleep(for: Duration.seconds(0.3))
                
                withAnimation(.easeIn) {
                    self.size = 10
                }
                
                self.isLoading = false
                
            }
            
        }
        
    }
    
}
