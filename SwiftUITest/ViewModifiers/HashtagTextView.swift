//
//  HashtagTextView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/25/23.
//

import SwiftUI

struct HashtagText: View {
    
    private var text: String
    private var font: UIFont
    private var color: Color
    private var textAlignment: TextAlignment
    
    init(text: String,
         font: UIFont = .systemFont(ofSize: 25, weight: .semibold),
         textAlignment: TextAlignment = .leading,
         color: Color) {
        
        self.text = text
        self.font = font
        self.textAlignment = textAlignment
        self.color = color
        
    }
    
    var body: some View {
        
        textWithHashtags()
        .font(Font(self.font as CTFont))
        .bold()
        .multilineTextAlignment(self.textAlignment)

        
    }
    
    private func textWithHashtags() -> Text {
        
        let words = self.text.split(separator: " ")
        var output: Text = Text("")

        for word in words {
            
            if word.hasPrefix("#") { // Pick out hash in words
                output = output + Text(" ") + Text(String(word))
                    .foregroundStyle(self.color) // Add custom styling here
            } else {
                
                if word == words.first! {
                    output = Text(String(word))
                }
                else {
                    output = output + Text(" ") + Text(String(word))
                }
                
            }
            
        }
        
        return output
        
    }
    
}

#Preview {
    
    HashtagText(
        text: "Go my fellow #Airbuds and follow me into the #Dark",
        color: .cyan.opacity(1)
    )
    .padding(.horizontal, 32)
    
}
