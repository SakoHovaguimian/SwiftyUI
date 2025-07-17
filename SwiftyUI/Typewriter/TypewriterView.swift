//
//  TypewriterView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/14/23.
//

import SwiftUI

public struct TypingText: View {
    
    public let text: String
    public let startTyping: Bool
    public let typingSpeed: ClosedRange<TimeInterval>
    public let typingPreDelay: TimeInterval
    
    @State private var typedText: String = ""
    @State private var typingTask: Task<Void, Never>? = nil
    
    public init(text: String,
                startTyping: Bool,
                typingSpeed: ClosedRange<TimeInterval> = 0.05...0.1,
                typingPreDelay: TimeInterval = 0) {
        
        self.text = text
        self.startTyping = startTyping
        self.typingSpeed = typingSpeed
        self.typingPreDelay = typingPreDelay
        
    }
    
    public var body: some View {
        
        Text(self.typedText)
            .onChange(of: self.startTyping) { _, shouldStart in
                onChangeStartTyping(shouldStart: shouldStart)
            }
            .onChange(of: text) { _, newText in
                                
                if self.startTyping {
                    beginTyping()
                }
                
            }
            .onAppear {
                
                if self.startTyping {
                    beginTyping()
                }
                
            }
            .onDisappear {
                cancelTyping()
            }
        
    }
    
    private func onChangeStartTyping(shouldStart: Bool) {
        
        if shouldStart {
            beginTyping()
        } else {
            cancelTyping()
        }
        
    }
    
    private func beginTyping() {
                
        // Invlaidate
        
        self.typedText = ""
        self.typingTask?.cancel()
        
        // Being
        
        self.typingTask = Task {
            
            // Initial delay
            if self.typingPreDelay > 0 {
                try? await Task.sleep(for: .seconds(self.typingPreDelay))
            }
            
            for character in self.text {
                
                guard !Task.isCancelled else { return }
                self.typedText.append(character)
                
                let interval = TimeInterval.random(in: self.typingSpeed)
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                
            }
            
        }
        
    }
    
    private func cancelTyping() {
        
        self.typingTask?.cancel()
        self.typingTask = nil
        
    }
    
}
