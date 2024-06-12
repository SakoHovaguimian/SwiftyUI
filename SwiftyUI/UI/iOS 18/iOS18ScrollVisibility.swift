//
//  iOS18ScrollVisibility.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/11/24.
//

import SwiftUI

struct iOS18ScrollVisibility: View {
    
    @State private var colors: [Color] = [
        Color.darkRed,
        Color.darkBlue,
        Color.darkGreen,
        Color.darkPurple,
        Color.darkYellow,
        Color.lightRed,
        Color.lightBlue,
        Color.lightGreen,
        Color.lightPurple,
        Color.lightYellow
    ]
    
    var body: some View {
        
        ScrollView {
            
            LazyVStack(spacing: 0) {
                
                ForEach(self.colors, id: \.self) { color in
                    colorView(color)
                }
                
            }
            .scrollTargetLayout()
            
        }
        .scrollTargetBehavior(.paging)
        .ignoresSafeArea()
        
    }
    
    @ViewBuilder
    private func colorView(_ color: Color) -> some View {
        
        RoundedRectangle(cornerRadius: .appNone)
            .fill(color.gradient)
            .containerRelativeFrame(.vertical)
            .onScrollVisibilityChange(threshold: 1) { isVisible in
                
                if isVisible {
                    print("\(color.hashValue) Is Visibile")
                } else {
                    print("\(color.hashValue) Is Not Visibile")
                }
                
            }
        
    }
    
}

#Preview {
    iOS18ScrollVisibility()
}
