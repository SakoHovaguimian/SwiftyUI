//
//  SomeParticle.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/3/25.
//

import SwiftUI

public enum PixelVisual {
    
    public enum ShapeKind {
        
        case circle
        case square
        case rounded(CGFloat)
        
    }
    
    case shape(ShapeKind, Color)
    case image(Image)
    case color(Color)
    
    @ViewBuilder
    public func view(size: CGFloat) -> some View {
        
        switch self {
        case .shape(let kind, let color):
            
            switch kind {
            case .circle:
                Circle().fill(color).frame(width: size, height: size)
                
            case .square:
                Rectangle().fill(color).frame(width: size, height: size)
                
            case .rounded(let radius):
                
                RoundedRectangle(cornerRadius: radius)
                    .fill(color)
                    .frame(width: size, height: size)
            }
            
        case .image(let image):
            
            image
                .resizable()
                .interpolation(.high)
                .frame(width: size, height: size)
            
        case .color(let color):
            Circle().fill(color).frame(width: size, height: size)
        }
        
    }
    
}

public struct Pixel: Identifiable {
    
    public let id: UUID
    public var visual: PixelVisual
    public var position: CGPoint
    public var alpha: Double
    public var size: CGFloat
    
    public init(id: UUID = UUID(),
                visual: PixelVisual,
                position: CGPoint,
                alpha: Double,
                size: CGFloat) {
        
        self.id = id
        self.visual = visual
        self.position = position
        self.alpha = alpha
        self.size = size
        
    }
    
}

public struct PixelRiver: View {
    
    public enum Direction {
        
        case top
        case bottom
        
    }
        
    private let direction: Direction
    private let fadeRange: ClosedRange<Double>
    private let cullThresholdY: CGFloat
    private let animationDuration: Double
    private let spawnInterval: TimeInterval
    private let pixelSize: CGFloat
    
    // MARK: State
    
    @State private var pixels: [Pixel] = []
    
    // MARK: Init
    
    public init(direction: Direction = .top,
                fadeRange: ClosedRange<Double> = 0.3...1.0,
                cullThresholdY: CGFloat = 10,
                animationDuration: Double = 3,
                spawnInterval: TimeInterval = 0.05,
                pixelSize: CGFloat = 10) {
        
        self.direction = direction
        self.fadeRange = fadeRange
        self.cullThresholdY = cullThresholdY
        self.animationDuration = animationDuration
        self.spawnInterval = spawnInterval
        self.pixelSize = pixelSize
        
    }

    // MARK: Body

    public var body: some View {
        
        GeometryReader { geo in
            
            ZStack {
                
                ForEach(pixels) { pixel in
                    
                    pixel.visual
                        .view(size: pixel.size)
                        .position(pixel.position)
                        .opacity(pixel.alpha)
                    
                }
                
            }
            .rotationEffect(.degrees(self.direction == .top ? -180 : 0))
            .drawingGroup()
            .onAppear {
                
                Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { _ in
                    
                    // spawn
                    let color = Color(
                        hue: Double.random(in: 0.1...0.8),
                        saturation: 1,
                        brightness: 1
                    )

                    let startY = UIScreen.main.bounds.height
                    
                    let newPixel = Pixel(
                        visual: .shape(.circle, color),
                        position: CGPoint(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: startY
                        ),
                        alpha: Double.random(in: fadeRange),
                        size: pixelSize
                    )
                    
                    pixels.append(newPixel)

                    // step + fade (uses configurable duration and cull threshold)
                    withAnimation(.linear(duration: animationDuration)) {
                        
                        pixels = pixels
                            .map { p in
                                
                                var next = p
                                next.position.y -= 30 // controls speed of drop
                                next.alpha = 0
                                return next
                                
                            }
                            .filter { $0.position.y > cullThresholdY }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

// MARK: - Preview

#Preview {
    
    PixelRiver(
        direction: .top,
        fadeRange: 0.0...1.0,
        cullThresholdY: 30,
        animationDuration: 5,
        spawnInterval: 0.12,
        pixelSize: 20
    )
    .background(Color.black.ignoresSafeArea())
}


#Preview {
    
    VStack {
        
        Text("Some Test ") +
        Text("[www.google.com](Google.com)") +
        Text(" End")
        
    }
    .environment(\.openURL, .init(handler: { url in
        
        print(url)
        return .handled
        
    }))
    
}
