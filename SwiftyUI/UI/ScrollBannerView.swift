import SwiftUI

struct ScrollBannerView: View {
    
    @State private var scrollBannerViewItems: [ScrollViewBannerViewItem]
    
    @State private var currentIndex: Int? = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var currentIndexFrame: CGRect = .init(x: 0, y: 0, width: 0, height: 100)
    
    var onPageChanged: ((Int) -> Void)?
    
    init(items: [ScrollViewBannerViewItem],
         onPageChanged: ((Int) -> Void)? = nil) {
        
        self._scrollBannerViewItems = .init(initialValue: items)
        self.onPageChanged = onPageChanged
        
    }
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                scrollBox()
                
            }
            .background(self.scrollBannerViewItems[currentIndex ?? 0].backgroundColor.backgroundStyle())
            .cornerRadius(.medium)
            .frame(minHeight: 100)
            .padding(.horizontal, 24)
            .frame(minHeight: self.currentIndexFrame.height)
            .animation(.bouncy, value: self.currentIndex)
            .animation(.bouncy, value: self.currentIndexFrame)
            
            
            ProgressIndicatorNew(
                selectedIndex: currentIndex ?? 0,
                numberOfItems: self.scrollBannerViewItems.count,
                backgroundStyle: self.scrollBannerViewItems[currentIndex ?? 0].backgroundColor
            )
            
        }
        
    }
    
    private func scrollBox() -> some View {
        
        ScrollView(.horizontal) {
            
            HStack(spacing: 0) {
                
                ForEach(0..<scrollBannerViewItems.count, id: \.self) { index in
                    
                    page(height: scrollBannerViewItems[index].height)
                        .containerRelativeFrame(.horizontal)
                        .readingFrame { frame in
                            
                            if index == currentIndex {
                                
                                withAnimation(.bouncy) {
                                    currentIndexFrame = frame
                                }
                                
                            }
                            
                        }
                    
                }
                
            }
            .scrollTargetLayout()
            .frame(minHeight: self.currentIndexFrame.height)
            .frame(maxHeight: self.currentIndexFrame.height)
            
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: self.$currentIndex, anchor: .center)
        .scrollIndicators(.hidden)
        .onChange(of: currentIndex) { oldValue, newValue in
            print(newValue)
        }
        .animation(.bouncy, value: self.currentIndex)
        
    }
    
    func page(height: CGFloat) -> some View {
        
        Text("Page \(height)")
            .frame(height: height)
            .containerRelativeFrame(.horizontal)
            .foregroundStyle(.white)
            .cornerRadius(.medium)
        
    }
    
}

struct ScrollViewBannerViewItem: Identifiable {
    
    let id: String = UUID().uuidString
    let backgroundColor: AppBackgroundStyle
    let height: CGFloat
    
}

struct ScrollBannerViewPreview: View {
    
    @State private var items: [ScrollViewBannerViewItem] = [
        .init(backgroundColor: .color(.indigo), height: 100),
        .init(backgroundColor: .color(.blue), height: 200),
//        .init(backgroundColor: .linearGradient(.linearGradient(
//            colors: [
//                .mint,
//                .indigo
//            ],
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )), height: 150),
        .init(backgroundColor: .color(.green), height: 400)
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
