//
//  TypewriterContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/15/23.
//

import SwiftUI

struct TypewriterContentView: View {
    
    var storyPaths = [
        
        "Please come down to the greatest place on earth, Please come down to the greatest place on earth. Please come down to the greatest place on earth, Please come down to the greatest place on earth",
        "What's up?",
        "JOhn, come back?",
        "In the end nothing mattered..."
        
    ]
    
    @State private var currentStoryIndex: Int = 0
    @State private var currentStoryText: String = ""
    @State private var startTyping = false
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(
                colors: [
                    .mint.opacity(0.6),
                    .mint.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                
                ScrollView(.vertical) {
                    
                    Button("Start typing") {
                        self.startTyping.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Next path") {
                        
                        self.currentStoryIndex += 1
                        self.currentStoryText = self.storyPaths[self.currentStoryIndex]
                        
                    }
                    .buttonStyle(.borderedProminent)
                    
                    TypingText(
                        text: currentStoryText,
                        startTyping: self.startTyping
                    )
                    
                }
                .onAppear {
                    self.currentStoryText = self.storyPaths[self.currentStoryIndex]
                }
                
            }
            
        }
        
    }
    
}

#Preview {
    TypewriterContentView()
}
