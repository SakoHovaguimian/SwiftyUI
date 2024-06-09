//
//  TypewriterView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/14/23.
//

import SwiftUI

public struct TypingText: View {
    
    @State private var typedText = ""
    @State private var timer: Timer?
    
    @State private var _text: String = ""
    private var text: String
    
    private var startTyping: Bool
    private var typingSpeed: ClosedRange<TimeInterval>
    private var typingDelay: TimeInterval
    
    public init(text: String,
                startTyping: Bool,
                typingSpeed: ClosedRange<TimeInterval> = 0.05...0.1,
                typingDelay: TimeInterval = 0) {
        
        self._text = text
        self.text = text
        
        self.startTyping = startTyping
        self.typingSpeed = typingSpeed
        self.typingDelay = typingDelay
        
    }
    
    var currentTextIndex: Int {
        return self.typedText.count
    }
    
    public var body: some View {
        
        ZStack {
            
            VStack {
                
                Text(self.typedText)
                    .font(Font.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .overlay {
                        LinearGradient(
                            colors: [.purple, .blue, .indigo],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            Text(self.typedText)
                                .font(Font.system(size: 24, weight: .bold))
                                .multilineTextAlignment(.center)
                        )
                    }
                
            }
            .padding(.horizontal, 32)
            .onChange(of: self.startTyping) { shouldType in

                if shouldType {
                    self.startTyping(self.currentTextIndex)
                } else {
                    self.stopTyping()
                }

            }
            .onChange(of: self.text) { text in
                
                self._text = text
                self.typedText = ""
                
                if self.startTyping {
                    
                    self.stopTyping()
                    self.startTyping(self.currentTextIndex)
                    
                } else {
                    self.stopTyping()
                }
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        
    }
    
    private func startTyping(_ index: Int) {
        
        self.timer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval.random(in: typingSpeed),
            repeats: false) { timer in
                
                guard index < self._text.count else {
                    return
                }
                
                self.typedText.append(
                    self._text[self._text.index(self._text.startIndex, offsetBy: index)]
                )
                
                startTyping(index + 1)
                
            }
        
    }
    
    private func stopTyping() {
        self.timer?.invalidate()
    }
    
}
