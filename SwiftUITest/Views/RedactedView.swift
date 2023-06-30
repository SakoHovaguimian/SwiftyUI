//
//  RedactedView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/16/23.
//

import SwiftUI

struct RedactedView: View {
    
    @EnvironmentObject var navSettings: NavSettings
    
    var body: some View {
        
        ZStack {
            
//            Color(hex: "f5f5f4")
            Color.white
            
            VStack(spacing: 16) {
                
                Text("Some text")
                    .padding(16)
                    .font(.largeTitle)
                    .colorScheme(.light)
                    .frame(width: 200, height: 100)
                    .redacted(reason: .placeholder)
                    .shimmering()
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .colorScheme(.light)
                    .frame(width: 50, height: 50)
                    .redacted(reason: .placeholder)
                    .shimmering()
//                    .redacted(if: true, style: .appear)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    //                        isRedacted = false
                        }
                    }
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .colorScheme(.light)
                    .frame(width: 50, height: 50)
                    .redacted(reason: .placeholder)
    //                .redacted(if: true, style: .never)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    //                        isRedacted = false
                        }
                    }
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .colorScheme(.light)
                    .frame(width: 50, height: 50)
                    .redacted(reason: .placeholder)
    //                .redacted(if: true, style: .opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    //                        isRedacted = false
                        }
                    }
                
                Group {
                    
                    VStack(alignment: .leading) {
                        Text("Loading...").font(.title)
                        Text(String(repeating: "Shimmer", count: 12))
                            .redacted(reason: .placeholder)
                    }.frame(maxWidth: 200)
                    
                }
                .colorScheme(.light)
                .padding()
                .shimmering()
                
            }
            
            Spacer()
            
        }
        .navigationTitle("Shimmer View")
        .navigationBarTitleDisplayMode(.large)
        .ignoresSafeArea()
        .tint(Color.pink)
        .onAppear {
            self.navSettings.currentTintColor = .black
        }
        .onDisappear {
            self.navSettings.setTintToOriginalColor()
        }
        
    }
    
}
