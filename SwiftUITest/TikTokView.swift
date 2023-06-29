//
//  TikTokView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/26/23.
//

import SwiftUI

struct TikTokView: View {
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 0) {
                
                ForEach(0..<50) { i in
                    
                    if i % 2 == 0 {
                     
                        Text("Item \(i)")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity)
                            .frame(height: UIScreen.main.bounds.height)
                            .background {
                                
                                Image(i % 2 == 0 ? "sunset" : "pond")
                                    .resizable()
                                    .scaledToFill()
                                
                            }
                            .foregroundStyle(.white)
                        
                    }
                    else {
                        NestedHorizontalTikTokView()
                    }
                    
                }
                
            }
        }
        .ignoresSafeArea()
        .scrollTargetBehavior(.paging)
        
    }
    
}

// Test Only
struct NestedHorizontalTikTokView: View {
    
    var body: some View {
        
        ScrollView(.horizontal) {
            
//            ZStack {
                
                HStack(spacing: 0) {
                    
                    ForEach(0..<10) { i in
                        
                        Text("Item \(i)")
                            .font(.largeTitle)
//                            .frame(maxWidth: .infinity)
//                            .frame(
//                                height: UIScreen.main.bounds.height
//                            )
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            .background {
                                
                                Image(i % 2 == 0 ? "sunset" : "pond")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                
                            }
                            .overlay(content: {
                                
                                VStack {
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrowshape.right.fill")
                                        .resizable()
                                        .frame(
                                            width: 64,
                                            height: 64
                                        )
                                        .foregroundStyle(.red)
                                        .padding(.top, 128)
                                    
                                    Spacer()
                                    
                                }
                                
                            })
                            .clipped()
                            .foregroundStyle(.white)
                        
                    }
                    
                }
                
//            }
            
        }
        .ignoresSafeArea()
        .scrollTargetBehavior(.paging)
        
    }
    
}

#Preview {
    TikTokView()
}
