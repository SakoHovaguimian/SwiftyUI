//
//  BaseCardView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/20/23.
//

import SwiftUI

struct BaseCardView: View {
    
    var body: some View {
    
        ZStack {
            
            Color(.secondarySystemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                
                HStack {
                    
                    Label("Profile", systemImage: "person.fill")
                        .labelStyle(CustomLabelStyle())
                        .frame(maxWidth: .infinity)
                        .fontDesign(.rounded)
                        .font(.caption)
                    
                    
                    Label("Safari", systemImage: "safari.fill")
                        .labelStyle(CustomLabelStyle())
                        .frame(maxWidth: .infinity)
                        .fontDesign(.rounded)
                        .font(.caption)
                    
                    Label("Favorites", systemImage: "heart.fill")
                        .labelStyle(CustomLabelStyle())
                        .frame(maxWidth: .infinity)
                        .fontDesign(.rounded)
                        .font(.caption)
                    
                }
                .foregroundStyle(.black)
                
                Image(.sunset)
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .cornerRadius(11)
                    .padding(.horizontal, 16)
                
            }
            .cardBackground()
//            .background(Color(.secondarySystemBackground)
//              .shadow(color: Color.black, radius: 23)
//            )
//            .clipped()
            
        }
        
    }
    
}

struct CardBackground: ViewModifier {
    
    func body(content: Content) -> some View {
        
        content
            .padding(.top, 16)
            .background(Color(uiColor: .systemPurple).opacity(1))
            .cornerRadius(20)
            .padding(.horizontal, 16)
            .shadow(color: Color.black.opacity(0.6), radius: 6, y: 0)
        
    }
    
}

extension View {
    func cardBackground() -> some View {
        modifier(CardBackground())
    }
}

#Preview {
    BaseCardView()
}


struct CustomLabelStyle: LabelStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        
        HStack(spacing: 8) {
            configuration.icon
            configuration.title
        }
        
    }
    
}
