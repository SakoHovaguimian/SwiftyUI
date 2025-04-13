//
//  CurrencyTextField.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/25/23.
//

import Foundation
import UIKit
import SwiftUI

protocol NumberFormatterProtocol: AnyObject {
    func string(from number: NSNumber) -> String?
    func string(for obj: Any?) -> String?
    var numberStyle: NumberFormatter.Style { get set }
    var maximumFractionDigits: Int { get set }
}

extension NumberFormatter: NumberFormatterProtocol { }

class PreviewNumberFormatter: NumberFormatterProtocol {
    
    let numberFormatter: NumberFormatter
    
    init(locale: Locale) {
        numberFormatter = NumberFormatter()
        numberFormatter.locale = locale
    }
    
    var numberStyle: NumberFormatter.Style {
        get {
            return numberFormatter.numberStyle
        }
        set {
            numberFormatter.numberStyle = newValue
        }
    }
    
    var maximumFractionDigits: Int {
        get {
            return numberFormatter.maximumFractionDigits
        }
        set {
            numberFormatter.maximumFractionDigits = newValue
        }
    }
    
    func string(from number: NSNumber) -> String? {
        return numberFormatter.string(from: number)
    }
    
    func string(for obj: Any?) -> String? {
        numberFormatter.string(for: obj)
    }
}

class CurrencyUITextField: UITextField {
    
    @Binding private var value: Int
    private let formatter: NumberFormatterProtocol

    init(formatter: NumberFormatterProtocol, value: Binding<Int>) {
        self.formatter = formatter
        self._value = value
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: superview)
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        addTarget(self, action: #selector(resetSelection), for: .allTouchEvents)
        keyboardType = .numberPad
        textAlignment = .right
        sendActions(for: .editingChanged)
    }

    override func removeFromSuperview() {
        print(#function)
    }

    override func deleteBackward() {
        text = textValue.digits.dropLast().string
        sendActions(for: .editingChanged)
    }

    private func setupViews() {
        tintColor = .clear
        font = .systemFont(ofSize: 40, weight: .regular)
        setInitialValue()
    }
    
    private func setInitialValue() {
        if value > 0 {
            let val = Double(value)
            let decimalValue = Decimal(val / 100.0)
            text = currency(from: decimalValue)
        }
    }

    @objc private func editingChanged() {
        text = currency(from: decimal)
        resetSelection()
        updateValue()
    }

    @objc private func resetSelection() {
        selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
    }

    private func updateValue() {
        DispatchQueue.main.async { [weak self] in
            self?.value = self?.intValue ?? 0
        }
    }

    private var textValue: String {
        return text ?? ""
    }

    private var decimal: Decimal {
      return textValue.decimal / pow(10, formatter.maximumFractionDigits)
    }

    private var intValue: Int {
        return NSDecimalNumber(decimal: decimal * 100).intValue
    }

    private func currency(from decimal: Decimal) -> String {
        return formatter.string(for: decimal) ?? ""
    }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    var digits: Self { filter (\.isWholeNumber) }
}

extension String {
    var decimal: Decimal { Decimal(string: digits) ?? 0 }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}

struct CurrencyTextField: UIViewRepresentable {

    typealias UIViewType = CurrencyUITextField

    let numberFormatter: NumberFormatterProtocol
    let currencyField: CurrencyUITextField

    init(numberFormatter: NumberFormatterProtocol, value: Binding<Int>) {
        self.numberFormatter = numberFormatter
        currencyField = CurrencyUITextField(formatter: numberFormatter, value: value)
    }

    func makeUIView(context: Context) -> CurrencyUITextField {
        return currencyField
    }

    func updateUIView(_ uiView: CurrencyUITextField, context: Context) { }
}


// PARENT VIEW

struct CurrencyContentViewTest: View {
    @State private var isSubtitleHidden = false
    @State private var value = 10
    
    private var numberFormatter: NumberFormatterProtocol
    
    init(numberFormatter: NumberFormatterProtocol = NumberFormatter()) {
        self.numberFormatter = numberFormatter
        self.numberFormatter.numberStyle = .currency
        self.numberFormatter.maximumFractionDigits = 2
    }

    var body: some View {
        VStack(spacing: 20) {
            
            Text("Send money")
                .font(.title)
            
            CurrencyTextField(numberFormatter: numberFormatter, value: $value)
                .padding(20)
                .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2))
                .frame(height: 100)
            
            Text("Send")
                .fontWeight(.bold)
                .padding(30)
                .frame(width: 180, height: 50)
                .background(Color.yellow)
                .cornerRadius(20)
                .onTapGesture {
                    if !isSubtitleHidden {
                        isSubtitleHidden.toggle()
                    }
                }
                
                
            if isSubtitleHidden {
                Text("Sending \(value)")
            }
            
            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 20)
    }
}


#Preview {
    CurrencyContentViewTest(numberFormatter: PreviewNumberFormatter(locale: .current))
}
