//
//  MarkdownRenderer.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/2/25.
//

import SwiftUI
import RegexBuilder

// MARK: - Public API

struct MarkdownRendererView: View {

    let markdown: String
    let theme: MarkdownRendererTheme

    init(
        _ markdown: String,
        theme: MarkdownRendererTheme = .default
    ) {
        self.markdown = markdown
        self.theme = theme
    }

    var body: some View {
        ScrollView {
            MarkdownBlocksView(
                blocks: MarkdownParser.parse(markdown: markdown),
                theme: theme
            )
            .padding()
        }
    }
}

// MARK: - Theme

struct MarkdownRendererTheme {

    var h1Font: Font
    var h2Font: Font
    var h3Font: Font
    var bodyFont: Font
    var codeFont: Font

    var textColor: Color
    var codeBackground: Color
    var linkColor: Color
    var quoteStripe: Color
    var dividerColor: Color
    
    // Syntax Highlighting Colors
    var syntaxKeyword: Color
    var syntaxString: Color
    var syntaxComment: Color
    var syntaxNumber: Color

    var verticalSpacing: CGFloat
    var listItemSpacing: CGFloat
    var paragraphSpacing: CGFloat
    var codeCornerRadius: CGFloat

    static let `default` = MarkdownRendererTheme(
        h1Font: .system(size: 28, weight: .bold),
        h2Font: .system(size: 24, weight: .semibold),
        h3Font: .system(size: 20, weight: .semibold),
        bodyFont: .system(size: 16, weight: .regular),
        codeFont: .system(.body, design: .monospaced),
        textColor: .primary,
        codeBackground: Color(.secondarySystemBackground),
        linkColor: .blue,
        quoteStripe: .blue.opacity(0.4),
        dividerColor: Color(.separator),
        syntaxKeyword: .pink,
        syntaxString: .indigo,
        syntaxComment: .green,
        syntaxNumber: .purple,
        verticalSpacing: 8,
        listItemSpacing: 4,
        paragraphSpacing: 10,
        codeCornerRadius: 8
    )
    
}

// MARK: - Models (AST)

enum TaskState: Hashable {
    case incomplete
    case completed
}

struct MarkdownListItem: Hashable {
    let level: Int
    let taskState: TaskState?
    let inlines: [MarkdownInline]
}

indirect enum MarkdownBlock: Hashable {

    case heading(level: Int, inlines: [MarkdownInline])
    case paragraph(inlines: [MarkdownInline])
    case list(items: [MarkdownListItem], isOrdered: Bool)
    case codeBlock(language: String?, code: String)
    case blockQuote(blocks: [MarkdownBlock]) // True AST: Quotes can hold other blocks
    case image(alt: String, url: String)
    case divider
    
}

enum MarkdownInline: Hashable {

    case text(String)
    case bold(String)
    case italic(String)
    case strikethrough(String)
    case code(String)
    
    case link(text: String,
              url: String)
    
}

// MARK: - Parser

enum MarkdownParser {

    // High-level entry point
    static func parse(markdown: String) -> [MarkdownBlock] {
        let lines = markdown.components(separatedBy: .newlines)
        return parseLines(lines)
    }

