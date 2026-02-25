//
//  PatternStyle.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/23/26.
//

// Make more bubble card views
// Dot wave + Geometry is bad


import SwiftUI

// MARK: - 1. Pattern Styles & Configuration
enum PatternStyle: String, CaseIterable {
    case bubbles = "Bubbles"
    case dotWave = "Dot Wave"
    case interlockingRings = "Rings"
    case floatingGeometry = "Geometry"
    case shimmeringDiagonals = "Diagonals"
}

// MARK: - 2. The Reusable Component
struct PatternCardView<Content: View>: View {
    let style: PatternStyle
    let colors: [Color]
    let isAnimating: Bool
    let speed: Double
    let scale: Double
    let content: Content
    
    init(
        style: PatternStyle,
        colors: [Color] = [Color.blue, Color.purple],
        isAnimating: Bool = true,
        speed: Double = 1.0,
        scale: Double = 1.0,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.colors = colors
        self.isAnimating = isAnimating
        self.speed = speed
        self.scale = scale
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            
            // Pattern Layer
            GeometryReader { geo in
                Group {
                    switch style {
                    case .bubbles:
                        BubblesPattern(isAnimating: isAnimating, speed: speed, scale: scale, geo: geo)
                    case .dotWave:
                        DotWavePattern(isAnimating: isAnimating, speed: speed, scale: scale, geo: geo)
                    case .interlockingRings:
                        InterlockingRingsPattern(isAnimating: isAnimating, scale: scale, geo: geo)
                    case .floatingGeometry:
                        FloatingGeometryPattern(isAnimating: isAnimating, speed: speed, scale: scale, geo: geo)
                    case .shimmeringDiagonals:
                        ShimmeringDiagonalsPattern(isAnimating: isAnimating, speed: speed, scale: scale, geo: geo)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
            }
            
            // Card Content
            content
                .padding(24)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: - 3. Individual Pattern Implementations

struct BubblesPattern: View {
    var isAnimating: Bool
    var speed: Double
    var scale: Double
    var geo: GeometryProxy
    
    let configs = [
        (size: 300.0, ox: 100.0, oy: -100.0, dx: 40.0, dy: -40.0),
        (size: 200.0, ox: -120.0, oy: 120.0, dx: -30.0, dy: 50.0),
        (size: 150.0, ox: 50.0, oy: 150.0, dx: -50.0, dy: -20.0)
    ]
    
    var body: some View {
        ZStack {
            ForEach(0..<configs.count, id: \.self) { i in
                let conf = configs[i]
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: conf.size * scale, height: conf.size * scale)
                    .offset(
                        x: conf.ox + (isAnimating ? conf.dx : 0),
                        y: conf.oy + (isAnimating ? conf.dy : 0)
                    )
                    .animation(
                        .easeInOut(duration: (i % 2 == 0 ? 5.0 : 7.0) / speed)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .position(x: geo.size.width / 2, y: geo.size.height / 2)
    }
}

struct DotWavePattern: View {
    var isAnimating: Bool
    var speed: Double
    var scale: Double
    var geo: GeometryProxy
    
    let columns = 20
    let rows = 12
    let spacing: CGFloat = 12
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<columns, id: \.self) { col in
                VStack(spacing: spacing) {
                    ForEach(0..<rows, id: \.self) { row in
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 6 * scale, height: 6 * scale)
                            .offset(y: isAnimating ? -15 : 15)
                            .animation(
                                .easeInOut(duration: 1.2 / speed)
                                .repeatForever(autoreverses: true)
                                .delay(Double(col) * 0.08), // Ripple delay across columns
                                value: isAnimating
                            )
                    }
                }
            }
        }
        .position(x: geo.size.width / 2, y: geo.size.height / 2)
        .rotationEffect(.degrees(-10))
    }
}

struct FloatingGeometryPattern: View {
    var isAnimating: Bool
    var speed: Double
    var scale: Double
    var geo: GeometryProxy
    
    var body: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { i in
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.2), lineWidth: 3)
                    .frame(width: (i % 2 == 0 ? 40 : 60) * scale, height: (i % 2 == 0 ? 40 : 60) * scale)
                    .rotationEffect(.degrees(isAnimating ? (i % 2 == 0 ? 360 : -360) : 0))
                    .offset(
                        x: CGFloat.random(in: -geo.size.width/2...geo.size.width/2) + (isAnimating ? CGFloat.random(in: -30...30) : 0),
                        y: CGFloat.random(in: -geo.size.height/2...geo.size.height/2) + (isAnimating ? CGFloat.random(in: -50...50) : 0)
                    )
                    .animation(
                        .linear(duration: Double.random(in: 10...20) / speed)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
        }
        .position(x: geo.size.width / 2, y: geo.size.height / 2)
    }
}

