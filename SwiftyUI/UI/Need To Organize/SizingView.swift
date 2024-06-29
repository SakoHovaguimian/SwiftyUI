//
//  SizingView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/28/24.
//

import SwiftUI

struct SizingView: View {
    
    var body: some View {
        VStack(spacing: 64) {
            
            Text("SOME SPACING MESSAGE")
            
            GeometryReader { geometry in
                VStack {
                    Text("Hello, World!")
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .frame(maxWidth: geometry.size.width * 0.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.red)
                .fixedSize(horizontal: false, vertical: true)
            }
            
        }
    }
}

#Preview {
    SizingView()
}