    // AST Block Parser
    private static func parseLines(_ lines: [String]) -> [MarkdownBlock] {
        var result: [MarkdownBlock] = []

        var index = 0
        let count = lines.count

        while index < count {

            let line = lines[index]
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // Skip leading empty lines
            if trimmedLine.isEmpty {
                index += 1
                continue
            }

            // Divider
            if trimmedLine == "---" || trimmedLine == "***" {
                result.append(.divider)
                index += 1
                continue
            }

            // Image
            if trimmedLine.hasPrefix("!["),
               let closeBracket = trimmedLine.firstIndex(of: "]"),
               trimmedLine.index(after: closeBracket) < trimmedLine.endIndex,
               trimmedLine[trimmedLine.index(after: closeBracket)] == "(",
               let closeParen = trimmedLine[closeBracket...].firstIndex(of: ")")
            {
                let altTextRange = trimmedLine.index(trimmedLine.startIndex, offsetBy: 2)..<closeBracket
                let altText = String(trimmedLine[altTextRange])
                
                let urlStart = trimmedLine.index(after: trimmedLine.index(after: closeBracket))
                let urlText = String(trimmedLine[urlStart..<closeParen])
                
                result.append(.image(alt: altText, url: urlText))
                index += 1
                continue
            }

            // Code block
            if line.hasPrefix("```") {
                let language = parseCodeFenceLanguage(from: line)
                var codeLines: [String] = []
                index += 1

                while index < count, !lines[index].hasPrefix("```") {
                    codeLines.append(lines[index])
                    index += 1
                }

                // Skip closing fence
                if index < count {
                    index += 1
                }

                let code = codeLines.joined(separator: "\n")
                result.append(.codeBlock(language: language, code: code))
                continue
            }

            // Heading
            if line.hasPrefix("#") {
                let (level, content) = parseHeading(line)
                let inlines = parseInline(content)
                result.append(.heading(level: level, inlines: inlines))
                index += 1
                continue
            }

            // Block quote (Recursive AST)
            if trimmedLine.hasPrefix(">") {
                var quoteLines: [String] = []
                
                while index < count {
                    let currentTrimmed = lines[index].trimmingCharacters(in: .whitespaces)
                    if !currentTrimmed.hasPrefix(">") && !currentTrimmed.isEmpty {
                        break
                    }
                    
                    if currentTrimmed.hasPrefix(">") {
                        let stripped = currentTrimmed.dropFirst()
                        let finalLine = stripped.hasPrefix(" ") ? String(stripped.dropFirst()) : String(stripped)
                        quoteLines.append(finalLine)
                    } else {
                        quoteLines.append("")
                    }
                    index += 1
                }
                
                let nestedBlocks = parseLines(quoteLines)
                result.append(.blockQuote(blocks: nestedBlocks))
                continue
            }

            // Unordered list
            if let firstItem = parseListItem(line, isOrdered: false) {
                var items: [MarkdownListItem] = [firstItem]
                index += 1

                while index < count, let nextItem = parseListItem(lines[index], isOrdered: false) {
                    items.append(nextItem)
                    index += 1
                }

                result.append(.list(items: items, isOrdered: false))
                continue
            }

            // Ordered list
            if let firstItem = parseListItem(line, isOrdered: true) {
                var items: [MarkdownListItem] = [firstItem]
                index += 1

                while index < count, let nextItem = parseListItem(lines[index], isOrdered: true) {
                    items.append(nextItem)
                    index += 1
                }

                result.append(.list(items: items, isOrdered: true))
                continue
            }

            // Paragraph – collect until blank line or other block
            var paragraphLines: [String] = [trimmedLine]
            index += 1

            while index < count {
                let next = lines[index]
                let nextTrimmed = next.trimmingCharacters(in: .whitespaces)
                
                if nextTrimmed.isEmpty { break }

                if next.hasPrefix("#")
                    || next.hasPrefix("```")
                    || nextTrimmed == "---"
                    || nextTrimmed == "***"
                    || nextTrimmed.hasPrefix("![")
                    || parseListItem(next, isOrdered: false) != nil
                    || parseListItem(next, isOrdered: true) != nil
                    || nextTrimmed.hasPrefix(">")
                {
                    break
                }

                paragraphLines.append(nextTrimmed)
                index += 1
            }

            let paragraphText = paragraphLines.joined(separator: " ")
            let paragraphInlines = parseInline(paragraphText)
            result.append(.paragraph(inlines: paragraphInlines))
        }

        return result
    }

    // MARK: - Block helpers

