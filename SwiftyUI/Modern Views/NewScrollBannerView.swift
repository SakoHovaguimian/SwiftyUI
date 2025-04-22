////
////  NewScrollBannerView.swift
////  SwiftyUI
////
////  Created by Sako Hovaguimian on 1/13/25.
////
//
import SwiftUI

struct BannerItem2: Identifiable {
    
    let id = UUID()
    let title: String
    let height: CGFloat
    let color: Color
    
    static func FAKE_TITLE_ITEMS() -> [Self] {
            
        return [
            BannerItem2(title: "Page 1", height: 80, color: .blue),
            BannerItem2(title: "Page 2", height: 165, color: .red),
            BannerItem2(title: "Page 3", height: 60, color: .green),
            BannerItem2(title: "Page 4", height: 200, color: .purple)
        ]
        
    }
    
    static func FAKE_MESSAGE_ITEMS() -> [Self] {
            
        return [
            BannerItem2(title: "5 out of 10 people don't read this message", height: 120, color: .blue),
            BannerItem2(title: "This is going to be a full screen banner. This is going to be a full screen banner.", height: 165, color: .red),
            BannerItem2(title: "This is going to be a full screen banner.", height: 60, color: .green),
            BannerItem2(title: "Page 4", height: 200, color: .purple)
        ]
        
    }
    
}

struct ScrollBannerView2: View {
    
    // MARK: - Properties -
    
    @State private var containerHeight: CGFloat = 50
    @State private var scrollOffsetX: CGFloat
    @State private var currentIndex: Int
    @State private var currentWidth: CGFloat
    
    private let items: [BannerItem2]
    
    init(items: [BannerItem2],
         containerHeight: CGFloat = 50,
         scrollOffsetX: CGFloat = 0,
         currentIndex: Int = 0,
         currentWidth: CGFloat = 0) {
        
        self.items = items
        self.scrollOffsetX = scrollOffsetX
        self.currentIndex = currentIndex
        self.currentWidth = currentWidth
        self.containerHeight = items.first?.height ?? containerHeight
        
    }
    
    // MARK: - Body -
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            scrollView()
            
            Text("Current Page Index: \(currentIndex)")
            
        }
        
    }
    
    // MARK: - Views -
    
    private func scrollView() -> some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 0) {
                
                ForEach(items.indices, id: \.self) { index in
                    
                    bannerPage(for: items[index])
                        .frame(width: UIScreen.main.bounds.width - 64)
                        .onAppear {
                            
                            if currentWidth == 0 {
                                currentWidth = UIScreen.main.bounds.width - 64
                            }
                            
                        }
                    
                }
                
            }
            .scrollTargetLayout()
            
        }
        .scrollTargetBehavior(.paging)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            return geometry.contentOffset.x
        } action: { oldValue, newValue in
            handleScrollChange(oldOffset: oldValue, newOffset: newValue)
        }
        .clipShape(.rect(cornerRadius: 8))
        .frame(minHeight: containerHeight)
        .frame(maxHeight: containerHeight)
        .animation(.linear(duration: 0.1), value: containerHeight)
        .padding(.horizontal, 32)
        .onFirstAppear {
            self.containerHeight = items.first?.height ?? containerHeight
        }
        
    }
    
    private func bannerPage(for item: BannerItem2) -> some View {
        
        ZStack {
            
            item.color
            
            Text(item.title)
                .font(.body)
                .foregroundColor(.white)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .center)
            
        }
        
    }
    
    // MARK: - Helpers -
    
    private func handleScrollChange(oldOffset: CGFloat, newOffset: CGFloat) {
        
        guard currentWidth > 0 else { return }
        
        let pageWidth = currentWidth
        
        // 1) Compute the “pageFloat” to figure out which page we’re on or going to.
        let pageFloat = newOffset / pageWidth
        
        // 2) fromIndex is the current “base page” boundary we’re leaving from.
        let fromIndex = Int(floor(pageFloat))
        
        // 3) Clamp fromIndex to valid range.
        //    If fromIndex is out of bounds, return.
        guard fromIndex >= 0 && fromIndex < items.count else { return }
        
        // 4) Figure out the next page in the direction of scrolling.
        //    (Alternatively, you could just do `targetIndex = fromIndex + 1`
        //     if you only want to handle forward scroll. But we can handle
        //     backward by checking the sign.)
        let direction = (newOffset >= CGFloat(fromIndex) * pageWidth) ? 1 : -1
        let targetIndex = fromIndex + direction
        
        guard targetIndex >= 0 && targetIndex < items.count else { return }

        // 5) Distance we’ve scrolled *beyond* `fromIndex` in points:
        //    e.g., if fromIndex=2, that means the offset to the start of page 2 is
        //    `2 * pageWidth`. We see how many points beyond that we are.
        let fromIndexOffset = CGFloat(fromIndex) * pageWidth
        let dx = newOffset - fromIndexOffset  // can be negative if scrolling backward
        
        // If you want strictly forward fraction, do:
        //   dx = max(dx, 0)
        //   if dx < 0 => means we overshot fromIndex, but let's keep it simple:
        
        // 6) fraction of the way from `fromIndex` to `targetIndex`
        //    (ranging from 0.0 up to 1.0)
        var fraction = dx / pageWidth
        
        // For backward scroll, fraction might be negative or over 1.0
        // So clamp it:
        fraction = min(max(fraction, 0), 1)

        // 7) Interpolate the heights
        let fromHeight = items[fromIndex].height
        let toHeight   = items[targetIndex].height
        let interpolatedHeight = fromHeight + (toHeight - fromHeight) * fraction
        
        self.containerHeight = interpolatedHeight

        // 8) Optionally, update currentIndex in real time. For example:
        //    If fraction > 0.5, we’re “closer” to targetIndex, otherwise we’re at fromIndex.
        self.currentIndex = (fraction > 0.8) ? targetIndex : fromIndex
        
        // Debug prints
        print("fromIndex: \(fromIndex), targetIndex: \(targetIndex), fraction: \(fraction)")
        
    }
    
}

#Preview("Title") {
    return ScrollBannerView2(items: BannerItem2.FAKE_TITLE_ITEMS())
}

#Preview("Message") {
    return ScrollBannerView2(items: BannerItem2.FAKE_MESSAGE_ITEMS())
}

struct SomePreviewView2: View {
    
    var body: some View {
        ScrollBannerView2(items: BannerItem2.FAKE_TITLE_ITEMS())
    }
    
}
