//
//  TikTokSideWaysContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/29/23.
//

import SwiftUI

struct TikTokSideWaysContentView: View {
    
    var body: some View {
        
        ScrollView(.horizontal) {
            
            HStack(spacing: 0) {
                
                ForEach(0..<10) { i in
                    
                    Text("Item \(i)")
                        .font(.largeTitle)
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
            
        }
        .ignoresSafeArea()
        .scrollTargetBehavior(.paging)
        
    }
    
}

#Preview {
    TikTokSideWaysContentView()
}
