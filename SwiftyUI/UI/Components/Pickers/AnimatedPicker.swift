//
//  AnimatedPicker.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/29/24.
//

import SwiftUI

struct AnimatedPicker: View {
    
    enum Category: String, CaseIterable {
        
        case music
        case sports
        case anime
        case home
        
    }
    
    @State private var selectedCategory: Category?
    @Namespace private var namespace
    
    var body: some View {
        
        ZStack {
            
            Color(.systemGray4)
                .ignoresSafeArea()
            
            ScrollView(.horizontal) {
                
                HStack(spacing: 12) {
                    
                    ForEach(Category.allCases, id: \.rawValue) { category in
                        
                        Button(action: {
                            
                            withAnimation(.smooth) {
                                self.selectedCategory = category
                            }
                            
                        }, label: {
                            
                            Text(category.rawValue.capitalized)
                                .font(.callout)
                                .foregroundStyle(self.selectedCategory == category ? .white : .black)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background {
                                    
                                    if self.selectedCategory == category {
                                        
                                        Capsule()
                                            .fill(.black)
                                            .matchedGeometryEffect(id: "ACTIVE_TAB", in: self.namespace)
                                        
                                    }
                                    else {
                                        
                                        Capsule()
                                            .fill(.white)
                                        
                                    }
                                    
                                }
                            
                        })
                        
                    }
                    
                }
                
            }
            .frame(maxWidth: .infinity)
            .safeAreaPadding(.horizontal, 24)
            
        }
        
    }
    
}

#Preview {
    AnimatedPicker()
}
