//
//  MarkdownRenderer.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/2/25.
//

import SwiftUI

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
        verticalSpacing: 8,
        listItemSpacing: 4,
        paragraphSpacing: 10,
        codeCornerRadius: 8
    )
    
}

// MARK: - Model

enum MarkdownBlock: Equatable {

    case heading(level: Int, inlines: [MarkdownInline])
    case paragraph(inlines: [MarkdownInline])
    case unorderedList(items: [[MarkdownInline]])
    case orderedList(items: [[MarkdownInline]])
    case codeBlock(language: String?, code: String)
    case blockQuote(inlines: [MarkdownInline])
    
}

enum MarkdownInline: Equatable {

    case text(String)
    case bold(String)
    case italic(String)
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

    // Very lightweight block parser.
    // Not spec-complete, but works well for most "app content" markdown.
    private static func parseLines(_ lines: [String]) -> [MarkdownBlock] {
        var result: [MarkdownBlock] = []

        var index = 0
        let count = lines.count

        while index < count {

            let line = lines[index]

            // Skip leading empty lines
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
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

            // Block quote
            if line.trimmingCharacters(in: .whitespaces).hasPrefix(">") {
                let quoteText = line
                    .trimmingCharacters(in: .whitespaces)
                    .dropFirst()
                    .trimmingCharacters(in: .whitespaces)
                let inlines = parseInline(String(quoteText))
                result.append(.blockQuote(inlines: inlines))
                index += 1
                continue
            }

            // Unordered list
            if isUnorderedListItem(line) {
                var items: [[MarkdownInline]] = []

                while index < count, isUnorderedListItem(lines[index]) {
                    let itemContent = stripUnorderedListMarker(lines[index])
                    items.append(parseInline(itemContent))
                    index += 1
                }

                result.append(.unorderedList(items: items))
                continue
            }

            // Ordered list
            if isOrderedListItem(line) {
                var items: [[MarkdownInline]] = []

                while index < count, isOrderedListItem(lines[index]) {
                    let itemContent = stripOrderedListMarker(lines[index])
                    items.append(parseInline(itemContent))
                    index += 1
                }

                result.append(.orderedList(items: items))
                continue
            }

            // Paragraph – collect until blank line or other block
            var paragraphLines: [String] = [line]
            index += 1

            while index < count {
                let next = lines[index]
                if next.trimmingCharacters(in: .whitespaces).isEmpty {
                    break
                }

                if next.hasPrefix("#")
                    || next.hasPrefix("```")
                    || isUnorderedListItem(next)
                    || isOrderedListItem(next)
                    || next.trimmingCharacters(in: .whitespaces).hasPrefix(">")
                {
                    break
                }

                paragraphLines.append(next)
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

    private static func isUnorderedListItem(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ")
    }

    private static func stripUnorderedListMarker(_ line: String) -> String {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("- ") {
            return String(trimmed.dropFirst(2))
        }
        if trimmed.hasPrefix("* ") {
            return String(trimmed.dropFirst(2))
        }
        return trimmed
    }

    private static func isOrderedListItem(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard let dotIndex = trimmed.firstIndex(of: ".") else { return false }
        let prefix = trimmed[..<dotIndex]
        return Int(prefix) != nil && trimmed[dotIndex...].hasPrefix(". ")
    }

    private static func stripOrderedListMarker(_ line: String) -> String {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard let dotIndex = trimmed.firstIndex(of: ".") else { return trimmed }
        let afterDot = trimmed.index(dotIndex, offsetBy: 2) // ". "
        if afterDot < trimmed.endIndex {
            return String(trimmed[afterDot...])
        }
        return ""
    }

    // MARK: - Inline parsing

    private static func parseInline(_ text: String) -> [MarkdownInline] {
        // Very simple inline parser:
        // **bold**, *italic*, `code`, [link](url)
        // Not nested-safe or exhaustive, but good enough for app copy.

        var result: [MarkdownInline] = []
        var index = text.startIndex

        func peek(_ offset: Int) -> Character? {
            guard let idx = text.index(text.startIndex, offsetBy: offset, limitedBy: text.index(before: text.endIndex)) else {
                return nil
            }
            return text[idx]
        }

        func advance(_ count: Int = 1) {
            index = text.index(index, offsetBy: count, limitedBy: text.endIndex) ?? text.endIndex
        }

        var currentBuffer = ""

        func flushBuffer() {
            guard !currentBuffer.isEmpty else { return }
            result.append(.text(currentBuffer))
            currentBuffer = ""
        }

        while index < text.endIndex {

            let remaining = text[index...]
            let remainingString = String(remaining)

            // Bold **
            if remainingString.hasPrefix("**"),
               let closingRange = remainingString.range(of: "**", options: [], range: remainingString.index(remainingString.startIndex, offsetBy: 2)..<remainingString.endIndex)
            {
                flushBuffer()
                let content = String(remainingString[remainingString.index(remainingString.startIndex, offsetBy: 2)..<closingRange.lowerBound])
                result.append(.bold(content))
                let advanceCount = content.count + 4 // ** + content + **
                advance(advanceCount)
                continue
            }

            // Italic *
            if remainingString.hasPrefix("*"),
               let closingRange = remainingString.range(of: "*", options: [], range: remainingString.index(after: remainingString.startIndex)..<remainingString.endIndex)
            {
                flushBuffer()
                let content = String(remainingString[remainingString.index(after: remainingString.startIndex)..<closingRange.lowerBound])
                result.append(.italic(content))
                let advanceCount = content.count + 2 // * + content + *
                advance(advanceCount)
                continue
            }

            // Code `
            if remainingString.hasPrefix("`"),
               let closingRange = remainingString.range(of: "`", options: [], range: remainingString.index(after: remainingString.startIndex)..<remainingString.endIndex)
            {
                flushBuffer()
                let content = String(remainingString[remainingString.index(after: remainingString.startIndex)..<closingRange.lowerBound])
                result.append(.code(content))
                let advanceCount = content.count + 2
                advance(advanceCount)
                continue
            }

            // Link [text](url)
            if remainingString.hasPrefix("["),
               let closingBracket = remainingString.firstIndex(of: "]"),
               closingBracket < remainingString.endIndex,
               remainingString[remainingString.index(after: closingBracket)...].hasPrefix("("),
               let closingParen = remainingString[remainingString.index(after: closingBracket)...].firstIndex(of: ")")
            {
                flushBuffer()

                let textRange = remainingString.index(after: remainingString.startIndex)..<closingBracket
                let linkText = String(remainingString[textRange])

                let urlStart = remainingString.index(after: closingBracket)
                let urlRangeStart = remainingString.index(urlStart, offsetBy: 1)
                let urlRange = urlRangeStart..<closingParen
                let urlText = String(remainingString[urlRange])

                result.append(.link(text: linkText, url: urlText))

                let advanceCount = remainingString.distance(from: remainingString.startIndex, to: closingParen) + 1
                advance(advanceCount)
                continue
            }

            // Default: accumulate character
            currentBuffer.append(text[index])
            advance()
        }

        flushBuffer()
        return result
    }
}

// MARK: - Blocks View

struct MarkdownBlocksView: View {

    let blocks: [MarkdownBlock]
    let theme: MarkdownRendererTheme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.verticalSpacing) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
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

        case let .unorderedList(items):
            MarkdownListView(
                items: items,
                isOrdered: false,
                theme: theme
            )
            .padding(.bottom, theme.paragraphSpacing)

        case let .orderedList(items):
            MarkdownListView(
                items: items,
                isOrdered: true,
                theme: theme
            )
            .padding(.bottom, theme.paragraphSpacing)

        case let .codeBlock(_, code):
            MarkdownCodeBlockView(
                code: code,
                theme: theme
            )
            .padding(.bottom, theme.paragraphSpacing)

        case let .blockQuote(inlines):
            MarkdownQuoteView(
                inlines: inlines,
                theme: theme
            )
            .padding(.bottom, theme.paragraphSpacing)
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
        case 1:
            theme.h1Font
        case 2:
            theme.h2Font
        default:
            theme.h3Font
        }
    }

