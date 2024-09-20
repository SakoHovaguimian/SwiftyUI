//
//  RichText.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/12/24.
//

import SwiftUI

import SwiftUI

// MARK: - Components Enum
enum NewComponent {
    case text(String)
    case rectangleOverlay(String)
    case circleOverlay(String)
    case numberedList([String])
}

// MARK: - Protocol for the service
protocol NewComponentParsingService {
    func parseCustomMarkup(_ input: String) -> [NewComponent]
    func parseNumberedList(_ input: String) -> [String]
}

// MARK: - Service Class
class NewDefaultComponentParsingService: NewComponentParsingService {
    
    func parseCustomMarkup(_ input: String) -> [NewComponent] {
        var components: [NewComponent] = []
        var currentText = ""
        let characters = Array(input)
        var i = 0
        
        while i < characters.count {
            if i + 1 < characters.count {
                switch (characters[i], characters[i+1]) {
                case ("[", "["):
                    
                    appendTextComponentIfNeeded(&components, &currentText)
                    
                    i = parseOverlayText(
                        start: i,
                        characters: characters,
                        components: &components,
                        startMarker: "[[",
                        endMarker: "]]",
                        componentType: { string in
                            return .rectangleOverlay(string)
                        }
                    )
                    
                case ("•", "•"):
                    
                    appendTextComponentIfNeeded(&components, &currentText)
                    
                    i = parseOverlayText(
                        start: i,
                        characters: characters,
                        components: &components,
                        startMarker: "••",
                        endMarker: "••",
                        componentType: { string in
                            return .circleOverlay(string)
                        }
                    )
                    
                case ("™", "™"):
                    appendTextComponentIfNeeded(&components, &currentText)
                    i = parseNumberedListOverlay(start: i, characters: characters, components: &components)
                    
                default:
                    currentText.append(characters[i])
                }
            } else {
                currentText.append(characters[i])
            }
            i += 1
        }
        
        if !currentText.isEmpty {
            components.append(.text(currentText))
        }
        
        return components
    }
    
    private func appendTextComponentIfNeeded(_ components: inout [NewComponent], _ currentText: inout String) {
        if !currentText.isEmpty {
            components.append(.text(currentText))
            currentText = ""
        }
    }
    
    private func parseOverlayText(start: Int, characters: [Character], components: inout [NewComponent], startMarker: String, endMarker: String, componentType: (String) -> NewComponent) -> Int {
        var i = start + startMarker.count
        var overlayText = ""
        while i + endMarker.count <= characters.count, Array(characters[i..<i+endMarker.count]) != Array(endMarker) {
            overlayText.append(characters[i])
            i += 1
        }
        components.append(componentType(overlayText))
        return i + endMarker.count - 1
    }
    
    private func parseNumberedListOverlay(start: Int, characters: [Character], components: inout [NewComponent]) -> Int {
        var i = start + 2
        var listText = ""
        while i + 2 <= characters.count, !(characters[i] == "™" && characters[i+1] == "™") {
            listText.append(characters[i])
            i += 1
        }
        let listItems = parseNumberedList(listText)
        components.append(.numberedList(listItems))
        return i + 1
    }
    
    func parseNumberedList(_ input: String) -> [String] {
        var items: [String] = []
        var currentItem = ""
        var isInItem = false
        let characters = Array(input)
        var i = 0
        
        while i < characters.count {
            if characters[i].isNumber, let j = findPeriod(after: i, in: characters) {
                if isInItem {
                    items.append(currentItem.trimmingCharacters(in: .whitespaces))
                }
                currentItem = ""
                isInItem = true
                i = j + 1 // Move past the period
                continue
            }
            if isInItem {
                currentItem.append(characters[i])
            }
            i += 1
        }
        
        if isInItem {
            items.append(currentItem.trimmingCharacters(in: .whitespaces))
        }
        
        return items
    }
    
    private func findPeriod(after index: Int, in characters: [Character]) -> Int? {
        var j = index + 1
        while j < characters.count, characters[j].isNumber {
            j += 1
        }
        return (j < characters.count && characters[j] == ".") ? j : nil
    }
}

// MARK: - View
struct CustomMarkupView: View {
    
    let text: String
    private let parsingService: NewComponentParsingService
    
    init(text: String, parsingService: NewComponentParsingService = NewDefaultComponentParsingService()) {
        self.text = text
        self.parsingService = parsingService
    }
    
    var body: some View {
        let components = parsingService.parseCustomMarkup(text)
        
        return VStack(alignment: .leading, spacing: 32) {
            ForEach(Array(components.enumerated()), id: \.offset) { _, component in
                renderComponent(component)
            }
        }
    }
    
