//
//  Strings.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 4/9/25.
//

import Foundation

struct StringSource {
    
    // MARK: - Transform using StyleConverter
    
    /// Transforms the input string from one naming style to another.
    /// - Parameters:
    ///   - input: The original string.
    ///   - from: The style the input string is currently in.
    ///   - to: The style to convert the input string to.
    /// - Returns: The transformed string.
    static func transform(_ input: String, from sourceStyle: StyleConverter, to targetStyle: StyleConverter) -> String {
        return StyleConverter.convert(input, from: sourceStyle, to: targetStyle)
    }
    
    // MARK: - Pluralization
    
    /// Returns the plural version of a string using simple English rules.
    ///
    /// **Note:** This is a very simplified approach. For irregular words or more complex rules, consider integrating
    /// a library or maintaining a lookup dictionary.
    ///
    /// - Parameter input: The singular form of the string.
    /// - Returns: The pluralized form.
    static func pluralize(_ input: String) -> String {
        // If the word ends in "y" and the preceding character is not a vowel, replace the "y" with "ies"
        if input.count > 1, let last = input.last, last == "y",
           let secondLast = input.dropLast().last, !"aeiou".contains(secondLast.lowercased()) {
            return String(input.dropLast()) + "ies"
        }
        // If the word ends in "s", "x", "sh", or "ch", add "es"
        else if input.hasSuffix("s") ||
                    input.hasSuffix("x") ||
                    input.hasSuffix("sh") ||
                    input.hasSuffix("ch") {
            return input + "es"
        }
        // Otherwise, just add "s"
        else {
            return input + "s"
        }
    }
    
    // MARK: - Localization
    
    /// Retrieves a localized string from a specified strings file.
    ///
    /// - Parameters:
    ///   - file: The name of the localizable strings file (without the `.strings` extension).
    ///   - key: The key of the string within the specified file.
    ///   - bundle: The bundle containing the localized file (default is `.main`).
    ///   - comment: An optional comment to provide context for translators.
    /// - Returns: The localized string.
    static func localized(fromFile file: String, key: String, bundle: Bundle = .main, comment: String = "") -> String {
        return NSLocalizedString(key, tableName: file, bundle: bundle, value: "", comment: comment)
    }
    
}

extension String {
    
    /// Converts the string into a specified naming style.
    ///
    /// This version assumes a default source style (in this example, `.snakeCase`).
    /// - Parameter targetStyle: The naming style to convert the string to.
    /// - Returns: The string transformed into the target naming style.
    func convertNamingStyle(to targetStyle: StyleConverter) -> String {
        return self.convertNamingStyle(from: .sentenceCase, to: targetStyle)
    }
    
}
