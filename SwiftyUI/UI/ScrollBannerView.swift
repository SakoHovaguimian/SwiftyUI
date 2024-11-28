import SwiftUI

struct ScrollBannerView: View {
    
    let views: [AnyView]
    
    @State private var currentIndex: Int? = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var currentIndexFrame: CGRect = .init(x: 0, y: 0, width: 0, height: 100)
    
    var onPageChanged: ((Int) -> Void)?
    
    init(views: [AnyView],
         onPageChanged: ((Int) -> Void)? = nil) {
        
        self.views = views
        self.onPageChanged = onPageChanged
        
    }
    
    var body: some View {
        
        HStack {
            
            ScrollView(.horizontal) {
                
                LazyHStack(spacing: 0) {
                    
                    ForEach(0..<views.count, id: \.self) { index in
                        
                        views[index]
                            .containerRelativeFrame(.horizontal)
                            .readingFrame { frame in
                                
                                if index == currentIndex {
                                    currentIndexFrame = frame
                                    print(frame.height)
                                }
                                
                            }
                        
                    }
                    
                }
                .scrollTargetLayout()
                .frame(minHeight: self.currentIndexFrame.height)
                .frame(maxHeight: self.currentIndexFrame.height)
                
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: self.$currentIndex, anchor: .center)
            .scrollIndicators(.hidden)
//            .onChange(of: currentIndex) { oldValue, newValue in
//                onPageChanged?(newValue)
//            }
            .animation(.linear, value: self.currentIndex)
            
        }
        .background(.blue)
        .cornerRadius(.medium)
        .frame(minHeight: 100)
        .padding(.horizontal, 24)
        .frame(minHeight: self.currentIndexFrame.height)
        .animation(.smooth, value: self.currentIndex)
        .animation(.smooth, value: self.currentIndexFrame)
        
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
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .cornerRadius(.medium)
        
    }
    
}

#Preview {
    
    ScrollBannerViewPreview()
    
}
