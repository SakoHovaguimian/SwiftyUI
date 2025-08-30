import SwiftUI

/// Wraps subviews across multiple lines (iOS 16+)
struct WrapLayout: Layout {
    var spacing: CGFloat = 6
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var lineW: CGFloat = 0, lineH: CGFloat = 0
        var totalH: CGFloat = 0, maxLineW: CGFloat = 0
        
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if lineW + s.width > maxWidth, lineW > 0 {
                totalH += lineH + spacing
                maxLineW = max(maxLineW, lineW - spacing)
                lineW = 0; lineH = 0
            }
            lineW += s.width + spacing
            lineH = max(lineH, s.height)
        }
        totalH += lineH
        maxLineW = max(maxLineW, lineW - spacing)
        return CGSize(width: min(maxWidth, maxLineW), height: totalH)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX, x > bounds.minX {
                y += lineH + spacing
                x = bounds.minX
                lineH = 0
            }
            v.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += s.width + spacing
            lineH = max(lineH, s.height)
        }
    }
}

struct BlurWordAnimationView: View {
    // Inputs
    let text: String
    let textSize: CGFloat
    let perWordDelay: Double
    let startTime: Double
    
    // Derived once
    private let words: [String]
    
    // State
    @State private var revealedCount = 0
    
    init(text: String,
         textSize: CGFloat = 20,
         perWordDelay: Double = 0.08,
         startTime: Double = 0.3)
    {
        self.text = text
        self.textSize = textSize
        self.perWordDelay = perWordDelay
        self.startTime = startTime
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
        WrapLayout(spacing: 6) {
            ForEach(words.indices, id: \.self) { i in
                Text(words[i])
                    .font(.system(size: textSize))
//                    .blur(radius: i < revealedCount ? 0 : 6)
                    .opacity(i < revealedCount ? 1 : 0.01)
                    .blur(radius: i < revealedCount ? 0 : 6)
//                    .opacity(i < revealedCount ? 1 : 0.25)
//                    .foregroundStyle(i == revealedCount ? .blue : .black)
                    .animation(.smooth(duration: 0.3), value: revealedCount)
//                    .overlay {
//                        
//                        if i == revealedCount {
//                            
//                            Rectangle()
//                                .fill(.blue.opacity(1))
//                                .animation(.smooth(duration: 0.3), value: revealedCount)
//                            
//                        }
//                        
//                    }
            }
        }
        .padding(12)
        .background(.white)
        .cornerRadius(.large)
        .shadow(radius: 8)
        .padding(.horizontal, 0)
        .task { await animate() } // explicit stepper
    }
    
    @MainActor
    private func step(to n: Int) {
        withAnimation(.smooth(duration: min(0.25, perWordDelay * 0.9))) {
            revealedCount = n
        }
    }
    
    private func animate() async {
        // initial delay
        try? await Task.sleep(nanoseconds: UInt64(startTime * 1_000_000_000))
        // reveal words one-by-one with explicit animation
        for n in 1...words.count {
            await MainActor.run { step(to: n) }
            try? await Task.sleep(nanoseconds: UInt64(perWordDelay * 1_000_000_000))
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            
            BlurWordAnimationView(
                text: "The history of software development is filled with fascinating breakthroughs and frustrating missteps, and nowhere is that more evident than in the shift from monolithic systems to distributed architectures. In the early days, programs were written as massive blocks of logic running on a single machine, which made them relatively easy to reason about but nearly impossible to scale. As the demand for connected applications grew, engineers began exploring. The history of software development is filled with fascinating breakthroughs and frustrating missteps, and nowhere is that more evident than in the shift from monolithic systems to distributed architectures. In the early days, programs were written as massive blocks of logic running on a single machine, which made them relatively easy to reason about but nearly impossible to scale. As the demand for connected applications grew, engineers began exploring. The history of software development is filled with fascinating breakthroughs and frustrating missteps, and nowhere is that more evident than in the shift from monolithic systems to distributed architectures. In the early days, programs were written as massive blocks of logic running on a single machine, which made them relatively easy to reason about but nearly impossible to scale. As the demand for connected applications grew, engineers began exploring.",
                textSize: 16,
                perWordDelay: 0.011,
                startTime: 0.3
            )
            
        }
        .padding()
    }
}
