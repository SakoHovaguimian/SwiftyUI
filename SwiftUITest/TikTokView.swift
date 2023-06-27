//
//  TikTokView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/26/23.
//

import SwiftUI

struct TikTokView: View {
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 0) {
                
                ForEach(0..<50) { i in
                    
                    Text("Item \(i)")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height)
                        .background(i % 2 == 0 ? Color.blue.gradient : Color.green.gradient)
                        .foregroundStyle(.white)
                    
                }
                
            }
        }
        .ignoresSafeArea()
        .scrollTargetBehavior(.paging)
        
    }
}

#Preview {
    TikTokView()
}
