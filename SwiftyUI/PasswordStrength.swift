//
//  PasswordStrength.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/3/25.
//

import SwiftUI

struct PasswordStrength: View {
    
    enum Strength: Int {
        
        case weak
        case medium
        case strong
        
        var displayName: String {
            switch self {
            case .weak: return "Weak"
            case .medium: return "Medium"
            case .strong: return "Strong"
            }
        }
        
        var color: Color {
            switch self {
            case .weak:  return .red
            case .medium: return .yellow
            case .strong: return .green
            }
        }
        
    }
    
    @State var passwordText: String = ""
    @State var passwordStrength: Strength?
    
    var body: some View {
        
        VStack {
            
            TextField("Password", text: self.$passwordText)
                .textFieldStyle(.roundedBorder)
            
            passwordStrengthContainer()
            
            Text("Your Password is: \(self.passwordStrength?.displayName ?? "Invalid")")
            
        }
        .onChange(of: passwordText) { oldValue, newValue in
            checkPasswordStrength()
        }
        .padding(.horizontal, .large)
        
    }
    
    func passwordStrengthContainer() -> some View {
        
        let currentStrengthInt: Int = self.passwordStrength?.rawValue ?? -1
        let currentStrengthColor: Color = self.passwordStrength?.color ?? .pink
        
        return HStack(spacing: 8) {
            
            passwordStrengthProgressBar(
                color: currentStrengthColor,
                isFilled: currentStrengthInt >= 0
            )
            
            passwordStrengthProgressBar(
                color: currentStrengthColor,
                isFilled: currentStrengthInt >= 1
            )
            
            passwordStrengthProgressBar(
                color: currentStrengthColor,
                isFilled: currentStrengthInt >= 2
            )
            
        }
        
    }
    
    func passwordStrengthProgressBar(color: Color, isFilled: Bool) -> some View {
        
        ZStack {
            
            Capsule()
                .fill(.gray.opacity(0.15))
            
            if isFilled {
                
                Capsule()
                    .fill(color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                
            }
            
        }
        .frame(height: 8, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(.capsule)
        .animation(.easeInOut, value: isFilled)
        
    }
    
    func checkPasswordStrength() {
        
        guard !self.passwordText.isEmpty else {
            
            self.passwordStrength = nil
            return
            
        }
        
        let minimumLength: Bool = passwordText.count > 4
        let hasUpperCase: Bool = self.passwordText.contains(where: { $0.isUppercase })
        let hasLowerCase: Bool = self.passwordText.contains(where: { $0.isLowercase })
        let hasDigit: Bool = self.passwordText.contains(where: { $0.isNumber })
        
        print("HAS MINIMUM LENGTH: \(minimumLength)")
        print("HAS UPPER CASE: \(hasUpperCase)")
        print("HAS LOWER CASE: \(hasLowerCase)")
        print("HAS DIGIT: \(hasDigit)")
        
        let allBools: [Bool] = [minimumLength, hasUpperCase, hasLowerCase, hasDigit]
        let numberOfTrueBools: Int = allBools.filter { $0 }.count
        
        switch numberOfTrueBools {
        case 0..<2:
            print("enters here")
            self.passwordStrength = .weak
        case 2..<4:
            self.passwordStrength = .medium
        case 4..<100:
            self.passwordStrength = .strong
        default: self.passwordStrength = nil
        }
        
    }
    
}

#Preview {
    PasswordStrength()
}
