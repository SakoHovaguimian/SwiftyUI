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

extension Color {
    
    init(hex: String) {
        
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
}
