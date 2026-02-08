import SwiftUI

// MARK: - 1. THE PHYSICS ENGINE (Haptics)
class TitanEngine {
    static let shared = TitanEngine()
    private var heavy = UIImpactFeedbackGenerator(style: .heavy)
    private var rigid = UIImpactFeedbackGenerator(style: .rigid)
    private var soft = UIImpactFeedbackGenerator(style: .soft)
    
    func prepare() {
        heavy.prepare()
        rigid.prepare()
        soft.prepare()
    }
    
    func playRipTexture() {
        // High frequency, low amplitude to simulate tearing foil
        rigid.impactOccurred(intensity: 0.7)
    }
    
    func playSnap() {
        heavy.impactOccurred(intensity: 1.0)
    }
    
    func playCardFlip() {
        soft.impactOccurred(intensity: 0.8)
    }
    
    func playHoloShimmer() {
        // Subtle vibration for the rare card
        soft.impactOccurred(intensity: 0.4)
    }
}

// MARK: - 2. VISUAL SHADERS & STYLES

// A. Liquid Metal Shader (Simulates brushed steel/titanium)
struct LiquidMetal: View {
    // This simulates light hitting a brushed cylinder
    let texture = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(white: 0.3), location: 0.0),
            .init(color: Color(white: 0.8), location: 0.2), // Highlight
            .init(color: Color(white: 0.4), location: 0.3),
            .init(color: Color(white: 0.7), location: 0.45),
            .init(color: Color(white: 0.9), location: 0.5), // Specular pop
            .init(color: Color(white: 0.7), location: 0.55),
            .init(color: Color(white: 0.4), location: 0.7),
            .init(color: Color(white: 0.8), location: 0.9), // Edge light
            .init(color: Color(white: 0.2), location: 1.0)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        texture
            .overlay(
                // Micro-scratches for realism
                HStack(spacing: 1) {
                    ForEach(0..<80, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.black.opacity(Double.random(in: 0.02...0.1)))
                            .frame(width: Double.random(in: 0.5...2))
                        Spacer()
                    }
                }
            )
    }
}

// B. Gold Foil (Fixed to be a Property for ShapeStyle usage)
var goldFoilBorder: LinearGradient {
    LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.85, green: 0.65, blue: 0.13), // Dark Gold
            Color(red: 1.0, green: 0.9, blue: 0.5),    // Bright Gold
            Color(red: 0.85, green: 0.65, blue: 0.13), // Dark Gold
            Color(red: 0.6, green: 0.4, blue: 0.0)     // Shadow Gold
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// C. ZigZag Shape (Fixed)
struct ZigZagLine: Shape {
    var toothDepth: CGFloat = 10
    var toothWidth: CGFloat = 15
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Calculate number of teeth
        let count = Int(rect.width / toothWidth)
        
        // Draw the jagged top edge
        for i in 0...count {
            let x = CGFloat(i) * toothWidth
            path.addLine(to: CGPoint(x: x + (toothWidth / 2), y: toothDepth))
            path.addLine(to: CGPoint(x: x + toothWidth, y: 0))
        }
        
        // Close the box
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - 3. AGGRESSIVE PRISMATIC HOLO
struct AggressiveHolo: View {
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base Rainbow
                AngularGradient(
                    gradient: Gradient(colors: [.red, .blue, .purple, .green, .yellow, .red]),
                    center: .center
                )
                .saturation(2.0) // Oversaturate
                .blur(radius: 10)
                .opacity(0.6)
                
                // The "Beam" of light
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .white.opacity(0.9), .clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 150)
                    .rotationEffect(.degrees(25))
                    .offset(x: shimmerOffset)
            }
            // THIS blend mode creates the "burning" metallic look
            .blendMode(.colorDodge)
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    shimmerOffset = geo.size.width + 200
                }
            }
        }
    }
}

