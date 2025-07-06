//
//  ContentView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/5/25.
//


import SwiftUI

struct PageHeaderPreviewTest: View {
    
    let headers: [PageHeader] = [
        .init(title: "Posts", icon: "square.grid.3x3.fill", selectedColor: .mint, unselectedColor: .gray),
        .init(title: "Reels", icon: "photo.stack.fill", selectedColor: .mint, unselectedColor: .gray),
        .init(title: "Tagged", icon: "person.crop.rectangle", selectedColor: .mint, unselectedColor: .gray)
    ]
    
    var body: some View {
        
        HeaderPageScrollView(pageHeaders: headers) {
                
            ColorView(.red, count: 50)
            ColorView(.yellow, count: 10)
            ColorView(.indigo, count: 5)
            
        }
        
    }
    
    @ViewBuilder
    private func ColorView(_ color: Color, count: Int) -> some View {
        
        LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
            
            ForEach(0..<count, id: \.self) { index in
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.gradient)
                    .frame(height: 160)
                
            }
            
        }
        .padding(15)
        
    }
    
}

#Preview {
    PageHeaderPreviewTest()
}
