import SwiftUI

struct ScrollBannerView: View {
    
    let views: [AnyView]
    
    @State private var currentIndex: Int? = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var currentIndexFrame: CGRect = .init(x: 0, y: 0, width: 0, height: 100)
    
    private var colors: [AppForegroundStyle] = [
        
        .color(.indigo),
        .color(.mint),
        .color(.teal)
        
    ]
    
    var onPageChanged: ((Int) -> Void)?
    
    init(views: [AnyView],
         onPageChanged: ((Int) -> Void)? = nil) {
        
        self.views = views
        self.onPageChanged = onPageChanged
        
    }
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                scrollBox()
                
            }
            .background(self.colors[currentIndex ?? 0].foregroundStyle())
            .cornerRadius(.medium)
            .frame(minHeight: 100)
            .padding(.horizontal, 24)
            .frame(minHeight: self.currentIndexFrame.height)
            .animation(.bouncy, value: self.currentIndex)
            .animation(.bouncy, value: self.currentIndexFrame)
            
            
            ProgressIndicatorNew(
                selectedIndex: currentIndex ?? 0,
                numberOfItems: 3,
                foregroundStyle: self.colors[currentIndex ?? 0]
            )
            
        }
        
    }
    
    private func scrollBox() -> some View {
        
        ScrollView(.horizontal) {
            
            HStack(spacing: 0) {
                
                ForEach(0..<views.count, id: \.self) { index in
                    
                    views[index]
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
    
}

struct ScrollBannerViewPreview: View {
    
    @State private var pages = [AnyView]()
    
    var body: some View {
        
        ScrollBannerView(views: pages) { pageIndex in
            print("Scrolled to page: \(pageIndex)")
        }
        .onAppear {
            
            self.pages = [
                
                page(height: 100).asAnyView(),
                page(height: 200).asAnyView(),
                page(height: 150).asAnyView()
                
            ]
            
        }
        
    }
    
    func page(height: CGFloat) -> some View {
        
        Text("Page \(height)")
            .frame(height: height)
            .containerRelativeFrame(.horizontal)
            .foregroundStyle(.white)
            .cornerRadius(.medium)
        
    }
    
}

#Preview {
    
    ScrollBannerViewPreview()
    
}