// MARK: - 4. THE RIPPER (Tear Strip)
struct TitaniumTearStrip: View {
    var width: CGFloat
    var onComplete: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isCompleted = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Dark Void Behind
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.8))
                .frame(height: 54)
                .padding(.horizontal, 2)
            
            // The Metal Strip
            LiquidMetal()
                .frame(width: width, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .mask(
                    HStack(spacing: 0) {
                        // This shrinks as we drag
                        Rectangle().frame(width: max(0, width - dragOffset))
                        Spacer()
                    }
                )
                .shadow(color: .black.opacity(0.5), radius: 5, x: 5, y: 5)
            
            // The Pull Mechanism (Draggable)
            Circle()
                .fill(
                    LinearGradient(colors: [.white, Color(white: 0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(Color(white: 0.5), lineWidth: 1)
                )
                .shadow(radius: 8, x: 0, y: 5)
                .overlay(
                    Image(systemName: "chevron.right.2")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.gray)
                )
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard !isCompleted else { return }
                            let x = value.translation.width
                            
                            // Prevent dragging backwards
                            if x > 0 && x < width {
                                self.dragOffset = x
                                // Aggressive Haptics: Tick every 5 points
                                if Int(x) % 5 == 0 {
                                    TitanEngine.shared.playRipTexture()
                                }
                            }
                        }
                        .onEnded { value in
                            if value.translation.width > width * 0.75 {
                                // SNAP (Success)
                                isCompleted = true
                                TitanEngine.shared.playSnap()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    dragOffset = width + 100
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    onComplete()
                                }
                            } else {
                                // Recoil (Fail)
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.4)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
        }
        .frame(width: width, height: 60)
    }
}

// MARK: - 5. THE MASTER CARD
struct UltraCard: View {
    let index: Int
    let isRare: Bool
    let isFlipped: Bool
    
    var body: some View {
        ZStack {
            // --- BACK OF CARD ---
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.2), .black]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                )
                .overlay(
                    // Tech Pattern
                    VStack(spacing: 5) {
                        ForEach(0..<10, id: \.self) { _ in
                            Rectangle().fill(Color.white.opacity(0.05)).frame(height: 1)
                        }
                    }.rotationEffect(.degrees(45))
                )
                .overlay(
                    // FIX: Using the computed property 'goldFoilBorder'
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(goldFoilBorder, lineWidth: 3)
                )
                .overlay(
                    Text("TITAN\nDECK")
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                )
                .opacity(isFlipped ? 0 : 1)

            // --- FRONT OF CARD ---
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.black)
                
                // Artwork Area
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(colors: [
                            Color(hue: Double(index) * 0.15, saturation: 0.8, brightness: 0.4),
                            Color(hue: Double(index) * 0.15, saturation: 0.8, brightness: 0.1)
                        ], startPoint: .top, endPoint: .bottom)
                    )
                    .padding(8)
                
                // Content
                VStack {
                    Image(systemName: isRare ? "crown.fill" : "suit.diamond.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                        .foregroundColor(.white)
                        .shadow(color: isRare ? .purple : .blue, radius: 20)
                    
                    Text(isRare ? "OMEGA RARE" : "Level \(index + 1)")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding(.top)
                }
                
                // --- HOLO LAYER (Only for Rare) ---
                if isRare {
                    AggressiveHolo()
                        .mask(RoundedRectangle(cornerRadius: 18))
                        .allowsHitTesting(false)
                    
                    // Sparkles
                    Circle()
                        .fill(Color.white)
                        .frame(width: 5, height: 5)
                        .offset(x: 50, y: -50)
                        .blur(radius: 1)
                }
                
                // Gold Border Overlay (The outer one)
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(goldFoilBorder, lineWidth: 6)
            }
            // IMPORTANT: Mirror the front so text is readable when flipped
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .opacity(isFlipped ? 1 : 0)
        }
        .frame(width: 260, height: 380)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0.0, y: 1.0, z: 0.0),
            perspective: 0.6 // Extreme perspective for "in your face" 3D
        )
        .shadow(color: isRare && isFlipped ? .purple.opacity(0.6) : .black.opacity(0.5), radius: isRare ? 30 : 10, y: 10)
    }
}

// MARK: - 6. ORCHESTRATOR
struct UltraPremiumOpening: View {
    @State private var isPackOpen = false
    @State private var currentCard = 0
    @State private var flippedCards: Set<Int> = [] // Tracks which are face up
    @State private var discardedCards: Set<Int> = [] // Tracks which are gone
    
    // Visual FX
    @State private var flashOpacity: Double = 0
    
    let totalCards = 5
    
