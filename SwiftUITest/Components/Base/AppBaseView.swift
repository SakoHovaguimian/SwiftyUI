//
//  AppBaseView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/31/23.
//

import SwiftUI

struct AppBaseView<Content>: View where Content: View {

    private let horizontalPadding: Spacing
    private let content: Content

    public init(
        horizontalPadding: Spacing = .none,
        @ViewBuilder content: () -> Content) {
            
            self.horizontalPadding = horizontalPadding
            self.content = content()
            
        }
    
    var body : some View {
        
        ZStack {
            
            AppColor.eggShell
                .ignoresSafeArea()
            
            content
                .padding(.horizontal, self.horizontalPadding)
            
        }
        
    }
    
}
