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
        
        scrollView()
            .overlay(alignment: .top) {
                header()
            }
            .safeAreaInset(edge: .bottom) {
                button()
            }
        
    }
    
    private func scrollView() -> some View {
        
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
                    
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollTargetLayout()
            
        }
        .background(.mint)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: self.$currentPage, anchor: .top)
        .defaultScrollAnchor(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        
    }
    
    private func header() -> some View {
        
        VStack(spacing: 32) {
            
            let item = getHeaderCopy(self.currentPage)
            
            if self.currentPage == .one {
                
                Text(item?.title ?? "N/A")
                    .frame(maxWidth: .infinity)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity
                    ))
                
                Text(item?.message ?? "N/A")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .leading)),
                        removal: .opacity
                    ))
                
            } else if self.currentPage == .two {
                
                Text(item?.title ?? "N/A")
                    .frame(maxWidth: .infinity)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity
                    ))
                
                Text(item?.message ?? "N/A")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .leading)),
                        removal: .opacity
                    ))
                
            } else if currentPage == .three {
                
                Text(item?.title ?? "N/A")
                    .frame(maxWidth: .infinity)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity
                    ))
                
                Text(item?.message ?? "N/A")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .leading)),
                        removal: .opacity
                    ))
                
            }
            
        }
        .padding(.vertical, 24)
        .background(.mint)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.easeInOut(duration: 0.6), value: self.currentPage)
        .allowsHitTesting(false)
        
    }
    
    func getHeaderCopy(_ currentPage: Page?) -> (title: String, message: String)? {
        
        guard let currentPage else { return ("", "") }
        
        switch currentPage {
        case .one: return (currentPage.title, currentPage.longPageMessage)
        case .two: return (currentPage.title, currentPage.longPageMessage)
        case .three: return (currentPage.title, currentPage.longPageMessage)
        }
        
    }
    
    private func button() -> some View {
        
        AppButton(title: "Finish", titleColor: .white, backgroundColor: .mint) {}
            .opacity(self.currentPage == .three ? 1 : 0)
            .offset(y: self.currentPage == .three ? 0 : 200)
            .animation(.smooth, value: self.currentPage)
            .padding(.horizontal, 32)
        
    }
    
}

#Preview {
    
    VerticalScrollView()
    
}
