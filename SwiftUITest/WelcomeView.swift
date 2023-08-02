//
//  WelcomeView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/31/23.
//

import SwiftUI

struct WelcomItem: Hashable {
    
    var title: String
    var message: String
    var image: String
    
}

struct WelcomeView: View {
    
    let items: [WelcomItem] = [
        .init(
            title: "Your recordings",
            message: "Welcome to the new app where we have a bunch of cool things",
            image: "heart.fill"
        ),
        .init(
            title: "Your recordings",
            message: "Welcome to the new app where we have a bunch of cool things. Welcome to the new app where we have a bunch of cool things. Welcome to the new app where we have a bunch of cool things",
            image: "heart.fill"
        ),
        .init(
            title: "Your recordings",
            message: "Welcome to the new app where we have a bunch of cool things",
            image: "heart.fill"
        ),
    ]
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            Color.black
                .opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                Image(systemName: "bell")
                    .resizable()
                    .frame(width: 85, height: 85)
                    .foregroundStyle(AppColor.brandGreen.gradient)
                    .padding(.top, 32)
                
                Text("Welcome to Rival")
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .fontDesign(.default)
                    .multilineTextAlignment(.center)
                
                Rectangle()
                    .fill(.clear)
                    .frame(height: 24)

                ForEach(self.items, id: \.self) { item in
                    welcomeItem(item: item)
                }
                
            }
            .padding(.horizontal, 32)
            
        }
        .safeAreaInset(edge: .bottom) {
            
            Button("Continue") {
                
            }
            .buttonStyle(AppButtonStyle())
            .padding(.horizontal, 32)
            .customSafeAreaPadding(padding: 16)
            
        }
        
    }
    
    private func textStack(item: WelcomItem) -> some View {
        
        VStack(alignment: .leading) {
            
            Text(item.title)
                .foregroundStyle(.white)
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
            
            Text(item.message)
                .foregroundStyle(Color(uiColor: .lightGray))
                .font(.subheadline)
                .fontWeight(.regular)
                .fontDesign(.rounded)
            
            
        }
        
    }
    
    private func welcomeItem(item: WelcomItem) -> some View {
        
        HStack(spacing: 16) {
        
            Image(systemName: item.image)
                .resizable()
                .frame(width: 24, height: 20)
                .foregroundStyle(AppColor.brandGreen.gradient)
            
            textStack(item: item)
            
        }
        
    }
    
}

#Preview {
    WelcomeView()
}
