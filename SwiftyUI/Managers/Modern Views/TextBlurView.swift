//
//  TextBlurView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 10/10/24.
//

import SwiftUI

// TODO: -
/// Change 0.15 to be a settable property
/// Rename starttime to delay
/// Remove comments

struct TextBlurView: View {
    
    let characters: Array<String.Element> // Array of characters from the input text.
    
    let baseTime: Double // The time after which the animation should start.
    
    let textSize: Double // The font size for the text.
    
    @State var blurValue: Double = 0 // State variable to control the blur radius.
    @State var opacity: Double = 0 // State variable to control the opacity.
    
    init(text: String, textSize: Double, startTime: Double) {
        
        characters = Array(text) // Convert the text into an array of individual characters.
        self.textSize = textSize // Set the text size.
        baseTime = startTime // Set the base time for the animation to start.
        
    }
    
    var body: some View {
        
        HStack(spacing: 1) {
            
            ForEach(0..<characters.count) { num in
                
                Text(String(self.characters[num])) // Convert each character back into a string.
                    .font(.system(size: textSize))
                    .fontDesign(.serif)
                    .blur(radius: blurValue) // Apply the blur effect.
                    .opacity(opacity) // Set the opacity.
                    .animation(.easeInOut.delay( Double(num) * 0.15 ), value: blurValue) // Apply an animation with easing in/out effect and a delay for each character.
                
            }
            
        }
        .onTapGesture {
            
            if blurValue == 0 {
                
                blurValue = 10 // If it's not blurred, set blur value to 10.
                opacity = 0.01 // Set opacity to almost transparent.
                
            } else {
                
                blurValue = 0 // Remove blur.
                opacity = 1 // Make the text fully visible.
                
            }
            
        }
        .onAppear {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + baseTime) {
                
                if blurValue == 0 {
                    
                    blurValue = 10 // If no blur, add blur and reduce opacity.
                    opacity = 0.01
                    
                } else {
                    
                    blurValue = 0 // Remove blur and increase opacity.
                    opacity = 1
                    
                }
                
            }
            
        }
        
    }
    
}

struct TextBlurViewPreviewView: View {
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Blur Text Animation")
                .fontWeight(.heavy)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            VStack(alignment: .leading) {
                
                TextBlurView(text: "Text Animation", textSize: 38, startTime: 0.41)
                TextBlurView(text: "Made By", textSize: 38, startTime: 1.85)
                TextBlurView(text: "@SwiftUICodes", textSize: 38, startTime: 2.76)
                TextBlurView(text: "Subscribe on Youtube", textSize: 16, startTime: 3.76)
                    .padding(.top, 30) // Adds padding to the top for the last line.
                
            }
            
        }
        
    }
    
}

#Preview {
    TextBlurViewPreviewView()
}
