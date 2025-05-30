//
//  AttributedBuilder.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 4/9/25.
//

import SwiftUI

@resultBuilder
struct AttributedTextBuilder {
    
    static func buildBlock(_ components: Text...) -> Text {
        components.reduce(Text(""), { $0 + $1 })
    }
    
}

struct AttributedText: View {
    
    private let content: Text

    /// Initializes an `AttributedText` view using the provided builder closure.
    /// - Parameter content: A closure returning a composed `Text` using the `AttributedTextBuilder`.
    init(@AttributedTextBuilder content: () -> Text) {
        self.content = content()
    }
    
    var body: some View {
        content
    }
    
}

// Example usage:
struct AttributedTextViewTest: View {
    
    var body: some View {
        
        AttributedText {
            
            Text("This is a ")
            
            Text("SomeTest")
                .foregroundColor(.red)
                .fontWeight(.bold)
                .underline()
            
            Text(" embedded in custom text.")
            Text(" embedded in custom text.")
            Text(" embedded in custom text.")
            Text(" embedded in custom text.")
            Text(" embedded in custom text.")
            Text(" embedded in custom text.")
            Text(" embedded in custom text.")
            Text(" embedded in custom text.")
            
        }
        
    }
    
}

#Preview {
    
    AttributedTextViewTest()
    
}
