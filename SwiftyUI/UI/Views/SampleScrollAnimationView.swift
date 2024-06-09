//
//  ContentView.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 3/31/24.
//

import SwiftUI

struct SampleScrollAnimationView: View {
    
    @State private var yOffset: CGFloat = 0
    @State private var selectedId: String? = nil
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Color.white.ignoresSafeArea()
            
            ScrollView(.vertical) {
                
                LazyVStack {
                    
                    Rectangle()
                        .fill(.green)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .background(Color.green)
                        .overlay {
                            Text("Home Page Title")
                        }
                        .asStretchyHeader(startingHeight: 200)
                    
                    
                    ForEach(0..<30) { x in
                        Text("")
                            .frame(maxWidth: .infinity)
                            .frame(height: 800)
                            .cornerRadius(10)
                            .background(Color.green)
                            .padding()
                            .id("\(x)")
                    }
                    
                }
                .scrollTargetLayout()
                .readingFrame { frame in
                    yOffset = frame.minY
                }
                
            }
            .overlay(Text("Offset: \(yOffset)"))
            .scrollPosition(id: $selectedId)
            .onChange(of: self.selectedId) { oldValue, newValue in
                print("WOAH MY NEW SLEECTED ID IS \(newValue ?? "NO VALUE")")
            }
            
            fakeHeaderView(shouldShow: yOffset < -160)
            
        }
        .ignoresSafeArea()
        
    }
    
    @ViewBuilder
    private func fakeHeaderView(shouldShow: Bool) -> some View {
        HStack(alignment: .center) {
            
            Circle()
                .fill(.white)
                .frame(width: 32, height: 32)
            
            Text("Home Page Title")
                .opacity(shouldShow ? 1 : 0)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Circle()
                .fill(.white)
                .frame(width: 32, height: 32)
                .offset(x: shouldShow ? 0 : 400)
            
        }
        .frame(height: 100)
        .padding(.top, 32)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(shouldShow ? .red : .black.opacity(0.001))
        .animation(.smooth, value: yOffset)
    }
    
}


#Preview {
    SampleScrollAnimationView()
}
