//
//  StyleConverter.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 4/9/25.
//

enum StyleConverter: String, CaseIterable {
    
    case snakeCase = "snake_case"
    case camelCase = "camelCase"
    case pascalCase = "PascalCase"
    case kebabCase = "kebab-case"
    case screamingSnakeCase = "SCREAMING_SNAKE_CASE"
    case sentenceCase = "Sentence case"
    
    public static func convert(_ input: String,
                                    from sourceStyle: StyleConverter,
                                    to targetStyle: StyleConverter) -> String {
        
        // First, convert the input to a common format (words array)
        let words = sourceStyle.toWords(input)
        
        // Then, convert from the common format to the target style
        return targetStyle.fromWords(words)
        
    }
    
    private func toWords(_ input: String) -> [String] {
        
        switch self {
        case .snakeCase, .screamingSnakeCase:
            
            return input.lowercased().split(separator: "_").map(String.init)
            
        case .camelCase, .pascalCase:
            
            return input.replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
                .split(separator: " ")
                .map(String.init)
            
        case .kebabCase:
            
            return input.split(separator: "-").map(String.init)
            
        case .sentenceCase:
            
            return input.lowercased().split(separator: " ").map(String.init)
            
        }
        
    }
    
    private func fromWords(_ words: [String]) -> String {
        
        switch self {
        case .snakeCase:
            
            return words.joined(separator: "_")
            
        case .camelCase:
            
            return words.enumerated().map { $0 == 0 ? $1 : $1.capitalized }.joined()
            
        case .pascalCase:
            
            return words.map { $0.capitalized }.joined()
            
        case .kebabCase:
            
            return words.joined(separator: "-")
            
        case .screamingSnakeCase:
            
            return words.joined(separator: "_").uppercased()
            
        case .sentenceCase:
            
            return words.enumerated().map { $0 == 0 ? $1.capitalized : $1 }.joined(separator: " ")
            
        }
        
    }
    
}

extension String {
    
    func convertNamingStyle(from currentStyle: StyleConverter, to targetStyle: StyleConverter) -> String {
        
        return StyleConverter.convert(
            self, from: currentStyle,
            to: targetStyle
        )
        
    }
    
}
