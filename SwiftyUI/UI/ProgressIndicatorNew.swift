//
//  ProgressIndicatorNew.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/4/24.
//

import SwiftUI

struct ProgressIndicatorNew: View {
    
    var selectedIndex: Int = 0
    var numberOfItems: Int = 5
    var foregroundStyle: AppForegroundStyle = .color(.indigo)
    
    func fillColor(isSelected: Bool) -> AnyShapeStyle {
        
        return isSelected
        ? self.foregroundStyle.foregroundStyle()
        : AppForegroundStyle.color(.blackedGray).foregroundStyle()
        
    }
    
    var body: some View {
        
        HStack(spacing: Spacing.small.value) {
            
            ForEach(0..<numberOfItems, id: \.self) { index in
                
                Capsule()
                    .fill(fillColor(isSelected: selectedIndex == index))
                    .frame(width: selectedIndex == index ? 50 : 8, height: 8)
                
            }
            
        }
        .animation(.snappy, value: self.selectedIndex)
        
    }
    
}

#Preview {
    
    @Previewable @State var selectedIndex: Int = 0
    var numberOfItems = 5
    
    AppBaseView {
        
        ProgressIndicatorNew(
            selectedIndex: selectedIndex,
            numberOfItems: numberOfItems,
            foregroundStyle: .color(.indigo)
        )
        
    }
    .appOnTapGesture {
        
        let lastIndex = numberOfItems - 1
        let nextIndex = selectedIndex + 1
        let isLastIndex = selectedIndex == lastIndex
        
        selectedIndex = isLastIndex ? 0 : nextIndex
        
    }
    
}