    @ViewBuilder
    private func renderComponent(_ component: NewComponent) -> some View {
        switch component {
        case .text(let string):
            Text(string)
        case .rectangleOverlay(let string):
            VStack {
                RoundedRectangle(cornerRadius: 12.5)
                    .fill(Color.red)
                    .frame(height: 200)
                    .overlay(Text(string))
                
                Text(string)
                    .appFont(with: .header(.h5))
            }
        case .circleOverlay(let string):
            AppButton(
                title: string.capitalized,
                titleColor: .white,
                action: {}
            )
        case .numberedList(let items):
            VStack(alignment: .leading, spacing: 5) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    Text("\(index + 1). \(item)")
                        .bold(index == 0)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CustomMarkupView(
        text: "Welcome, [[Johny]]Here's your to-do list: ™™1. Buy groceries 2. Clean the house 3. Walk the dog™™ Hope you are feeling ••better•• today."
    ).padding()
}



















//import SwiftUI
//
//struct TextComponent {
//
//    enum Style {
//
//        case normal
//        case blue
//        case bold
//        case newLine
//        case currency
//        case percentage
//
//    }
//
//    let text: String
//    let style: Style
//
//}
//
//func parseCustomMarkup(_ input: String) -> [TextComponent] {
//
//    var components: [TextComponent] = []
//    var currentText = ""
//    var currentStyle: TextComponent.Style = .normal
//
//    let characters = Array(input)
//    var i = 0
//
//    while i < characters.count {
//
//        if i + 1 < characters.count {
//
//            if characters[i] == "[" && characters[i+1] == "[" {
//
//                if !currentText.isEmpty {
//
//                    components.append(TextComponent(text: currentText, style: currentStyle))
//                    currentText = ""
//
//                }
//
//                currentStyle = .blue
//                i += 2
//                continue
//
//            } else if characters[i] == "]" && characters[i+1] == "]" {
//
//                components.append(TextComponent(text: currentText, style: currentStyle))
//                currentText = ""
//                currentStyle = .normal
//                i += 2
//
//                continue
//
//            } else if characters[i] == "•" && characters[i+1] == "•" {
//
//                if currentStyle == .bold {
//                    // End of bold text
//                    components.append(TextComponent(text: currentText, style: .bold))
//                    currentText = ""
//                    currentStyle = .normal
//
//                } else {
//                    // Start of bold text
//                    if !currentText.isEmpty {
//                        components.append(TextComponent(text: currentText, style: currentStyle))
//                        currentText = ""
//                    }
//                    currentStyle = .bold
//
//                }
//                i += 2
//                continue
//            } else if characters[i] == "(" && characters[i+1] == "(" {
//                if !currentText.isEmpty {
//                    components.append(TextComponent(text: currentText, style: currentStyle))
//                    currentText = ""
//                }
//                components.append(TextComponent(text: "\n", style: .newLine))
//                i += 2
//                continue
//            } else if characters[i] == ")" && characters[i+1] == ")" {
//                components.append(TextComponent(text: currentText, style: currentStyle))
//                currentText = ""
//                i += 2
//                continue
//            } else if characters[i] == "$" && characters[i+1] == "$" {
//                if !currentText.isEmpty {
//                    components.append(TextComponent(text: currentText, style: currentStyle))
//                    currentText = ""
//                }
//                currentStyle = .currency
//                i += 2
//                continue
//            } else if characters[i] == "%" && characters[i+1] == "%" {
//                if !currentText.isEmpty {
//                    components.append(TextComponent(text: currentText, style: currentStyle))
//                    currentText = ""
//                }
//                currentStyle = .percentage
//                i += 2
//                continue
//            }
//        }
//
//        currentText.append(characters[i])
//        i += 1
//    }
//
//    if !currentText.isEmpty {
//        components.append(TextComponent(text: currentText, style: currentStyle))
//    }
//
//    return components
//}
//
//struct CustomMarkupText: View {
//    let text: String
//
//    var body: some View {
//        let components = parseCustomMarkup(text)
//
//        return components.reduce(Text("")) { (current, component) in
//            switch component.style {
//            case .normal:
//                return current + Text(component.text)
//            case .blue:
//                return current + Text(component.text).foregroundColor(.blue)
//            case .bold:
//                return current + Text(component.text).bold()
//            case .newLine:
//                return current + Text(component.text)
//            case .currency:
//                if let value = Double(component.text) {
//                    return current + Text(value, format: .currency(code: "USD"))
//                } else {
//                    return current + Text(component.text)
//                }
//            case .percentage:
//                if let value = Double(component.text) {
//                    return current + Text(value, format: .percent)
//                } else {
//                    return current + Text(component.text)
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    CustomMarkupText(text: "Welcome, [[Johny]]. Hope you are feeling ••better••. Come down ((Home To Mama)). Your balance is $$100.50$$ and you've completed %%0.75%% of your tasks.")
//        .padding()
//}
