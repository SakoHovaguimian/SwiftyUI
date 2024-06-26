//
//  Ext+String.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import Foundation
import CryptoKit
import UIKit

extension String {
    
    subscript(_ index: Int) -> Character? {
        
        guard index >= 0, index < self.count else {
            return nil
        }
        
        return self[self.index(self.startIndex, offsetBy: index)]
    }
    
}

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
    }.joined()
    
    return hashString
}

func randomNonceString(length: Int = 32) -> String {
    
    precondition(length > 0)
    let charset: Array<Character> =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}

extension String {
    
    var initials: String {
        return self.components(separatedBy: " ")
            .reduce("") {
                ($0.isEmpty ? "" : "\($0.first?.uppercased() ?? "")") +
                ($1.isEmpty ? "" : "\($1.first?.uppercased() ?? "")")
            }
    }
    
}

extension String {
    
    var firstName: String {
        return self.components(separatedBy: " ")
            .first ?? "DEBUG: [NO FIRST NAME]"
    }
    
}

extension UIPasteboard {
    
    static func pasteToClipboard(_ content: String) {
        self.general.string = content
    }
    
    static func readFromClipboard() -> String? {
        return self.general.string
    }
    
    // The code below can be used to pass values that are not plain-text
    /// `UIPasteboard.general.setValue(message, forPasteboardType: "public.plain-text")`
    
}
