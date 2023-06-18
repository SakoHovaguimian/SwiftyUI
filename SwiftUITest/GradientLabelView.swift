//
//  GradientLabelView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/16/23.
//

import SwiftUI

struct GradientLabelView: View {
    
    var text: String = "Sako Hovaguimian"
    
    var body: some View {
        
        VStack(
            alignment: .leading,
            spacing: 16) {
                
                GradientLabel(
                    text: self.text,
                    gradient: .init(colors: [.red, .green, .pink, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .font(.largeTitle)
                .fontWeight(.bold)
                
                GradientLabel(
                    text: self.text,
                    gradient: .init(colors: [.green, .pink]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .fontDesign(.rounded)
                .font(.largeTitle)
                .fontWeight(.bold)
                
                GradientLabel(
                    text: self.text,
                    gradient: .init(colors: [.blue, .indigo, .purple]),
                    startPoint: .center,
                    endPoint: .center
                )
                .fontDesign(.serif)
                .font(.largeTitle)
                .fontWeight(.bold)
                
                GradientLabel(
                    text: self.text,
                    gradient: .init(colors: [.cyan, .green, .mint, .cyan.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .fontDesign(.monospaced)
                .font(.largeTitle)
                .fontWeight(.bold)
                
            }
            .frame(maxHeight: 300)
            .padding(24)
        
        Spacer()
        
    }
    
}
