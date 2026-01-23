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
    
    @State var password = ""
    
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
                        isValid: rule.isValid(password),
                        isEmpty: self.password.isEmpty
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
    let isEmpty: Bool
    
    private var tint: Color {
        
        if self.isEmpty {
            return .gray
        }
        
        return self.isValid ? .green : .gray // .red
        
    }
    
    private var symbolName: String { self.isValid ? "checkmark.circle.fill" : "circle" }
    
    var body: some View {
        
        HStack(spacing: 8) {
            
            Image(systemName: self.symbolName)
                .foregroundStyle(self.tint)
            
            Text(self.title)
                .foregroundStyle(self.tint)
                .overlay {
                    
                    Capsule()
                        .frame(height: 2)
                        .frame(maxWidth: self.isValid ? .infinity : 0, alignment: .leading)
                        .foregroundStyle(self.tint)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .animation(.snappy, value: self.isValid)
                    
                }
            
        }
        .contentTransition(.symbolEffect(.replace))
        
    }
    
}

#Preview {
    
    ValidationView()
        .padding(.horizontal, .large)
    
}
