//
//  AmountTransferInputField.swift
//  swiftux-components
//
//  Created by SWIFT UX on 5/2/25.
//  Copyright © 2025 SWIFT UX. All rights reserved.
//

import SwiftUI

struct AmountTransferInputField: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    let placeholder: String
    let errorText: String
    let balance: Double
    let currency: Currency
    var isValid: Bool
    
    enum Currency {
        case usd
        case eur
        case gbp
        case custom(symbol: String, code: String)
        
        var symbol: String {
            switch self {
            case .usd: return "$"
            case .eur: return "€"
            case .gbp: return "£"
            case .custom(let symbol, _): return symbol
            }
        }
        
        var code: String {
            switch self {
            case .usd: return "USD"
            case .eur: return "EUR"
            case .gbp: return "GBP"
            case .custom(_, let code): return code
            }
        }
    }
    
    private func formatAmount(_ input: String) -> String {
        let filtered = input.filter { $0.isNumber || $0 == "." }
        if filtered.isEmpty { return "" }
        
        return filtered
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .center, spacing: 2) {
//                Text(currency.symbol)
//                    .foregroundStyle(text.isEmpty ? .secondary : .primary)
                ZStack(alignment: .leading) {
                    
                    TextField("0", text: $text)
                        .focused($isFocused)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.plain)
                        .onChange(of: text) { oldValue, newValue in
                            text = formatAmount(newValue)
                        }
                        .background(.backgroundTappable)
                        .opacity(0.09)
                    
                    let number = Double(text) ?? 0.0
                    let finalNumber = number * 0.01
                    
                    Text(
                        finalNumber.formatted(
                            .currency(code: "GBP").scale(1).sign(
                                strategy: .accountingAlways(showZero: true)
                            ).presentation(
                                .narrow
                            ).attributed
                        )
                    )
                        .foregroundStyle(text.isEmpty ? .primary : .primary)
                        .opacity(1)
                        .padding(.vertical, 8)
                        .background(.white)
                        .allowsHitTesting(false)
                        .tint(.red)
                }
            }
            .font(.system(size: 32, weight: .bold))
            
            HStack {
                Text(isFocused ? (isValid ? placeholder : errorText) : placeholder)
                    .foregroundColor(isValid ? .secondary : .red)
                    .contentTransition(.numericText())
                
                Spacer()
                
                Text("Balance: ")
                    .foregroundStyle(.secondary)
                +
                Text("\(String(format: "%.0f %@", balance, currency.code))")
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .font(.system(.subheadline, weight: .regular))
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .stroke(isFocused ? Color.primary : .gray.opacity(0.2), lineWidth: 1)
                .animation(.snappy, value: isFocused)
        }
        .animation(.smooth, value: isValid)
    }
}

#Preview {
    @Previewable @State var text: String = ""
    VStack(spacing: 20) {
        
        AmountTransferInputField(
            text: $text,
            placeholder: "Transfer amount",
            errorText: "Invalid amount",
            balance: 500,
            currency: .usd,
            isValid: true
        )
        
        AmountTransferInputField(
            text: $text,
            placeholder: "Transfer amount",
            errorText: "Invalid amount",
            balance: 500,
            currency: .eur,
            isValid: true
        )
        
        AmountTransferInputField(
            text: $text,
            placeholder: "Transfer amount",
            errorText: "Invalid amount",
            balance: 500,
            currency: .custom(symbol: "₽", code: "RUB"),
            isValid: true
        )
    }
    .padding()
}
