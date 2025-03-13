//
//  CustomAnimationTest.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/12/25.
//

import SwiftUI

struct CustomAnimationTest: View {
    
    @State private var isAnimating: Bool = false
    
    let defaultAnimation = Animation
        .linear(duration: 1.5)
        .delay(0.25)
        .repeatForever(autoreverses: true)
    
    var body: some View {
        
        RoundedRectangle(cornerRadius: 16)
            .fill(.darkBlue)
            .frame(
                width: 200,
                height: 200
            )
            .overlay(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: self.isAnimating ? [.cyan, .blue] : [.indigo, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(maxWidth: self.isAnimating ? .infinity : 0)
                    .opacity(self.isAnimating ? 1 : 1)
                
            }
            .mask({
                
                Image(systemName: "person.3.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
            })
            .animation(
                self.defaultAnimation,
                value: self.isAnimating
            )
            .onAppear {
                self.isAnimating = true
            }
        
    }
    
}

#Preview {
    
    CustomAnimationTest()
    
}
