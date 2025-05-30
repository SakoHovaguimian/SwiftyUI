//
//  AttributedStringBuilder.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 5/27/25.
//

import SwiftUI

@resultBuilder
public struct AttributedStringBuilder {
    
    public static func build(@AttributedStringBuilder _ content: () -> AttributedString) -> AttributedString {
        content()
    }
    
    /// Combine pieces into a single `AttributedString`.
    public static func buildBlock(_ components: AttributedString...) -> AttributedString {
        
        components.reduce(AttributedString()) { acc, next in
            
            var copy = acc
            copy.append(next)
            
            return copy
            
        }
        
    }

    /// Wrap a plain Swift String in an `AttributedString`.
    public static func buildExpression(_ expression: String) -> AttributedString {
        AttributedString(expression)
    }

    /// Pass through an existing `AttributedString`.
    public static func buildExpression(_ expression: AttributedString) -> AttributedString {
        expression
    }

    /// Parse a markdown fragment into `AttributedString`.
    public static func buildExpression(_ expression: Markdown) -> AttributedString {
        
        // Force-try for brevity; you may handle errors as needed.
        try! AttributedString(markdown: expression.content)
        
    }

    /// Support optional segments (e.g., `if` without `else`).
    public static func buildOptional(_ component: AttributedString?) -> AttributedString {
        component ?? AttributedString()
    }

    /// Support `if-else` branching.
    public static func buildEither(first component: AttributedString) -> AttributedString {
        component
    }
    public static func buildEither(second component: AttributedString) -> AttributedString {
        component
    }

    /// Flatten arrays of components.
    public static func buildArray(_ components: [AttributedString]) -> AttributedString {
        components.reduce(AttributedString()) { acc, next in var copy = acc; copy.append(next); return copy }
    }
    
}

public struct Markdown {
    
    fileprivate let content: String
    public init(_ content: String) { self.content = content }
    
}

public extension String {
    
    var md: Markdown { Markdown(self) }

    func withAttributes(_ configure: (inout AttributeContainer) -> Void) -> AttributedString {
        
        var container = AttributeContainer()
        configure(&container)
        
        var attributed = AttributedString(self)
        attributed.mergeAttributes(container, mergePolicy: .keepCurrent)
        
        return attributed
        
    }

    func font(_ font: UIFont) -> AttributedString {
        withAttributes { $0.font = font }
    }
    
    func foregroundColor(_ color: UIColor) -> AttributedString {
        withAttributes { $0.foregroundColor = color }
    }
    
    func link(_ url: URL) -> AttributedString {
        withAttributes { $0.link = url }
    }
    
}

struct AttributedStringBuilder_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let demo = AttributedStringBuilder.build {
            
            "Hello, "
                .font(.systemFont(ofSize: 24, weight: .regular))
            "World".withAttributes { $0.foregroundColor = .systemBlue }
            "! Check out ".md
            "Apple".link(URL(string: "https://apple.com")!)
            " docs.".md
            
            // Conditional segment
            if true {
                "\n**Bold markdown**".md
            }
            
        }
        
        return ScrollView {
            
            Text(demo)
                .font(.largeTitle)
                .padding()
            
        }
        .previewLayout(.sizeThatFits)
        .environment(\.openURL, .init(handler: { url in
            
            print(url)
            return .handled
            
        }))
        
    }
    
}
