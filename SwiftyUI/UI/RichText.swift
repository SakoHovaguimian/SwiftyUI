//
//  RichText.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/10/24.
//

import SwiftUI

struct RichTextParserView: View {
    
    let inputText: String
    
    var body: some View {
        VStack {
            parsedText(from: inputText)
        }
    }
    
    @ViewBuilder
    func parsedText(from text: String) -> some View {
        // This function parses the input text and returns styled text
        let components = parseText(text)
        
        // Loop through parsed components and render them appropriately
        ForEach(components.indices, id: \.self) { index in
            let component = components[index]
            switch component {
            case .text(let value):
                Text(value)
                    .font(.body)
            case .name(let value, let color):
                Text(value)
                    .foregroundColor(color)
            case .bold(let value):
                Text(value)
                    .bold()
            }
            
        }
        
    }
    
    // Enum to define the parsed components
    enum TextComponent {
        
        case text(String)
        case name(String, Color)
        case bold(String)
        
    }
    
    // Function to parse the text and identify tags like [name: ...] and [bold: ...]
    func parseText(_ input: String) -> [TextComponent] {
        var components: [TextComponent] = []
        
        var remainingText = input
        
        // Regex patterns for [name: ...] and [bold: ...]
        let namePattern = "\\[name: \"(\\w+)\", color: \"(\\w+)\"\\]"
        let boldPattern = "\\[bold: \"(\\w+)\"\\]"
        
        // Process for finding all matches in sequence
        while let nameRange = remainingText.range(of: namePattern, options: .regularExpression),
              let boldRange = remainingText.range(of: boldPattern, options: .regularExpression) {
            
            if nameRange.lowerBound < boldRange.lowerBound {
                // Handle plain text before the name match
                if nameRange.lowerBound != remainingText.startIndex {
                    let prefix = String(remainingText[..<nameRange.lowerBound])
                    components.append(.text(prefix))
                }
                
                // Extract and process the name match
                let nameMatch = String(remainingText[nameRange])
                if let name = extractContent(from: nameMatch, type: .name),
                   let color = extractColor(from: nameMatch) {
                    components.append(.name(name, color))
                }
                
                // Trim the remaining text
                remainingText = String(remainingText[nameRange.upperBound...])
            } else {
                // Handle plain text before the bold match
                if boldRange.lowerBound != remainingText.startIndex {
                    let prefix = String(remainingText[..<boldRange.lowerBound])
                    components.append(.text(prefix))
                }
                
                // Extract and process the bold match
                let boldMatch = String(remainingText[boldRange])
                if let boldText = extractContent(from: boldMatch, type: .bold) {
                    components.append(.bold(boldText))
                }
                
                // Trim the remaining text
                remainingText = String(remainingText[boldRange.upperBound...])
            }
        }
        
        // Append any leftover text after parsing all matches
        if !remainingText.isEmpty {
            components.append(.text(remainingText))
        }
        
        return components
    }
    
    // Helper function to extract the content between the tag
    func extractContent(from match: String, type: TextComponent) -> String? {
        switch type {
        case .name:
            let regex = try! NSRegularExpression(pattern: "\\[name: \"(\\w+)\", color: \"\\w+\"\\]")
            let matchRange = NSRange(location: 0, length: match.utf16.count)
            if let result = regex.firstMatch(in: match, range: matchRange) {
                return String(match[Range(result.range(at: 1), in: match)!])
            }
        case .bold:
            let regex = try! NSRegularExpression(pattern: "\\[bold: \"(\\w+)\"\\]")
            let matchRange = NSRange(location: 0, length: match.utf16.count)
            if let result = regex.firstMatch(in: match, range: matchRange) {
                return String(match[Range(result.range(at: 1), in: match)!])
            }
        default:
            return nil
        }
        return nil
    }
    
    // Helper function to extract the color
    func extractColor(from match: String) -> Color? {
        let regex = try! NSRegularExpression(pattern: "\\[name: \"\\w+\", color: \"(\\w+)\"\\]")
        let matchRange = NSRange(location: 0, length: match.utf16.count)
        if let result = regex.firstMatch(in: match, range: matchRange) {
            let colorName = String(match[Range(result.range(at: 1), in: match)!])
            return Color(colorName)
        }
        return nil
    }
    
}

#Preview {
    
    RichTextParserView(
        inputText: """
        Hello [name: "93489084390", color: "blue"],
        Hope you're having a good [bold: "day"]
        """
    )
    
}

