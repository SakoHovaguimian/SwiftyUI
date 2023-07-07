//
//  AdaptiveGridView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/6/23.
//

import SwiftUI

struct AdaptiveGridView: View {
    
    @State var width: CGFloat = 100
    @State var height: CGFloat = 120
    
    var insets: EdgeInsets = .init(
        top: 0,
        leading: 32,
        bottom: 0,
        trailing: 32
    )
    
    var interitemSpacing: CGFloat = 10
    
    let colors: [Color] = [
        .pink,
        .purple,
        .green,
        .blue,
        .orange,
        .red,
        .yellow,
        .gray,
        .black,
    ]
    
    var body: some View {
        
        ScrollView {
            
            LazyVGrid(
                
                columns: [
                    GridItem(.adaptive (minimum: self.width), spacing: self.interitemSpacing)
                ],
                spacing: self.interitemSpacing) {
                    
                    let totalCount = self.colors.count
                    
                    ForEach(0..<totalCount) { item in
                        
                        RoundedRectangle (cornerRadius: 10, style: .continuous)
                            .frame(height: self.height)
                            .foregroundColor (self.colors[item].opacity (0.6))
                        
                    }
                    
                }
                .padding(self.insets)
        }
        .onTapGesture {
            
            withAnimation(.bouncy) {
                
                let totalWidth = UIScreen.main.bounds.width - (self.insets.leading) - (self.insets.trailing)
             
                self.width = CGFloat.random(in: 50...totalWidth)
                self.height = CGFloat.random(in: 50...500)
                
            }
            
        }
        
    }
    
}

#Preview {
    AdaptiveGridView()
}
