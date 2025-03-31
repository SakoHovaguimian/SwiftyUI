//
//  WStack.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/16/25.
//


import SwiftUI

struct WStack: Layout {
    
    var alignment: HorizontalAlignment
    var spacing: CGFloat
    var lineSpacing: CGFloat
    var lineLimit: Int?
    var isHiddenLastItem: Bool
    var horizontalPadding: CGFloat
    
    init(alignment: HorizontalAlignment = .leading,
        spacing: CGFloat = 8,
        lineSpacing: CGFloat = 8,
        lineLimit: Int? = nil,
        isHiddenLastItem: Bool = false,
        horizontalPadding: CGFloat = 0) {
        
        self.alignment = alignment
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.lineLimit = lineLimit
        self.isHiddenLastItem = isHiddenLastItem
        self.horizontalPadding = horizontalPadding
        
    }
    
    func sizeThatFits(proposal: ProposedViewSize,
                      subviews: Subviews,
                      cache: inout ()) -> CGSize {
        
        let matrix = createMatrix(proposal: proposal, subviews: subviews)
        
        let rowHeight = subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
        let height = CGFloat(matrix.count) * rowHeight + CGFloat(max(0, matrix.count - 1)) * lineSpacing
        let width = proposal.width ?? (matrix.map { row in
            row.reduce(0) { $0 + subviews[$1].sizeThatFits(.unspecified).width } + CGFloat(max(0, row.count - 1)) * spacing
        }.max() ?? 0) + 2 * horizontalPadding
        
        return CGSize(width: width, height: height)
        
    }
    
    func placeSubviews(in bounds: CGRect,
                       proposal: ProposedViewSize,
                       subviews: Subviews, cache: inout ()) {
        
        let matrix = createMatrix(proposal: proposal, subviews: subviews)
        let rowHeight = subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
        
        var y = bounds.minY
        
        for row in matrix {
            
            let rowWidth = row.reduce(0) { $0 + subviews[$1].sizeThatFits(.unspecified).width } + CGFloat(max(0, row.count - 1)) * spacing
            var x = bounds.minX + horizontalPadding
            
            switch alignment {
            case .center:
                x += (bounds.width - rowWidth) / 2
            case .trailing:
                x += bounds.width - rowWidth - 2 * horizontalPadding
            default:
                break
            }
            
            for index in row {
                
                let subview = subviews[index]
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                subview.place(
                    at: CGPoint(x: x, y: y + (rowHeight - subviewSize.height) / 2),
                    proposal: ProposedViewSize(subviewSize)
                )
                
                x += subviewSize.width + spacing
            }
            
            y += rowHeight + lineSpacing
        }
        
    }
    
    private func createMatrix(proposal: ProposedViewSize,
                              subviews: Subviews) -> [[Int]] {
        
        var result: [[Int]] = []
        var currentRow: [Int] = []
        var currentWidth: CGFloat = 0
        let availableWidth = (proposal.width ?? .infinity) - 2 * horizontalPadding
        
        for i in 0..<subviews.count {
            
            if let lineLimit = lineLimit, lineLimit == result.count {
                
                lineLimitHandler(&result, subviews: subviews)
                return result
                
            }
            
            let width = subviews[i].sizeThatFits(.unspecified).width
            
            if i == subviews.count - 1 && isHiddenLastItem {
                
                if currentWidth + width + spacing > availableWidth {
                    result.append(currentRow)
                    currentRow = [i]
                    currentWidth = width
                }
                
                break
                
            }
            
            if currentWidth + width + spacing <= availableWidth {
                
                currentWidth += width + spacing
                currentRow.append(i)
                
            } else {
                
                result.append(currentRow)
                currentRow = [i]
                currentWidth = width
                
            }
            
        }
        
        if let lineLimit = lineLimit, lineLimit == result.count {
            
            lineLimitHandler(&result, subviews: subviews)
            return result
            
        }
        
        if currentRow.count == 1 && currentRow.last == subviews.count - 1 && isHiddenLastItem {
            return result
        }
        
        result.append(currentRow)
        return result
        
    }
    
    private func lineLimitHandler(_ matrix: inout [[Int]],
                                  subviews: Subviews) {
        
        guard var lastRow = matrix.last else { return }
        
        var lastWidth = lastRow.reduce(0) { currentWidth, i in
            return currentWidth + subviews[i].sizeThatFits(.unspecified).width + spacing
        }
        lastWidth -= spacing // Remove extra spacing
        
        let lastItemWidth = subviews[subviews.count - 1].sizeThatFits(.unspecified).width
        
        while lastWidth + lastItemWidth + spacing > (subviews[0].dimensions(in: .unspecified).width - 2 * horizontalPadding) {
            
            guard let i = lastRow.popLast() else { return }
            lastWidth -= (subviews[i].sizeThatFits(.unspecified).width + spacing)
        }
        
        if count(matrix: matrix) < subviews.count - 1 {
            lastRow.append(subviews.count - 1)
            matrix[matrix.endIndex - 1] = lastRow
        }
        
        if lastRow.count == 1 && lastRow.last == subviews.count - 1 {
            _ = matrix.popLast()
        }
        
    }
    
    private func count(matrix: [[Int]]) -> Int {
        matrix.reduce(0) { $0 + $1.count }
    }
    
}
