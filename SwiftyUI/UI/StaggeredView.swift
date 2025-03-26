import SwiftUI

// TODO: - Add static methods as styles. PopIn(direction: Top/Bottom)
// TODO: - SLIDE LEFT / RIGHT
// TODO: - OPACITY

struct StaggeredConfig {
    var delay: Double = 0.05
    var maxDelay: Double = 0.4
    var blurRadius: CGFloat = 6
    var offset: CGSize = .init(width: 0, height: 100)
    var scale: CGFloat = 0.95
    var scaleAnchor: UnitPoint = .center
    var animation: Animation = .smooth(duration: 0.3, extraBounce: 0)
    var disappearInSameDirection: Bool = true
    var noDisappearAnimation: Bool = false
    // Add more properties as per your needs!
}

fileprivate struct CustomStaggeredTransition: Transition {
    
    var index: Int
    var config: StaggeredConfig
    
    func body(content: Content, phase: TransitionPhase) -> some View {
        
        let isIdentity: Bool = (phase == .identity)
        let didDisappear: Bool = (phase == .didDisappear)
        
        let x: CGFloat = config.offset.width
        let y: CGFloat = config.offset.height
        
        let reverseX: CGFloat = config.disappearInSameDirection ? x : -x
        let disableX: CGFloat = config.noDisappearAnimation ? 0 : reverseX
        
        let reverseY: CGFloat = config.disappearInSameDirection ? y : -y
        let disableY: CGFloat = config.noDisappearAnimation ? 0 : reverseY
        
        let offsetX = isIdentity ? 0 : (didDisappear ? disableX : x)
        let offsetY = isIdentity ? 0 : (didDisappear ? disableY : y)
        
        return content
            .opacity(isIdentity ? 1 : 0)
            .blur(radius: isIdentity ? 0 : config.blurRadius)
            .compositingGroup()
            .scaleEffect(isIdentity ? 1 : config.scale, anchor: config.scaleAnchor)
            .offset(x: offsetX, y: offsetY)
            .animation(config.animation.delay(Double(index) * config.delay), value: phase)
        
    }
    
}

struct StaggeredView<Content: View>: View {
    var config: StaggeredConfig
    @ViewBuilder var content: Content
    
    var body: some View {
        Group(subviews: content) { collection in
            ForEach(collection.indices, id: \.self) { index in
                collection[index]
                    .transition(CustomStaggeredTransition(index: index, config: config))
            }
        }
    }
}

struct ContentView: View {
    @State private var showView: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    Button("Toggle View") {
                        showView.toggle()
                    }
                    
                    let config = StaggeredConfig(
                        delay: 0,
                        maxDelay: 0,
                        blurRadius: 2,
                        offset: .init(width: 300, height: 0),
                        scale: 1,
                        scaleAnchor: .center,
                        noDisappearAnimation: false
                    )
                    
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                        StaggeredView(config: config) {
                            if showView {
                                ForEach(1...10, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.black.gradient)
                                        .frame(height: 150)
                                }
                            }
                        }
                    }
                    .padding(15)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Staggered View")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
