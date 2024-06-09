//
//  BaseHeaderScrollView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import SwiftUI

struct BaseHeaderScrollView<NavBarContent: View,
                            ScrollViewContent: View>: View {
    
    private let alignment: Alignment
    private let navBarContent: NavBarContent
    private let scrollViewContent: ScrollViewContent
    
    private var horizontalPadding: Spacing = .medium
    
    private var loadingTitle: String = "Loading"
    private var isLoading: Bool = false
    private var loadingColor: Color
    
    public init(alignment: Alignment = .top,
                horizontalPadding: Spacing = .medium,
                loadingTitle: String = "Loading",
                loadingColor: Color = ThemeManager.shared.accentColor(),
                isLoading: Bool = false,
                @ViewBuilder navBarContent: () -> NavBarContent,
                @ViewBuilder scrollViewContent: () -> ScrollViewContent) {
        
        self.alignment = alignment
        self.horizontalPadding = horizontalPadding
        self.loadingTitle = loadingTitle
        self.loadingColor = loadingColor
        self.isLoading = isLoading
        self.navBarContent = navBarContent()
        self.scrollViewContent = scrollViewContent()
        
    }
    
    var body: some View {
        
        AppBaseView(alignment: self.alignment) {
            
            VStack(spacing: Spacing.none.value) {
                
                self.navBarContent
                
                ScrollView {
                    
                    self.scrollViewContent
                        .padding(.top, .medium)
                        .padding(.horizontal, self.horizontalPadding)
                    
                    
                }
//                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                .background(.clear)
                
            }
            
            if self.isLoading {
                
                ZStack {
                    
                    Color.black
                        .opacity(0.5)
                        .ignoresSafeArea()
                    
                    // TODO: - Replace With Something Else
                    ProgressView()
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            
        }
        .navigationBarBackButtonHidden()
        .scrollIndicators(.hidden)
        
    }
    
}
