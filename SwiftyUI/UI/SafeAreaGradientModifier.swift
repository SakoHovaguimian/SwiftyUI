//
//  SafeAreaGradientModifier.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/5/24.
//


import SwiftUI

struct SafeAreaGradientModifier: ViewModifier {
    
    var gradient: LinearGradient
    var edges: Edge.Set = .all

    func body(content: Content) -> some View {
        content
            .background(
                gradient
                    .ignoresSafeArea(edges: edges)
            )
    }
    
}

extension View {
    func safeAreaGradientBackground(
        colors: [Color],
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .center,
        edges: Edge.Set = .all
    ) -> some View {
        let gradient = LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
        return self.modifier(SafeAreaGradientModifier(gradient: gradient, edges: edges))
    }
}

struct SafeAreaGradientView: View {
    var body: some View {
        ZStack {
            
            Color.indigo.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    
                    RoundedRectangle(cornerRadius: .appSmall)
                        .fill(.mint)
                        .frame(height: 120)
                    
                    RoundedRectangle(cornerRadius: .appSmall)
                        .fill(.mint)
                        .frame(height: 120)
                    
                    RoundedRectangle(cornerRadius: .appSmall)
                        .fill(.mint)
                        .frame(height: 120)
                    
                    RoundedRectangle(cornerRadius: .appSmall)
                        .fill(.mint)
                        .frame(height: 120)
                    
                    RoundedRectangle(cornerRadius: .appSmall)
                        .fill(.mint)
                        .frame(height: 120)
                    
                    RoundedRectangle(cornerRadius: .appSmall)
                        .fill(.mint)
                        .frame(height: 120)
                    
                }
                .padding(.horizontal, .medium)
            }
            .background(.indigo)
            .safeAreaInset(edge: .bottom) {
                
                AppButton(title: "Please tap me", titleColor: .white, backgroundColor: .darkPurple) {}
                    .frame(maxWidth: .infinity)
                    .padding(.top, .xLarge)
                    .padding(.bottom, .small)
                    .padding(.horizontal, .large)
                    .safeAreaGradientBackground(colors: [.clear, .indigo])
                
            }
        }
            
    }
}

#Preview {
    SafeAreaGradientView()
}