    private static func parseCodeFenceLanguage(from line: String) -> String? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let components = trimmed.components(separatedBy: "```")
        let language = components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : ""
        return language.isEmpty ? nil : language
    }

    private static func parseHeading(_ line: String) -> (Int, String) {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let level = trimmed.prefix { $0 == "#" }.count
        let content = trimmed.dropFirst(level).trimmingCharacters(in: .whitespaces)
        return (max(1, min(level, 6)), String(content))
    }

    private static func parseListItem(_ line: String, isOrdered: Bool) -> MarkdownListItem? {
        // Calculate indentation using spaces/tabs
        let indentSpaces = line.prefix(while: { $0 == " " }).count
        let indentTabs = line.prefix(while: { $0 == "\t" }).count
        let level = indentTabs > 0 ? indentTabs : indentSpaces / 2
        
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        var content = ""
        
        if isOrdered {
            guard let dotIndex = trimmed.firstIndex(of: "."), Int(trimmed[..<dotIndex]) != nil else { return nil }
            let afterDot = trimmed.index(dotIndex, offsetBy: 2)
            guard afterDot <= trimmed.endIndex else { return nil }
            content = String(trimmed[afterDot...])
        } else {
            guard trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") else { return nil }
            content = String(trimmed.dropFirst(2))
        }
        
        var taskState: TaskState? = nil
        if content.hasPrefix("[ ] ") {
            taskState = .incomplete
            content = String(content.dropFirst(4))
        } else if content.lowercased().hasPrefix("[x] ") {
            taskState = .completed
            content = String(content.dropFirst(4))
        }
        
        return MarkdownListItem(level: level, taskState: taskState, inlines: parseInline(content))
    }

    // MARK: - Inline parsing

    private static func parseInline(_ text: String) -> [MarkdownInline] {
        var result: [MarkdownInline] = []
        var index = text.startIndex
        var currentBuffer = ""

        func flushBuffer() {
            if !currentBuffer.isEmpty {
                result.append(.text(currentBuffer))
                currentBuffer = ""
            }
        }

        while index < text.endIndex {
            let char = text[index]
            
            // 1. Check for escaped characters
            if char == "\\" {
                let nextIndex = text.index(after: index)
                if nextIndex < text.endIndex {
                    currentBuffer.append(text[nextIndex])
                    index = text.index(after: nextIndex)
                    continue
                }
            }

            let remaining = text[index...]

            // Bold **
            if remaining.hasPrefix("**"),
               let endRange = remaining.dropFirst(2).range(of: "**") {
                flushBuffer()
                let content = String(remaining[remaining.index(index, offsetBy: 2)..<endRange.lowerBound])
                result.append(.bold(content))
                index = endRange.upperBound
                continue
            }

            // Italic *
            if remaining.hasPrefix("*"),
               let endRange = remaining.dropFirst(1).range(of: "*") {
                flushBuffer()
                let content = String(remaining[remaining.index(after: index)..<endRange.lowerBound])
                result.append(.italic(content))
                index = endRange.upperBound
                continue
            }
            
            // Strikethrough ~~
            if remaining.hasPrefix("~~"),
               let endRange = remaining.dropFirst(2).range(of: "~~") {
                flushBuffer()
                let content = String(remaining[remaining.index(index, offsetBy: 2)..<endRange.lowerBound])
                result.append(.strikethrough(content))
                index = endRange.upperBound
                continue
            }

            // Code `
            if remaining.hasPrefix("`"),
               let endRange = remaining.dropFirst(1).range(of: "`") {
                flushBuffer()
                let content = String(remaining[remaining.index(after: index)..<endRange.lowerBound])
                result.append(.code(content))
                index = endRange.upperBound
                continue
            }

            // Link [text](url)
            if remaining.hasPrefix("["),
               let closeBracket = remaining.firstIndex(of: "]"),
               let openParen = remaining[closeBracket...].firstIndex(of: "("),
               openParen == remaining.index(after: closeBracket),
               let closeParen = remaining[openParen...].firstIndex(of: ")")
            {
                flushBuffer()
                let textRange = remaining.index(after: index)..<closeBracket
                let linkText = String(remaining[textRange])

                let urlRange = remaining.index(after: openParen)..<closeParen
                let urlText = String(remaining[urlRange])

                result.append(.link(text: linkText, url: urlText))
                index = remaining.index(after: closeParen)
                continue
            }

            // Default: accumulate character
            currentBuffer.append(char)
            index = text.index(after: index)
        }

        flushBuffer()
        return result
    }
}

// MARK: - Syntax Highlighter (Swift Regex)

struct MarkdownSyntaxHighlighter {
    
