import SwiftUI

private struct BlurFadeModifier: ViewModifier, Animatable {
    
    var progress: CGFloat // 0 -> hidden, 1 -> visible
    
    var animatableData: CGFloat {
        get { self.progress }
        set { self.progress = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(max(0.01, self.progress))
            .blur(radius: (1 - self.progress) * 6)
    }
    
}

extension AnyTransition {
    
    static var blurFade: AnyTransition {
        .modifier(
            active: BlurFadeModifier(progress: 0),
            identity: BlurFadeModifier(progress: 1)
        )
    }
    
}

/// Wraps subviews across multiple lines (iOS 16+)
struct WrapLayout: Layout {
    
    // **********************************
    // MARK: - Properties
    // **********************************
    
    var wordSpacing: CGFloat = 6
    var lineSpacing: CGFloat = 6
    
    // **********************************
    // MARK: - Layout
    // **********************************
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        
        let maxWidth = proposal.width ?? .infinity
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        var totalHeight: CGFloat = 0
        var maxLineWidth: CGFloat = 0
        
        for view in subviews {
            
            let size = view.sizeThatFits(.unspecified)
            
            if lineWidth + size.width > maxWidth, lineWidth > 0 {
                
                totalHeight += lineHeight + self.lineSpacing
                maxLineWidth = max(maxLineWidth, lineWidth - self.wordSpacing)
                
                lineWidth = 0
                lineHeight = 0
                
            }
            
            lineWidth += size.width + self.wordSpacing
            lineHeight = max(lineHeight, size.height)
            
        }
        
        totalHeight += lineHeight
        maxLineWidth = max(maxLineWidth, lineWidth - self.wordSpacing)
        
        return CGSize(
            width: min(maxWidth, maxLineWidth),
            height: totalHeight
        )
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0
        
        for view in subviews {
            
            let size = view.sizeThatFits(.unspecified)
            
            if x + size.width > bounds.maxX, x > bounds.minX {
                
                y += lineHeight + self.lineSpacing
                x = bounds.minX
                lineHeight = 0
                
            }
            
            view.place(
                at: CGPoint(x: x, y: y),
                proposal: .unspecified
            )
            
            x += size.width + self.wordSpacing
            lineHeight = max(lineHeight, size.height)
            
        }
    }
}

// **********************************
// MARK: - BlurWordAnimationView
// **********************************

struct BlurWordAnimationView: View {
    
    enum HeightBehavior {
        case reserve
        case grow
    }
    
    // Inputs
    let text: String
    let textSize: CGFloat
    let perWordDelay: Double
    let startTime: Double
    let heightBehavior: HeightBehavior
    
    // Derived once
    private let words: [String]
    
    // State
    @State private var revealedCount = 0
    
    init(
        text: String,
        textSize: CGFloat = 20,
        perWordDelay: Double = 0.08,
        startTime: Double = 0.3,
        heightBehavior: HeightBehavior = .reserve
    ) {
        self.text = text
        self.textSize = textSize
        self.perWordDelay = perWordDelay
        self.startTime = startTime
        self.heightBehavior = heightBehavior
        
        // Tokenize once; add a space after each word except the last so wrapping looks natural
        let raw = text.split(whereSeparator: \.isWhitespace).map(String.init)
        var spaced: [String] = []
        spaced.reserveCapacity(raw.count)
        
        for (i, w) in raw.enumerated() {
            spaced.append(i < raw.count - 1 ? w + " " : w)
        }
        
        self.words = spaced
    }
    
    var body: some View {
        WrapLayout(wordSpacing: 0, lineSpacing: 8) {
            ForEach(visibleIndices, id: \.self) { i in
                
                Text(words[i])
                    .font(.system(size: textSize))
                    .modifier(wordModifier(for: i))
                    .transition(.blurFade)
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.smooth(duration: 0.3), value: revealedCount)
        .padding(12)
        .background(.white)
        .cornerRadius(.large)
        .shadow(radius: 8)
        .padding(.horizontal, 0)
        .task { await animate() }
    }
    
    private var visibleIndices: Range<Int> {
        switch self.heightBehavior {
        case .reserve:
            return 0..<self.words.count
        case .grow:
            return 0..<max(0, min(self.revealedCount, self.words.count))
        }
    }
    
    @ViewBuilder
    private func wordModifier(for index: Int) -> some ViewModifier {
        switch self.heightBehavior {
        case .reserve:
            // Current behavior: all words exist; hide unrevealed but layout reserves final height.
            return BlurFadeModifier(progress: index < self.revealedCount ? 1 : 0)
            
        case .grow:
            // Grow behavior: words only exist once revealed. Keep them fully visible.
            return BlurFadeModifier(progress: 1)
        }
    }
    
    @MainActor
    private func step(to n: Int) {
        withAnimation(.smooth(duration: min(0.25, self.perWordDelay * 0.9))) {
            self.revealedCount = n
        }
    }
    
    private func animate() async {
        try? await Task.sleep(nanoseconds: UInt64(self.startTime * 1_000_000_000))
        
        for n in 1...self.words.count {
            await MainActor.run { step(to: n) }
            try? await Task.sleep(nanoseconds: UInt64(self.perWordDelay * 1_000_000_000))
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            
            BlurWordAnimationView(
                text: "The history of software development is filled with fascinating breakthroughs and frustrating missteps, and nowhere is that more evident than in the shift from monolithic systems to distributed architectures.",
                textSize: 16,
                perWordDelay: 0.08,
                startTime: 0.3,
                heightBehavior: .reserve
            )
            
            BlurWordAnimationView(
                text: "The history of software development is filled with fascinating breakthroughs and frustrating missteps, and nowhere is that more evident than in the shift from monolithic systems to distributed architectures.",
                textSize: 16,
                perWordDelay: 0.08,
                startTime: 0.3,
                heightBehavior: .grow
            )
            .frame(maxWidth: .infinity)
            
        }
        .padding()
    }
}
