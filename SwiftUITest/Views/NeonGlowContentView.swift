//
//  NeonGlowContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/29/23.
//

import SwiftUI

struct NeonGlowContentView: View {
    
    let greenColors = [
        Color(hex: "#FFF01F"),
        Color(hex: "#E7EE4F"),
        Color(hex: "#DFFF00")
    ]
    
    let blueColors = [
        Color(Color.RGBColorSpace.sRGB, red: 96/255, green: 252/255, blue: 255/255, opacity: 1),
        Color(Color.RGBColorSpace.sRGB, red: 44/255, green: 158/255, blue: 238/255, opacity: 1),
        Color(Color.RGBColorSpace.sRGB, red: 0/255, green: 129/255, blue: 255/255, opacity: 1)
    ]
    
    let redColors = [
        Color(hex: "#FF3131"),
        Color(hex: "#FF5E00"),
    ]
    
    let pinkColors = [
        Color(hex: "#EA00FF"),
        Color(hex: "#FF1493")
    ]

var body: some View {
    
    ZStack{
        
        Color.black
            .opacity(0.95)
            .ignoresSafeArea()
        
        VStack {
            
            Text("Following")
                .font(.largeTitle)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .addGlowEffect(
                    color1: blueColors[0],
                    color2: blueColors[1],
                    color3: blueColors[2]
                )
            
            Text("Following")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .fontDesign(.serif)
                .addGlowEffect(
                    color1: greenColors[0],
                    color2: greenColors[0],
                    color3: greenColors[0]
                )
            
            Text("Following")
                .font(.largeTitle)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .addGlowEffect(
                    color1: redColors[0],
                    color2: redColors[1],
                    color3: redColors[1]
                )
            
            Text("Following")
                .font(.largeTitle)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .addGlowEffect(
                    color1: pinkColors[0],
                    color2: pinkColors[1],
                    color3: pinkColors[1]
                )
          }
        
       }
    }
 }

#Preview {
    NeonGlowContentView()
}
