//
//  iOSBlendColors.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/14/24.
//

import SwiftUI

struct iOSBlendColors: View {
    
    var body: some View {
        
        AppBaseView(alignment: .top) {
            
            VStack(alignment: .leading, spacing: 32) {
                
                textView("Starting Colors")
                
                HStack {
                    
                    Circle()
                        .fill(.brandGreen)
                        .frame(width: 120)
                    
                    Spacer()
                    
                    Circle()
                        .fill(.brandPink)
                        .frame(width: 120)
                    
                }
                
                textView("Blended Colors")
                
                blendedRowItem(
                    title: "Green + Pink (0.2)",
                    color: .brandGreen.mix(with: .brandPink, by: 0.2)
                )
                
                blendedRowItem(
                    title: "Green + Pink (0.5)",
                    color: .brandGreen.mix(with: .brandPink, by: 0.5)
                )
                
                blendedRowItem(
                    title: "Green + Pink (0.8)",
                    color: .brandGreen.mix(with: .brandPink, by: 0.8)
                )
                
                blendedRowItem(
                    title: "Green + Pink (1)",
                    color: .brandGreen.mix(with: .brandPink, by: 1)
                )
                
                
            }
            .padding(.horizontal, .large)
            
        }
        
    }
    
    private func textView(_ text: String) -> some View {
        
        Text(text)
            .font(.title3)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
        
    }
    
    private func blendedRowItem(title: String, color: Color) -> some View {
        
        HStack {
            
            textView(title)
            
            Spacer()
            
            Circle()
                .fill(color)
                .frame(width: 120)
            
        }
        
    }
    
}

#Preview {
    iOSBlendColors()
}