    var body: some View {
        MarkdownInlineTextView(
            inlines: inlines,
            font: font,
            theme: theme
        )
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
            .environment(\.openURL, .init(handler: { url in
                
                print(url)
                return .handled
                
            }))
    }

    private func buildAttributedString() -> AttributedString {
        var attributed = AttributedString("")

        for inline in inlines {
            switch inline {
            case let .text(value):
                let part = AttributedString(value)
                attributed.append(part)

            case let .bold(value):
                var part = AttributedString(value)
                part.font = font.weight(.bold)
                attributed.append(part)

            case let .italic(value):
                var part = AttributedString(value)
                part.font = font.italic()
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

    let items: [[MarkdownInline]]
    let isOrdered: Bool
    let theme: MarkdownRendererTheme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.listItemSpacing) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, itemInlines in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(bullet(for: index))
                        .font(theme.bodyFont)
                        .fontWeight(.semibold)

                    MarkdownInlineTextView(
                        inlines: itemInlines,
                        font: theme.bodyFont,
                        theme: theme
                    )
                }
            }
        }
    }

    private func bullet(for index: Int) -> String {
        if isOrdered {
            "\(index + 1)."
        } else {
            "•"
        }
    }
}

// MARK: - Code Block View

struct MarkdownCodeBlockView: View {

    let code: String
    let theme: MarkdownRendererTheme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(code)
                .font(theme.codeFont)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.darkGreen)
                .background(theme.codeBackground)
                .clipShape(
                    RoundedRectangle(cornerRadius: theme.codeCornerRadius, style: .continuous)
                )
        }
    }
}

// MARK: - Quote View

struct MarkdownQuoteView: View {

    let inlines: [MarkdownInline]
    let theme: MarkdownRendererTheme

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .frame(width: 3)
                .foregroundStyle(theme.quoteStripe)

            MarkdownInlineTextView(
                inlines: inlines,
                font: theme.bodyFont.italic(),
                theme: theme
            )
        }
    }
}

// MARK: - Preview

struct MarkdownRendererView_Previews: PreviewProvider {

    static let sampleMarkdown = """
    # Markdown Renderer

    This is a simple **Markdown renderer** built in *SwiftUI*.

    ## Features

    ## Styles
    - Headings (#, ##, ###)
    - **Bold** and *italic* text
    - `Inline code`
    - Code blocks:
    ```swift
    struct ContentView: View {
        var body: some View {
            Text("Hello, Markdown!")
        }
    }
    ```
    
    ## Links
    - [Links](https://example.com)

    ## Quotes
    > This is a blockquote with *inline styles*.

    ## Lists
    1. First item
    2. Second item
    3. Third item
    """

    static var previews: some View {
        MarkdownRendererView(sampleMarkdown)
            .previewLayout(.sizeThatFits)
    }
}
