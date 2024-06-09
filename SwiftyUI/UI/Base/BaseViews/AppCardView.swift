//
//  BaseCardView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import SwiftUI

struct AppCardView<Content>: View where Content: View {

    private let verticalPadding: Spacing
    private let horizontalPadding: Spacing
    private let backgroundColor: Color
    private let content: Content
    
    public init(verticalPadding: Spacing = .medium,
                horizontalPadding: Spacing = .medium,
                backgroundColor: Color = ThemeManager.shared.background(.secondary),
                @ViewBuilder content: () -> Content) {
        
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.backgroundColor = backgroundColor
        self.content = content()
        
    }
    
    var body : some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: 0) {
                
                self.content
                    .padding(.vertical, self.verticalPadding)
                    .padding(.horizontal, self.horizontalPadding)
                
                Spacer(minLength: 0)
                
            }
            
        }
        .background(self.backgroundColor)
        .cornerRadius(CornerRadius.small2.value)
        .appShadow()
        
    }
    
}

#Preview {
    
    AppCardView {
        
        HStack {
            
            Label(
                "Person",
                systemImage: "person.fill"
            )
            
            Spacer(minLength: 0)
            
            Image(systemName: "chevron.right")
            
        }
        .foregroundStyle(ThemeManager.shared.accentColor())
        
    }
    .padding(.horizontal, 32)
    
}
