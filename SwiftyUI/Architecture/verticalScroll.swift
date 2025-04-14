//
//  verticalScroll.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 4/14/25.
//

import SwiftUI

struct VerticalScrollView: View {
    
    enum Page: String, CaseIterable {
        
        case one
        case two
        case three
        
        var title: String {
            switch self {
            case .one: "Page one"
            case .two: "Page two"
            case .three: "Page three"
            }
        }
        
        var longPageMessage: String {
            switch self {
            case .one: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam auctor quam id massa faucibus dignissim. Nullam eget metus id nisl malesuada condimentum. Nam viverra fringilla erat, ut fermentum nunc feugiat eu."
            case .two: "Sed auctor ultricies ex, vel lacinia dolor faucibus vestibulum. Nullam ut viverra enim. Vestibulum luctus, nisl vitae scelerisque malesuada, metus odio varius elit, a euismod diam lacus vestibulum turpis."
            case .three: "Donec ut odio quis lectus sodales malesuada. Praesent commodo cursus magna, vel lacinia dolor faucibus vestibulum. Nullam ut viverra enim. Vestibulum luctus, nisl vitae scelerisque malesuada, metus odio varius elit, a euismod diam lacus vestibulum turpis."
            }
        }
        
    }
    
    @State var pages: [Page] = Page.allCases
    @State var currentPage: Page? = .one
    
    var body: some View {
        
        return ZStack {
            
            Color(uiColor: .systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                
                VStack(spacing: 0) {
                    
                    ForEach(pages, id: \.self) { page in
                        
                        VStack {
                            
                            Image(.image3)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(.rect(cornerRadius: 12))
                                .padding(.horizontal, 24)
                            
                        }
                        .frame(
                            width: UIScreen.main.bounds.width,
                            height: UIScreen.main.bounds.height
                        )
                        .background(.red)
                        
                    }

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollTargetLayout()
                
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: self.$currentPage, anchor: .top)
            .defaultScrollAnchor(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(alignment: .top) {
                
                VStack(spacing: 32) {
                    
                    if currentPage == .one,
                       let header = header(currentPage) {
                                                                        
                        Text(header.title)
                            .frame(maxWidth: .infinity)
                            .transition(.opacity.combined(with: .blurReplace))
                        
                        Text(header.message)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 32)
                            .multilineTextAlignment(.center)
                            .transition(.opacity.combined(with: .blurReplace))
    
                    }
                    
                    if currentPage == .two,
                       let header = header(currentPage) {
                                                                        
                        Text(header.title)
                            .frame(maxWidth: .infinity)
                            .transition(.opacity.combined(with: .blurReplace))
                        
                        Text(header.message)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 32)
                            .multilineTextAlignment(.center)
                            .transition(.opacity.combined(with: .blurReplace))
    
                    }
                    
                    if currentPage == .three,
                       let header = header(currentPage) {
                                                                        
                        Text(header.title)
                            .frame(maxWidth: .infinity)
                            .transition(.opacity.combined(with: .blurReplace))
                        
                        Text(header.message)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 32)
                            .multilineTextAlignment(.center)
                            .transition(.opacity.combined(with: .blurReplace))
    
                    }
                    
                }
                .padding(.bottom, 12)
                .background(Color(uiColor: .systemGray6))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .animation(.spring(), value: self.currentPage)
                
            }
            .safeAreaInset(edge: .bottom) {
                
                AppButton(title: "Finish", titleColor: .white, backgroundColor: .green) {}
                    .opacity(self.currentPage == .three ? 1 : 0)
                    .offset(y: self.currentPage == .three ? 0 : 200)
                    .animation(.smooth, value: self.currentPage)
                    .padding(.horizontal, 32)
                
            }
            
        }
        
        func header(_ currentPage: Page?) -> (title: String, message: String)? {
            
            guard let currentPage else { return ("", "") }
            
            switch currentPage {
            case .one: return (currentPage.title, currentPage.longPageMessage)
            case .two: return (currentPage.title, currentPage.longPageMessage)
            case .three: return (currentPage.title, currentPage.longPageMessage)
            }
            
        }
        
    }
    
}

#Preview {
    
    VerticalScrollView()
    
}
