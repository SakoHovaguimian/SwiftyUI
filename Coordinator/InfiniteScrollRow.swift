import SwiftUI

public struct LogoItem: Identifiable {
    
    public let id: String
    public let imageName: String
    public let backgroundColor: Color
    
    public init(id: String = UUID().uuidString,
                imageName: String,
                backgroundColor: Color) {
        
        self.id = id
        self.imageName = imageName
        self.backgroundColor = backgroundColor
    }
    
}

public struct LogoTileView: View {
    
    private let item: LogoItem
    private let size: CGFloat
    
    public init(item: LogoItem,
                size: CGFloat) {
        
        self.item = item
        self.size = size
        
    }
    
    public var body: some View {
        
        Image(self.item.imageName)
            .resizable()
            .scaledToFit()
            .padding(self.size * 0.22)
            .frame(
                width: self.size,
                height: self.size
            )
            .background(self.item.backgroundColor)
            .clipShape(.rect(cornerRadius: self.size * 0.22))
        
    }
    
}

public struct InfiniteScrollRow: View {
    
    public enum ScrollDirection {
        
        case leftToRight
        case rightToLeft
        
    }
    
    @State private var offset: CGFloat = 0
    @State private var animationStarted = false
    
    private let items: [LogoItem]
    private var itemSize: CGFloat
    private var spacing: CGFloat
    private let speed: Double
    private let direction: ScrollDirection
    
    @Binding private var isPaused: Bool
    
    public init(items: [LogoItem],
                itemSize: CGFloat = 100,
                spacing: CGFloat = 12,
                speed: Double,
                direction: ScrollDirection,
                isPaused: Binding<Bool> = .constant(false)) {
        
        self.items = items
        self.itemSize = itemSize
        self.spacing = spacing
        self.speed = speed
        self.direction = direction
        self._isPaused = isPaused
        
    }

    private var segmentWidth: CGFloat {
        CGFloat(self.items.count) * (self.itemSize + self.spacing)
    }

    private var loopedItems: [LogoItem] {
        self.items + self.items + self.items
    }

    public var body: some View {
        
        HStack(spacing: self.spacing) {
            
            ForEach(Array(self.loopedItems.enumerated()), id: \.offset) { _, item in
                
                LogoTileView(
                    item: item,
                    size: self.itemSize
                )
                
            }
            
        }
        .offset(x: self.offset)
        .frame(height: self.itemSize)
        .mask(self.edgeFadeMask())
        .allowsHitTesting(false)
        .onAppear {
            startAnimationIfNeeded()
        }
        .onChange(of: self.isPaused) { _, newValue in
            
            if !newValue {
                startAnimationIfNeeded()
            }
            
        }
        
    }
    
    private func startAnimationIfNeeded() {
        
        guard !self.animationStarted, !self.isPaused else { return }

        self.animationStarted = true
        self.offset = self.direction == .rightToLeft ? 0 : -self.segmentWidth

        withAnimation(
            .linear(duration: self.segmentWidth / self.speed)
            .repeatForever(autoreverses: false)
        ) {
            self.offset = (self.direction == .rightToLeft)
                ? -self.segmentWidth
                : 0
        }
        
    }
    
    @ViewBuilder
    private func edgeFadeMask() -> some View {
        
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.05),
                .init(color: .black, location: 0.95),
                .init(color: .clear, location: 1)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        
    }
    
}

#Preview {
    
    VStack(spacing: 12) {
        
        InfiniteScrollRow(
            items: [
                .init(imageName: "sparkle", backgroundColor: .red.opacity(0.45)),
                .init(imageName: "sparkle", backgroundColor: .blue.opacity(0.45)),
                .init(imageName: "sparkle", backgroundColor: .green.opacity(0.45)),
                .init(imageName: "sparkle", backgroundColor: .orange.opacity(0.45)),
            ],
            speed: 60,
            direction: .leftToRight
        )
        
        InfiniteScrollRow(
            items: [
                .init(imageName: "sparkle", backgroundColor: .purple.opacity(0.45)),
                .init(imageName: "sparkle", backgroundColor: .yellow.opacity(0.45)),
                .init(imageName: "sparkle", backgroundColor: .pink.opacity(0.45)),
                .init(imageName: "sparkle", backgroundColor: .cyan.opacity(0.45)),
            ],
            speed: 80,
            direction: .rightToLeft
        )
        
    }
    
}
