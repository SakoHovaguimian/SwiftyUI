import SwiftUI

struct ValidationView: View {
    
    enum PasswordRule: Hashable, Equatable, CaseIterable, Identifiable {
        
        case length(Int)
        case containsUppercase
        case containsLowercase
        case containsNumber
        case containsSpecialCharacter
        
        // **********************************
        // MARK: - CaseIterable
        // **********************************
        
        static var allCases: [PasswordRule] {
            [
                .length(8),
                .containsUppercase,
                .containsLowercase,
                .containsNumber,
                .containsSpecialCharacter
            ]
        }
        
        // **********************************
        // MARK: - Identifiable
        // **********************************
        
        var id: String { self.displayName }
        
        // **********************************
        // MARK: - UI
        // **********************************
        
        var displayName: String {
            switch self {
            case .length(let value): return "At least \(value) characters"
            case .containsUppercase: return "Contains uppercase letter"
            case .containsLowercase: return "Contains lowercase letter"
            case .containsNumber: return "Contains number"
            case .containsSpecialCharacter: return "Contains special character"
            }
        }
        
        // **********************************
        // MARK: - Validation
        // **********************************
        
        func isValid(_ password: String) -> Bool {
            
            switch self {
            case .length(let value):
                return password.count >= value
                
            case .containsUppercase:
                return password.rangeOfCharacter(from: .uppercaseLetters) != nil
                
            case .containsLowercase:
                return password.rangeOfCharacter(from: .lowercaseLetters) != nil
                
            case .containsNumber:
                return password.rangeOfCharacter(from: .decimalDigits) != nil
                
            case .containsSpecialCharacter:
                let special = CharacterSet.alphanumerics.inverted
                return password.rangeOfCharacter(from: special) != nil
            }
            
        }
        
    }
    
    @State var password = "Pokemon"
    
    var body: some View {
        
        AppBaseView {
            
            VStack(alignment: .leading,
                   spacing: 8) {

                TextField("password", text: $password)
                    .appTextFieldStyle(text: password, isFocused: true, borderColor: .black.opacity(0.3))
                    .padding(.bottom, 8)
                
                ForEach(PasswordRule.allCases) { rule in
                    
                    PasswordRuleRow(
                        title: rule.displayName,
                        isValid: rule.isValid(password)
                    )
                    
                }
                
            }
            
        }
        
    }
    
}

// **********************************
// MARK: - Row
// **********************************

private struct PasswordRuleRow: View {
    
    let title: String
    let isValid: Bool
    
    private var tint: Color { self.isValid ? .green : .gray }
    private var symbolName: String { self.isValid ? "checkmark.circle.fill" : "circle" }
    
    var body: some View {
        
        HStack(spacing: 8) {
            
            Image(systemName: self.symbolName)
                .foregroundStyle(self.tint)
            
            Text(self.title)
                .foregroundStyle(self.tint)
            
        }
        .contentTransition(.symbolEffect(.replace))
        .strikethrough(self.isValid)
        
    }
    
}

#Preview {
    
    ValidationView()
        .padding(.horizontal, .large)
    
}
