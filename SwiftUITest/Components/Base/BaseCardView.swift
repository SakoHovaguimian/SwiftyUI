//
//  BaseCardView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/31/23.
//

import SwiftUI

struct AppCardView<Content>: View where Content: View {

    private let verticalPadding: Spacing
    private let horizontalPadding: Spacing
    private let content: Content
    
    public init(verticalPadding: Spacing = .medium,
                horizontalPadding: Spacing = .medium,
                @ViewBuilder content: () -> Content) {
        
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.content = content()
        
    }
    
    var body : some View {
        
        VStack {
            
            HStack {
                
                self.content
                    .padding(.vertical, self.verticalPadding)
                    .padding(.horizontal, self.horizontalPadding)
                
                Spacer()
                
            }
            
        }
        .background(AppColor.eggShell)
        .cornerRadius(12)
        .appShadow()
        
    }
    
}
