//
//  MatchedGeoView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/22/23.
//

import SwiftUI

// Test this with selected view instead of shouldAnimate trigger

struct MatchedGeoView: View {
    
    @Namespace var animation
    @Namespace var textAnimation
    
    @State private var shouldAnimate = false
    @State private var selectedInt: Int?
    
    var body: some View {
        
        VStack {
            
            if let selectedInt {
                
                RoundedRectangle(cornerRadius: 12)
                    .matchedGeometryEffect(id: selectedInt, in: self.animation)
                    .frame(width: UIScreen.main.bounds.width, height: 400)
                    .foregroundStyle(selectedInt % 2 == 0 ? .green : .red)
                    .onTapGesture {
                        withAnimation(.bouncy(extraBounce: 0.03)) {
                            self.selectedInt = nil
                        }
                    }
                    .overlay(content: {
                        
                        VStack {
                            
                            Text("Woah")
                                .matchedGeometryEffect(id: "text", in: self.textAnimation)
                                .appFont(with: .header(.h5))
                            
                            Text("Some bio for the user")
                                .matchedGeometryEffect(id: "bio_text", in: self.textAnimation)
                                .appFont(with: .header(.h5))
                            
                        }
                        
                    })
                    .ignoresSafeArea()
                
                Spacer()
                
            } else {
                
                ZStack {
                    
                    Color.clear
                        .ignoresSafeArea()
                    
                    VStack {
                        
                        ForEach(0..<2) { i in
                            
                            RoundedRectangle(cornerRadius: 12)
                                .matchedGeometryEffect(id: i, in: self.animation)
                                .frame(width: 200, height: 200)
                                .foregroundStyle(i % 2 == 0 ? .green : .red)
                                .onTapGesture {
                                    withAnimation(.bouncy) {
                                        self.selectedInt = i
                                    }
                                }
                            
                        }
                        
                        Text("Woah")
                            .matchedGeometryEffect(id: "text", in: self.textAnimation)
                            .lineLimit(1, reservesSpace: true)
                            .appFont(with: .header(.h5))
                        
                        Text("Some bio for the user")
                            .matchedGeometryEffect(id: "bio_text", in: self.textAnimation)
                            .lineLimit(1, reservesSpace: true)
                            .appFont(with: .header(.h5))
                        
                    }
    
                    
                }
                
            }
            
        }
        .onTapGesture {
           withAnimation(.spring()) {
               shouldAnimate.toggle()
           }
        }
    }
}


#Preview {
    MatchedGeoView()
}