    var body: some View {
        ZStack {
            // Dark Studio Background
            RadialGradient(
                gradient: Gradient(colors: [Color(white: 0.2), Color.black]),
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            .edgesIgnoringSafeArea(.all)
            
            // --- THE CARDS ---
            // Render logic: Show cards that haven't been swiped away yet
            if isPackOpen || currentCard < totalCards {
                ZStack {
                    ForEach(0..<totalCards, id: \.self) { i in
                        UltraCard(
                            index: i,
                            isRare: i == (totalCards - 1),
                            isFlipped: flippedCards.contains(i)
                        )
                        // STACKING PHYSICS
                        .scaleEffect(i == currentCard ? 1.0 : 0.95)
                        .offset(y: i == currentCard ? 0 : 15)
                        .rotationEffect(.degrees(i == currentCard ? 0 : Double((i * 3) % 6 - 3)))
                        
                        // ENTRANCE ANIMATION (From Pack)
                        .offset(y: isPackOpen ? 0 : 200)
                        
                        // DISCARD ANIMATION (Fly Right)
                        .offset(x: discardedCards.contains(i) ? 500 : 0,
                                y: discardedCards.contains(i) ? -100 : 0)
                        .rotationEffect(.degrees(discardedCards.contains(i) ? 25 : 0))
                        .opacity(discardedCards.contains(i) ? 0 : 1)
                        
                        // Z-INDEX (Reverse order so 0 is on top)
                        .zIndex(Double(totalCards - i))
                        
                        .onTapGesture {
                            handleTap(at: i)
                        }
                    }
                }
                .padding(.bottom, 50)
            }
            
            // --- THE PACK (FOREGROUND) ---
            VStack(spacing: 0) {
                // Top Half
                LiquidMetal()
                    .frame(width: 300, height: 200)
                    .overlay(
                        Text("TITANIUM\nEDITION")
                            .font(.system(size: 30, weight: .black))
                            .foregroundColor(.black.opacity(0.6))
                            .shadow(color: .white.opacity(0.5), radius: 1, x: 1, y: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 10)
                    // Opening Animation
                    .offset(y: isPackOpen ? -400 : 0)
                    .rotation3DEffect(.degrees(isPackOpen ? -30 : 0), axis: (x: 1, y: 0, z: 0))
                
                // Tear Strip
                if !isPackOpen {
                    TitaniumTearStrip(width: 280) {
                        openPack()
                    }
                    .padding(.vertical, -5) // Overlap slightly
                    .zIndex(10)
                }
                
                // Bottom Half
                LiquidMetal()
                    .frame(width: 300, height: 200)
                    .mask(
                        // ZigZag Cut Mask
                        VStack(spacing: 0) {
                            ZigZagLine(toothDepth: 10, toothWidth: 15)
                                .frame(height: 10)
                            Rectangle()
                        }
                    )
                    .shadow(radius: 10)
                    // Opening Animation
                    .offset(y: isPackOpen ? 400 : 0)
                    .rotation3DEffect(.degrees(isPackOpen ? 30 : 0), axis: (x: 1, y: 0, z: 0))
            }
            
            // --- WHITE FLASH ---
            Color.white
                .edgesIgnoringSafeArea(.all)
                .opacity(flashOpacity)
                .allowsHitTesting(false)
            
            // RESET BUTTON
            if currentCard >= totalCards {
                Button(action: reset) {
                    Text("RELOAD DECK")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(LiquidMetal().frame(height: 50).cornerRadius(12))
                }
                .transition(.scale)
                .padding(.top, 400)
            }
        }
        .onAppear { TitanEngine.shared.prepare() }
    }
    
    // MARK: - Logic
    func openPack() {
        // 1. Flash
        withAnimation(.easeIn(duration: 0.1)) { flashOpacity = 1.0 }
        
        // 2. Explode Pack
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            isPackOpen = true
        }
        
        // 3. Fade Flash
        withAnimation(.easeOut(duration: 0.8).delay(0.1)) { flashOpacity = 0.0 }
    }
    
    func handleTap(at index: Int) {
        guard index == currentCard else { return }
        
        if flippedCards.contains(index) {
            // ACTION: Discard (Second Tap)
            TitanEngine.shared.playSnap() // Heavier sound for discard
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                discardedCards.insert(index)
                currentCard += 1
            }
        } else {
            // ACTION: Flip (First Tap)
            TitanEngine.shared.playCardFlip()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                flippedCards.insert(index)
            }
            
            // If Rare, add extra haptic
            if index == (totalCards - 1) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    TitanEngine.shared.playHoloShimmer()
                }
            }
        }
    }
    
    func reset() {
        withAnimation {
            isPackOpen = false
            currentCard = 0
            flippedCards.removeAll()
            discardedCards.removeAll()
        }
    }
}

struct UltraPreview: PreviewProvider {
    static var previews: some View {
        UltraPremiumOpening()
    }
}
