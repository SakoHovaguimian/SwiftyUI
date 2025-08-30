//
//  NewToggleTest.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/7/25.
//

import SwiftUI

struct NewToggleTest: View {
    
    @State var selectedIndex = 0
    @Namespace var animation
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            VStack {
                
                Label("Hatch", systemImage: "lightbulb")
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        withAnimation(.smooth) {
                            selectedIndex = 0
                        }
                    }
                    .foregroundStyle(selectedIndex == 0 ? .white : .gray)
                    .padding(.vertical, 16)
                    .background {
                        
                        Capsule()
                            .fill(Color.clear)
                        
                        if self.selectedIndex == 0 {
                            
                            Capsule()
                                .fill(Color.green)
                                .matchedGeometryEffect(id: "Tab", in: self.animation)
                            
                        }
                        
                    }
                
            }
            
            VStack {
                
                Label("Phone", systemImage: "iphone")
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        withAnimation(.smooth) {
                            selectedIndex = 1
                        }
                    }
                    .foregroundStyle(selectedIndex == 1 ? .white : .gray)
                    .padding(.vertical, 16)
                    .background {
                        
                        Capsule()
                            .fill(Color.clear)
                        
                        if self.selectedIndex == 1 {
                            
                            Capsule()
                                .fill(Color.green)
                                .matchedGeometryEffect(id: "Tab", in: self.animation)
                            
                        }
                        
                    }
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(.gray.opacity(0.3))
        .clipShape(.capsule)
        .padding(.horizontal, 32)
        
    }
    
}

#Preview {
    NewToggleTest()
}
