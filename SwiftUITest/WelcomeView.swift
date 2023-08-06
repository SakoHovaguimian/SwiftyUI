//
//  WelcomeView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/31/23.
//

import SwiftUI

struct WelcomeView: View {
    
    struct ListItem: Hashable {
        
        var title: String
        var message: String
        var image: String
        
        static var DUMMY_DATA: [ListItem] {
            
            return [
                .init(
                    title: "Your recordings",
                    message: "Welcome to the new app where we have a bunch of cool things",
                    image: "bell.fill"
                ),
                .init(
                    title: "Your recordings",
                    message: "Welcome to the new app where we have a bunch of cool things. Welcome to the new app where we have a bunch of cool things.",
                    image: "dollarsign.circle.fill"
                ),
                .init(
                    title: "Your recordings",
                    message: "Welcome to the new app where we have a bunch of cool things",
                    image: "trophy.fill"
                ),
            ]
            
        }
        
    }
    
    let items: [ListItem]
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            LinearGradient(
                colors: [Color(hex: "#1C2227"), .black],//AppColor.charcoal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                Image(.iconLogo)
                    .resizable()
                    .frame(width: 85, height: 85)
                    .foregroundStyle(AppColor.brandGreen.gradient)
                    .padding(.top, 32)
                
                Text("Welcome to Rival")
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .fontWeight(.black)
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
            
            AppButton(
                title: "Welcome",
                action: {
                    print("Something clicked")
                })
            .appShadow(style: .neon(AppColor.brandGreen))
            .padding(.horizontal, 32)
            .customSafeAreaPadding(padding: 16)
            
        }
        
    }
    
    private func textStack(item: ListItem) -> some View {
        
        VStack(alignment: .leading) {
            
            Text(item.title)
                .foregroundStyle(.white)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            
            Text(item.message)
                .foregroundStyle(Color(uiColor: .lightGray))
                .font(.system(size: 18, weight: .regular, design: .rounded))
            
            
        }
        
    }
    
    private func welcomeItem(item: ListItem) -> some View {
        
        HStack(spacing: 16) {
        
            Image(systemName: item.image)
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundStyle(AppColor.brandGreen.gradient)
            
            textStack(item: item)
            
        }
        
    }
    
}

#Preview {
    WelcomeView(items: WelcomeView.ListItem.DUMMY_DATA)
}
