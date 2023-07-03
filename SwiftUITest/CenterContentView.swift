//
//  CenterContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/2/23.
//

import SwiftUI

struct CenterContentView: View {
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            Color.clear
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                
                Text("Some Text")
                    .background(Color.gray)
                
                Button(action: {}, label: {
                    Text("Button")
                })
                
            }.frame(
                width: UIScreen.main.bounds.width - 32,
                alignment: .leading
            )
            .background(Color.red)
            
        }
        
    }
}

#Preview {
    CenterContentView()
}