    static func highlight(_ code: String, theme: MarkdownRendererTheme) -> AttributedString {
        var attr = AttributedString(code)
        attr.font = theme.codeFont
        attr.foregroundColor = theme.textColor
        
        // Fast Regex matches for common programming tokens
        let keywordRegex = try! Regex(#"\b(let|var|struct|class|enum|func|import|some|return|if|else|switch|case|true|false)\b"#)
        let stringRegex = try! Regex(#"("[^"]*")"#)
        let commentRegex = try! Regex(#"(//.*)"#)
        let numberRegex = try! Regex(#"(\b\d+\b)"#)
        
        func applyStyle(regex: Regex<AnyRegexOutput>, color: Color) {
            for match in code.matches(of: regex) {
                // Safely convert String.Index bounds to AttributedString.Index
                if let lowerBound = AttributedString.Index(match.range.lowerBound, within: attr),
                   let upperBound = AttributedString.Index(match.range.upperBound, within: attr) {
                    
                    let attrRange = lowerBound..<upperBound
                    attr[attrRange].foregroundColor = color
                    
                }
            }
        }
        
        applyStyle(regex: keywordRegex, color: theme.syntaxKeyword)
        applyStyle(regex: numberRegex, color: theme.syntaxNumber)
        applyStyle(regex: stringRegex, color: theme.syntaxString)
        applyStyle(regex: commentRegex, color: theme.syntaxComment)
        
        return attr
    }
}

// MARK: - Blocks View

struct MarkdownBlocksView: View {

    let blocks: [MarkdownBlock]
    let theme: MarkdownRendererTheme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.verticalSpacing) {
            ForEach(blocks, id: \.self) { block in
                blockView(block)
            }
        }
        .foregroundStyle(theme.textColor)
    }

    @ViewBuilder
    private func blockView(_ block: MarkdownBlock) -> some View {
        switch block {
        case let .heading(level, inlines):
            MarkdownHeadingView(
                level: level,
                inlines: inlines,
                theme: theme
            )
            .padding(.bottom, theme.paragraphSpacing)

        case let .paragraph(inlines):
            MarkdownInlineTextView(
                inlines: inlines,
                font: theme.bodyFont,
                theme: theme
            )
            .padding(.bottom, theme.paragraphSpacing)

        case let .list(items, isOrdered):
            MarkdownListView(
                items: items,
                isOrdered: isOrdered,
                theme: theme
            )
            .padding(.bottom, theme.paragraphSpacing)

        case let .codeBlock(_, code):
            MarkdownCodeBlockView(
                code: code,
                theme: theme
            )
            .padding(.bottom, theme.paragraphSpacing)

        case let .blockQuote(nestedBlocks):
            MarkdownQuoteView(
                blocks: nestedBlocks,
                theme: theme
            )
            .padding(.bottom, theme.paragraphSpacing)
            
        case let .image(alt, url):
            MarkdownImageView(
                alt: alt,
                url: url,
                theme: theme
            )
            .padding(.bottom, theme.paragraphSpacing)
            
        case .divider:
            Divider()
                .overlay(theme.dividerColor)
                .padding(.vertical, theme.paragraphSpacing)
        }
    }
}

// MARK: - Heading View

struct MarkdownHeadingView: View {

    let level: Int
    let inlines: [MarkdownInline]
    let theme: MarkdownRendererTheme

    private var font: Font {
        switch level {
        case 1: theme.h1Font
        case 2: theme.h2Font
        default: theme.h3Font
        }
    }

    var body: some View {
        MarkdownInlineTextView(
            inlines: inlines,
            font: font,
            theme: theme
        )
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Inline Text View

struct MarkdownInlineTextView: View {
    
    let inlines: [MarkdownInline]
    let font: Font
    let theme: MarkdownRendererTheme

    var body: some View {
        Text(buildAttributedString())
            .font(font)
//            .padding(12)
//            .background(Color(.secondarySystemBackground))
            .textSelection(.enabled) // Highlight & copy text!
            .environment(\.openURL, .init(handler: { url in
                print("Opening link: \(url)")
                return .handled
            }))
    }

    private func buildAttributedString() -> AttributedString {
        var attributed = AttributedString("")

        for inline in inlines {
            switch inline {
            case let .text(value):
                attributed.append(AttributedString(value))

            case let .bold(value):
                var part = AttributedString(value)
                part.font = font.weight(.bold)
                attributed.append(part)

            case let .italic(value):
                var part = AttributedString(value)
                part.font = font.italic()
                attributed.append(part)
                
            case let .strikethrough(value):
                var part = AttributedString(value)
                part.strikethroughStyle = .single
                attributed.append(part)

            case let .code(value):
                var part = AttributedString(value)
                part.font = theme.codeFont
                attributed.append(part)

            case let .link(text, url):
                var part = AttributedString(text)
                part.link = URL(string: url)
                part.foregroundColor = theme.linkColor
                attributed.append(part)
            }
        }

        return attributed
    }
}

// MARK: - List View

struct MarkdownListView: View {

    let items: [MarkdownListItem]
    let isOrdered: Bool
    let theme: MarkdownRendererTheme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.listItemSpacing) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    
                    // Indentation
                    if item.level > 0 {
                        Spacer()
                            .frame(width: CGFloat(item.level) * 16)
                    }
                    
                    // Task Checkbox OR Bullet/Number
                    if let task = item.taskState {
                        Image(systemName: task == .completed ? "checkmark.square.fill" : "square")
                            .foregroundColor(task == .completed ? .blue : .secondary)
                    } else {
                        Text(bullet(for: index, level: item.level))
                            .font(theme.bodyFont)
                            .fontWeight(.semibold)
                    }

                    MarkdownInlineTextView(
                        inlines: item.inlines,
                        font: theme.bodyFont,
                        theme: theme
                    )
                }
            }
        }
    }

    private func bullet(for index: Int, level: Int) -> String {
        if isOrdered {
            return "\(index + 1)."
        } else {
            // Alternate bullets based on nesting level
            return level % 2 == 0 ? "•" : "◦"
        }
    }
}

