//
//  SpacingTestView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/27/23.
//

import SwiftUI

enum Spacing: CGFloat {
    
    case none
    case small
    case medium
    case large
    
    var value: CGFloat {
        switch self {
        case .none: return 0
        case .small: return 8
        case .medium: return 16
        case .large: return 24
        }
    }
    
}

extension View {
    
    func padding(_ edges: Edge.Set = .all,
                 _ length: Spacing) -> some View {
        
        return self.padding(edges, length.value)
        
    }
    
    func padding(_ length: Spacing) -> some View {
        
        return self.padding(.all, length.value)
        
    }
    
}


extension EdgeInsets {
    
    init(top: Spacing = .none,
         left: Spacing = .none,
         bottom: Spacing = .none,
         right: Spacing = .none) {
        
        self.init(
            top: top.value,
            leading: left.value,
            bottom: bottom.value,
            trailing: right.value
        )
        
    }
    
    init(spacing: Spacing) {
        
        self.init(
            top: spacing.value,
            leading: spacing.value,
            bottom: spacing.value,
            trailing: spacing.value
        )
        
    }

    init(verticalSpacing spacing: Spacing) {
        
        self.init(
            top: spacing.value,
            leading: 0,
            bottom: spacing.value,
            trailing: 0
        )
        
    }

    init(horizontalSpacing spacing: Spacing) {
        
        self.init(
            top: 0,
            leading: spacing.value,
            bottom: 0,
            trailing: spacing.value
        )
        
    }
    
}

// Usage example:
struct SpacingTestView: View {
    
    var body: some View {
        
        VStack(spacing: 0) {
         
            Text("Hello, World!")
                .frame(maxWidth: .infinity)
                .background(.red)
                .padding(.horizontal, .large)

            Text("Hello, World!")
                .frame(maxWidth: .infinity)
                .background(.red)
                .padding(.horizontal, .medium)

            Text("Hello, World!")
                .frame(maxWidth: .infinity)
                .background(.red)
                .padding(.vertical, .large)
            
        }
        
    }
    
}

#Preview {
    SpacingTestView()
}