struct ShimmeringDiagonalsPattern: View {
    var isAnimating: Bool
    var speed: Double
    var scale: Double
    var geo: GeometryProxy
    
    var body: some View {
        HStack(spacing: 20 * scale) {
            ForEach(0..<30, id: \.self) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 10 * scale, height: geo.size.height * 2)
                    .offset(y: isAnimating ? -100 : 100)
                    .animation(
                        .linear(duration: 3.0 / speed)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
        }
        .rotationEffect(.degrees(45))
        .position(x: geo.size.width / 2, y: geo.size.height / 2)
    }
}

struct InterlockingRingsPattern: View {
    var isAnimating: Bool
    var scale: Double
    var geo: GeometryProxy
    
    var body: some View {
        Canvas { context, size in
            let radius: CGFloat = 35 * scale
            let step = radius * 1.5
            
            for x in stride(from: -radius, to: size.width + radius, by: step) {
                for y in stride(from: -radius, to: size.height + radius, by: step) {
                    let rowOffset = (Int(y / step) % 2 == 0) ? 0 : (step / 2)
                    let path = Path(ellipseIn: CGRect(x: x + rowOffset, y: y, width: radius * 2, height: radius * 2))
                    context.stroke(path, with: .color(.white.opacity(0.15)), lineWidth: 1.5 * scale)
                }
            }
        }
        // A subtle breathing effect for the static canvas
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: isAnimating)
    }
}

// MARK: - 4. The Showcase Dashboard
struct PatternShowcaseDashboard: View {
    @State private var selectedPattern: PatternStyle = .dotWave
    @State private var isAnimating = true
    @State private var speed: Double = 1.0
    @State private var patternScale: Double = 1.0
    
    // Sample color palettes
    let palettes: [[Color]] = [
        [Color(red: 0.42, green: 0.50, blue: 0.97), Color(red: 0.33, green: 0.40, blue: 0.96)], // Blue
        [Color.orange, Color.red],
        [Color.mint, Color.teal],
        [Color.purple, Color.indigo]
    ]
    @State private var colorIndex = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                
                // --- Preview Card ---
                PatternCardView(
                    style: selectedPattern,
                    colors: palettes[colorIndex],
                    isAnimating: isAnimating,
                    speed: speed,
                    scale: patternScale
                ) {
                    // Example content inside the reusable card
                    VStack(alignment: .leading, spacing: 20) {
                        Image(systemName: "wand.and.stars")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                        
                        Text("Make Boring\nCards Great")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack {
                            Text("18% Growth")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(palettes[colorIndex][1])
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(12)
                            
                            Spacer()
                            
                            Button(action: {
                                colorIndex = (colorIndex + 1) % palettes.count
                            }) {
                                Image(systemName: "paintpalette.fill")
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 300)
                .padding(.horizontal)
                .shadow(color: palettes[colorIndex][1].opacity(0.3), radius: 15, y: 10)
                
                // --- Dashboard Controls ---
                VStack(spacing: 20) {
                    // Pattern Picker
                    Picker("Pattern", selection: $selectedPattern) {
                        ForEach(PatternStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Animate Patterns", isOn: $isAnimating)
                        .font(.headline)
                    
                    VStack(alignment: .leading) {
                        Text("Animation Speed (\(speed, specifier: "%.1f")x)").font(.subheadline).foregroundColor(.secondary)
                        Slider(value: $speed, in: 0.2...3.0)
                            .disabled(!isAnimating)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Pattern Scale (\(patternScale, specifier: "%.1f")x)").font(.subheadline).foregroundColor(.secondary)
                        Slider(value: $patternScale, in: 0.5...2.5)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(20)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Pattern Dashboard")
        }
    }
}

#Preview {
    PatternShowcaseDashboard()
}