// MARK: - Code Block View

struct MarkdownCodeBlockView: View {

    let code: String
    let theme: MarkdownRendererTheme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(MarkdownSyntaxHighlighter.highlight(code, theme: theme))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(theme.codeBackground)
                .clipShape(
                    RoundedRectangle(cornerRadius: theme.codeCornerRadius, style: .continuous)
                )
                .textSelection(.enabled) // Select and copy code!
        }
    }
}

// MARK: - Quote View

struct MarkdownQuoteView: View {

    let blocks: [MarkdownBlock]
    let theme: MarkdownRendererTheme

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .frame(width: 3)
                .foregroundStyle(theme.quoteStripe)

            // Recursive AST Call!
            MarkdownBlocksView(
                blocks: blocks,
                theme: theme
            )
            .padding(.leading, 4)
            .opacity(0.8)
        }
    }
}

// MARK: - Image View

struct MarkdownImageView: View {
    
    let alt: String
    let url: String
    let theme: MarkdownRendererTheme
    
    var body: some View {
        if let imageURL = URL(string: url) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(theme.codeCornerRadius)
                        .accessibilityLabel(alt)
                case .failure:
                    HStack(spacing: 8) {
                        Image(systemName: "photo.fill")
                        Text(alt).font(theme.bodyFont)
                    }
                    .foregroundColor(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Previews

struct MarkdownRendererView_Previews: PreviewProvider {

    static let advancedMarkdown = """
    # The Ultimate Renderer
    
    ![Swift Logo](https://developer.apple.com/assets/elements/icons/swift/swift-96x96_2x.png)
    
    This handles **bold**, *italic*, ~~strikethrough~~, and `inline code`.
    
    You can even escape characters! Look: \\*This is literally wrapped in asterisks\\* without becoming italicized.
    
    ## Nested & Task Lists
    
    - [x] Adopt Swift Regex
    - [x] Move to AST
    - [ ] Take a break
    
    - Parent Item
      - Indented Child Item
      - Another Child Item
        - Deeply Nested Child

    ## Syntax Highlighting & Selection
    
    Try long-pressing this code snippet to select it:
    
    ```swift
    import SwiftUI

    struct Magic {
        let regex = true // Regex is amazing
        
        func castSpell() -> String {
            return "Expecto Patronum!"
        }
    }
    ```
    """
    
    static let recursiveMarkdown = """
    # Recursive Block Quotes
    
    > This is the first level of the quote.
    > 
    > > This is a nested quote!
    > > It works because of the AST implementation.
    > >
    > > - [x] Quotes can contain lists
    > > - [ ] Wow, right?
    """

    static var previews: some View {
        Group {
            MarkdownRendererView(advancedMarkdown)
                .previewDisplayName("Feature Showcase")
            
            MarkdownRendererView(recursiveMarkdown)
                .previewDisplayName("AST Recursive Quotes")
        }
    }
}
