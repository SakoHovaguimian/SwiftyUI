//
//  ArcMenuButtonView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/8/23.
//

import SwiftUI

struct ArcMenuButtonView: View {
    
    var body: some View {
        
        VStack {
            
            ArcMenuButton(buttons: ["circle", "star", "bell", "bookmark"])
                .padding(.bottom, 20)
                .padding(.trailing, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            
        }
    }
}

#Preview {
    ArcMenuButtonView()
}

// ArcMenuButton

// Add Action param that passed index to parent view
// Create style to make it vertical or radial

struct ArcMenuButton: View {
    
    @State var isExpanded = false
    
    let buttons: [String]
    
    var body: some View {
        
        ZStack {
            
            ForEach(self.buttons.indices, id: \.self) { index in
                
                Image(systemName: buttons [index])
                    .frame (width: 10, height: 10)
                    .padding()
                    .background (Color (.systemGray6))
                    .foregroundColor (.gray)
                    .cornerRadius (20)
                    .offset(x: offsetX(index: index),
                            y: offsetY(index: index))
                
                    .animation(
                        .spring(response: 0.5,
                                dampingFraction: 0.5,
                                blendDuration: 0)
                        .delay (Double (index) * 0.15),
                        value: self.isExpanded
                    )
            }
            
            Button {
                withAnimation {
                    self.isExpanded.toggle()
                }
            } label: {
                Image (systemName: self.isExpanded ? "xmark" : "plus")
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)
                    .padding(15)
                    .background (Color(.systemGray6))
                    .cornerRadius (25)
                
            }
            
        }
        
    }
    
    private func offsetX(index: Int) -> CGFloat {
        return self.isExpanded ? CGFloat(cos((Double(index) * 45 + 135) * Double.pi / 180) * 60): 0
    }
    
    private func offsetY(index: Int) -> CGFloat {
        return self.isExpanded ? CGFloat(sin((Double(index) * 45 + 135) * Double.pi / 180) * 60): 0
    }
    
}
