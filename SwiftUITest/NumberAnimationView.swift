//
//  NumberAnimationView.swift
//  Rival
//
//  Created by Sako Hovaguimian on 9/10/23.
//

import SwiftUI

struct NumberAnimationView: View {
    
    @State private var number: Float = 100
    
    var body: some View {
        
        AppBaseView {
                
            Text(self.number, format: .currency(code: "USD"))
                .appFont(with: .header(.h1))
                .foregroundStyle(AppColor.brandGreen)
                .contentTransition(.numericText())
            
        }
        .onTapGesture {
            
            withAnimation(.linear(duration: 0.3)) {
                self.number = Float.random(in: 0...1000)
            }
            
        }
        
    }
    
}

#Preview {
    NumberAnimationView()
}
