import SwiftUI

struct ScrollBannerView: View {
    
    @State private var scrollBannerViewItems: [ScrollViewBannerViewItem]
    
    @State private var currentIndex: Int? = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var currentIndexFrame: CGRect = .init(x: 0, y: 0, width: 0, height: 52)
    
    var onPageChanged: ((Int) -> Void)?
    
    init(items: [ScrollViewBannerViewItem],
         onPageChanged: ((Int) -> Void)? = nil) {
        
        self._scrollBannerViewItems = .init(initialValue: items)
        self.onPageChanged = onPageChanged
        
    }
    
    var body: some View {
        
        VStack {
            
            scrollBox()
            
            ProgressIndicatorNew(
                selectedIndex: self.currentIndex ?? 0,
                numberOfItems: self.scrollBannerViewItems.count,
                backgroundStyle: self.scrollBannerViewItems[currentIndex ?? 0].backgroundColor
            )
            
        }
        
    }
    
    private func scrollBox() -> some View {
        
        ScrollView(.horizontal) {
            
            HStack(spacing: 0) {
                
                ForEach(0..<self.scrollBannerViewItems.count, id: \.self) { index in
                    
                    page(item: self.scrollBannerViewItems[index])
                        .readingFrame { frame in
                            
                            if index == self.currentIndex {
                                calculateFrameForCurrentItem(frame)
                            }
                            
                        }
                    
                }
                
            }
            .scrollTargetLayout()
            .frame(minHeight: self.currentIndexFrame.height)
            .frame(maxHeight: self.currentIndexFrame.height)
            
        }
        .background(self.scrollBannerViewItems[currentIndex ?? 0].backgroundColor.backgroundStyle())
        .cornerRadius(.medium)
        .padding(.horizontal, 24)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: self.$currentIndex, anchor: .center)
        .scrollIndicators(.hidden)
        .animation(.bouncy, value: self.currentIndexFrame)
        
    }
    
    private func page(item: ScrollViewBannerViewItem) -> some View {
        
        HStack {
            
            Text(item.message)
                .appFont(with: .title(.t5))
                .foregroundStyle(.white)
                .transaction { transaction in
                    transaction.animation = nil
                }
                .padding(.horizontal, .small)
            
        }
        .containerRelativeFrame(.horizontal)
        
    }
    
    private func calculateFrameForCurrentItem(_ frame: CGRect) {
        
        withAnimation(.bouncy) {
            
            let frameWithVerticalPadding: CGRect = .init(
                x: 0,
                y: 0,
                width: 0,
                height: frame.height + (Spacing.medium.value * 2)
            )
            
            self.currentIndexFrame = frameWithVerticalPadding
            
        }
        
    }
    
}

struct ScrollViewBannerViewItem: Identifiable {
    
    let id: String = UUID().uuidString
    let backgroundColor: AppBackgroundStyle
    let message: String
    
}

struct ScrollBannerViewPreview: View {
    
    @State private var items: [ScrollViewBannerViewItem] = [
        
        .init(
            backgroundColor: .color(.darkPurple),
            message: "This is some test"
        ),
        .init(
            backgroundColor: .color(.darkBlue),
            message: "This is some paragraph. This is some paragraph. This is some paragraph. This is some paragraph. This is some paragraph."
        ),
        .init(
            backgroundColor: .color(.darkGreen),
            message: "This is some paragraph. This is some paragraph"
        ),
        
    ]
    
    var body: some View {
        
        AppBaseView {
            
            ScrollBannerView(items: items) { pageIndex in
                print("Scrolled to page: \(pageIndex)")
            }
            
        }
        
    }
    
}

#Preview {
    
    ScrollBannerViewPreview()
    
}
