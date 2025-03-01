import SwiftUI

struct BannerItem: Identifiable {
    
    let id = UUID()
    let title: String
    let color: Color
    
    static func FAKE_TITLE_ITEMS() -> [Self] {
            
        return [
            
            BannerItem(
                title: "Page 1",
                color: .blue
            ),
            
            BannerItem(
                title: "Page 2",
                color: .red
            ),
            
            BannerItem(
                title: "Page 3",
                color: .green
            ),
            
            BannerItem(
                title: "Page 4",
                color: .purple
            )
            
        ]
        
    }
    
    static func FAKE_MESSAGE_ITEMS() -> [Self] {
            
        return [
            
            BannerItem(
                title: "5 out of 10 people don't read this message, but we do have a way to do this shit in a cool way",
                color: .blue
            ),
            
            BannerItem(
                title: "This is going to be a full screen banner. This is going to be a full screen banner. This is going to be a full screen banner. This is going to be a full screen banner.",
                color: .red
            ),
            
            BannerItem(
                title: "This is going to be a full screen banner. This is going to be a full screen banner. This is going to be a full screen banner. This is going to be a full screen banner. This is going to be a full screen banner. This is going to be a full screen banner. This is going to be a full screen banner. This is going to be a full screen banner. This is going to be a full screen banner. This is going to be a full screen banner. This is going to be a full screen banner. This is going to be a full screen banner.",
                color: .green
            ),
            
            BannerItem(
                title: "This is going to be a full screen banner.",
                color: .purple
            )
            
        ]
        
    }
    
}

struct ScrollBannerView: View {
    
    // MARK: - Properties -
    
    @State private var containerHeight: CGFloat = 0
    @State private var scrollOffsetX: CGFloat
    @State private var currentIndex: Int
    @State private var currentWidth: CGFloat
    
    @State private var bannerFrames: [Int: CGFloat] = [:]
    
    private let items: [BannerItem]
    
    init(items: [BannerItem],
         scrollOffsetX: CGFloat = 0,
         currentIndex: Int = 0,
         currentWidth: CGFloat = 0) {
        
        self.items = items
        self.scrollOffsetX = scrollOffsetX
        self.currentIndex = currentIndex
        self.currentWidth = currentWidth
        self.containerHeight = containerHeight
        
    }
    
    // MARK: - Body -
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            scrollView()
            
            ProgressIndicatorNew(
                selectedIndex: currentIndex,
                numberOfItems: items.count,
                backgroundStyle: .color(.white)
            )
            .padding(.bottom, 16)
                        
        }
        .background(.darkBlue)
        .clipShape(.rect(cornerRadius: 8))
        .padding(.horizontal, 24)
        
    }
    
    // MARK: - Views -
    
    private func scrollView() -> some View {
        
        GeometryReader { geometry in
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 0) {
                    
                    ForEach(items.indices, id: \.self) { index in
                        
                        bannerPage(for: items[index])
                            .frame(width: geometry.size.width)
                            .onGeometryChange(for: CGRect.self, of: { proxy in
                                return proxy.frame(in: .local)
                            }, action: { newValue in
                                
                                bannerFrames[index] = newValue.height
                                
                                if containerHeight == 0 && index == 0 {
                                    containerHeight = newValue.height
                                }
                                
                                if currentWidth == 0 {
                                    currentWidth = geometry.size.width
                                }
                                
                            })
                        
                    }
                    
                }
                .frame(maxHeight: containerHeight)
                .scrollTargetLayout()
                
            }
            .scrollTargetBehavior(.viewAligned)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                return geometry.contentOffset.x
            } action: { oldValue, newValue in
                handleScrollChange(oldOffset: oldValue, newOffset: newValue)
            }
            .background(.darkBlue)
            .clipShape(.rect(cornerRadius: 8))
            .animation(.linear(duration: 0.1), value: containerHeight)
            
        }
        .frame(height: containerHeight)
        
    }
    
    private func bannerPage(for item: BannerItem) -> some View {
        
        Text(item.title)
            .font(.body)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(16)
            .lineLimit(nil)
            .allowsTightening(true)
        
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
        let fromHeight = bannerFrames[fromIndex] ?? 0
        let toHeight = bannerFrames[targetIndex] ?? 0
        let interpolatedHeight = fromHeight + (toHeight - fromHeight) * fraction
        
        self.containerHeight = interpolatedHeight

        // 8) Optionally, update currentIndex in real time. For example:
        //    If fraction > 0.5, we’re “closer” to targetIndex, otherwise we’re at fromIndex.
        self.currentIndex = (fraction > 0.8) ? targetIndex : fromIndex
        
        // Debug prints
//        print("fromIndex: \(fromIndex), targetIndex: \(targetIndex), fraction: \(fraction)")
        
    }
    
}

#Preview("Title") {
    return ScrollBannerView(items: BannerItem.FAKE_TITLE_ITEMS())
}

#Preview("Message") {
    return ScrollBannerView(items: BannerItem.FAKE_MESSAGE_ITEMS())
}

struct SomePreviewView: View {
    
    var body: some View {
        ScrollBannerView(items: BannerItem.FAKE_MESSAGE_ITEMS())
    }
    
}
