//
//  MentionPickerView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 11/1/24.
//

import SwiftUI

import SwiftUI
import UIKit

struct MentionPickerView: View {
    @State private var text: String = ""
    @State private var showMentionList = false
    @State private var availableNames = ["John", "Jane", "Jack", "Jill"]
    @State private var filteredNames: [String] = []
    @State private var mentions: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Spacer()
            
//            if showMentionList {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: .appMedium) {
                        ForEach(filteredNames, id: \.self) { name in
                            Text("@\(name)")
                                .padding(.horizontal, 8)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                                .onTapGesture {
                                    addMention(name)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: 200, height: 150, alignment: .leading)
                .padding(.vertical, 24)
                .padding(.horizontal, 24)
                .background(ThemeManager.shared.background(.secondary))
                .clipShape(.rect(cornerRadius: 20))
                .appShadow(style: .card)
                .padding(.horizontal, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .frame(height: showMentionList ? nil : 0)
                .opacity(showMentionList ? 1 : 0)
//            }

            TextField("Type something...", text: $text, onEditingChanged: { isEditing in
                if !isEditing { showMentionList = false }
            })
            .onChange(of: text, perform: handleTextChange)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding([.horizontal])
            
            // Display text with mentions highlighted
            RoundedMentionText(text: text, mentions: mentions)
                .padding()
        }
    }
    
    private func handleTextChange(newText: String) {
        
        if let mentionTrigger = newText.last, mentionTrigger == "@" {
            
            withAnimation(.smooth) {
                showMentionList = true
                filteredNames = availableNames // Show full list initially
                
            }
            
        } else if showMentionList, let mentionStartIndex = text.lastIndex(of: "@") {
            let query = text[mentionStartIndex...].dropFirst()
            filteredNames = availableNames.filter { $0.lowercased().hasPrefix(query.lowercased()) }
        } else {
            showMentionList = false
        }
    }
    
    private func addMention(_ name: String) {
        if let atIndex = text.lastIndex(of: "@") {
            text = String(text[..<atIndex]) + "@\(name) " // Replace @query with @name
        } else {
            text += "@\(name) "
        }
        mentions.append(name)
        showMentionList = false
    }
}

struct RoundedMentionText: UIViewRepresentable {
    let text: String
    let mentions: [String]
    
    func makeUIView(context: Context) -> UILabel {
        let label = RoundedLabel()
        label.numberOfLines = 0
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = makeAttributedString()
    }
    
    private func makeAttributedString() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        for mention in mentions {
            let mentionText = "@\(mention)"
            let range = (text as NSString).range(of: mentionText)
            
            if range.location != NSNotFound {
                let attributes: [NSAttributedString.Key: Any] = [
                    .backgroundColor: UIColor.clear, // We’ll handle background in RoundedLabel
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
                ]
                attributedString.addAttributes(attributes, range: range)
            }
        }
        
        return attributedString
    }
}

// Custom UILabel subclass to draw rounded background for mentions
class RoundedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        guard let attributedText = attributedText else {
            super.drawText(in: rect)
            return
        }
        
        // Draw rounded backgrounds for mentions
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        attributedText.enumerateAttribute(.backgroundColor, in: NSRange(location: 0, length: attributedText.length), options: []) { value, range, _ in
            if let _ = value as? UIColor {
                // Get the bounding box of the mention text
                let textRect = self.boundingRect(for: attributedText, range: range)
                
                // Draw a rounded rectangle behind the mention text
                let roundedRect = UIBezierPath(roundedRect: textRect, cornerRadius: 12)
                UIColor.purple.setFill()
                roundedRect.fill()
            }
        }
        
        context?.restoreGState()
        
        // Draw the actual text
        super.drawText(in: rect)
    }
    
    private func boundingRect(for attributedText: NSAttributedString, range: NSRange) -> CGRect {
        let textStorage = NSTextStorage(attributedString: attributedText)
        let textContainer = NSTextContainer(size: CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = 0.0
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        layoutManager.ensureLayout(for: textContainer)
        
        // Get bounding rect for the specified range
        var glyphRange = NSRange()
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
        // Adjust for UILabel's text insets
        return boundingRect.offsetBy(dx: 0, dy: (bounds.height - boundingRect.height) / 2)
    }
}
#Preview {
    MentionPickerView()
}
