//
//  Ext+BlurView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/22/25.
//

import SwiftUI

public enum GradientBlurMask {
    
    /// 0 = very soft; 1 = very harsh
    case preset(GradientBlurMaskPreset)
    
    case harshness(Double)
    case custom([Gradient.Stop])
    
}

public enum GradientBlurHeightStyle: Equatable {
    
    case fixed(CGFloat)
    case dynamic
    
}

public enum GradientDirection {
    
    case topToBottom
    case bottomToTop
    
}

public enum GradientBlurMaskPreset {
    
    case soft
    case medium
    case hard
    
}

public extension View {
    
    func gradientBlur(color: Color = .black,
                      alignment: Alignment = .bottom,
                      gradientDirection: GradientDirection = .topToBottom,
                      mask: GradientBlurMask = .preset(.medium),
                      heightStyle: GradientBlurHeightStyle = .fixed(140),
                      additionalHeightPadding: CGFloat = 8,
                      allowsHitTesting: Bool = false) -> some View {
        
        ZStack(alignment: alignment) {
            
            self
                .overlay(alignment: alignment) {
                    
                    GradientBlurOverlay(
                        color: color,
                        gradientDirection: gradientDirection,
                        mask: mask,
                        heightStyle: heightStyle,
                        additionalHeightPadding: additionalHeightPadding
                    )
                    .allowsHitTesting(allowsHitTesting)
                    
                }
            
        }
        
    }
    
}

fileprivate struct GradientBlurOverlay: View {
    
    let color: Color
    let gradientDirection: GradientDirection
    let mask: GradientBlurMask
    let heightStyle: GradientBlurHeightStyle
    let additionalHeightPadding: CGFloat
    
    @State private var measuredHeight: CGFloat = 0
    
    private var isDynamic: Bool {
        if case .dynamic = heightStyle { return true }
        return false
    }
    
    private var resolvedHeight: CGFloat? {
        switch heightStyle {
        case .fixed(let h):
            return h + additionalHeightPadding
        case .dynamic:
            return nil
        }
    }
    
    private var startPoint: UnitPoint {
        (self.gradientDirection == .topToBottom) ? .top : .bottom
    }
    
    private var endPoint: UnitPoint {
        (self.gradientDirection == .topToBottom) ? .bottom : .top
    }
    
    private var gradientStops: [Gradient.Stop] {
        switch self.mask {
        case .preset(let p): return Self.presetStops(p)
        case .harshness(let h): return Self.harshnessStops(h)
        case .custom(let stops): return stops
        }
    }
    
    private var maskColors: [Color] {
        
        return [
            .black.opacity(0.01),
            .black.opacity(0.4),
            .black.opacity(0.7),
            .black.opacity(1.0)
        ]
        
    }
    
    var body: some View {
        
        Rectangle()
            .fill(self.color)
            .mask(LinearGradient(gradient: Gradient(stops: gradientStops),
                                 startPoint: startPoint,
                                 endPoint: endPoint))
            .compositingGroup()
            .frame(height: self.resolvedHeight ?? nil)
            .compositingGroup()
            
    }
    
    /// Quick presets for “soft / medium / hard” edges.
    private static func presetStops(_ preset: GradientBlurMaskPreset) -> [Gradient.Stop] {
        switch preset {
        case .soft:
            return [
                .init(color: .black.opacity(0.00), location: 0.00),
                .init(color: .black.opacity(0.20), location: 0.35),
                .init(color: .black.opacity(0.55), location: 0.65),
                .init(color: .black.opacity(1.00), location: 1.00)
            ]
        case .medium:
            return [
                .init(color: .black.opacity(0.00), location: 0.00),
                .init(color: .black.opacity(0.30), location: 0.25),
                .init(color: .black.opacity(0.70), location: 0.55),
                .init(color: .black.opacity(1.00), location: 0.85)
            ]
        case .hard:
            return [
                .init(color: .black.opacity(0.00), location: 0.00),
                .init(color: .black.opacity(0.05), location: 0.15),
                .init(color: .black.opacity(0.80), location: 0.35),
                .init(color: .black.opacity(1.00), location: 0.55)
            ]
        }
    }
    
        /// Parametric harshness control:
        /// - `h = 0` very soft (long ramp)
        /// - `h = 1` very harsh (short ramp)
        private static func harshnessStops(_ h: Double) -> [Gradient.Stop] {
            
            let clamped = max(0, min(1, h))
            
            // Map harshness to positions:
            // As harshness increases, push the opaque region earlier and tighten the ramp.
            let a = 0.00                                 // transparent start
            let b = 0.20 - 0.15 * clamped               // early low opacity
            let c = 0.55 - 0.30 * clamped               // mid high opacity
            let d = 0.90 - 0.45 * clamped               // fully opaque start
            
            return [
                .init(color: .black.opacity(0.00), location: a),
                .init(color: .black.opacity(0.25 + 0.20 * clamped), location: b),
                .init(color: .black.opacity(0.60 + 0.30 * clamped), location: c),
                .init(color: .black.opacity(1.00), location: d)
            ]
            
        }
    
}

struct TestVst2: View {
    
    let uiImage: UIImage = UIImage(resource: .image4)
    @State private var extractedColors: [Color] = []
    
    var body: some View {
            
        VStack(spacing: 0) {
            
            Image(.image4)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .gradientBlur(
                    color: extractedColors.first ?? .red,
                    alignment: .bottom,
                    gradientDirection: .topToBottom,
                    mask: .preset(.medium),
                    heightStyle: .fixed(150)
                )
//                .overlay(alignment: .top) {
//                    
//                    Color.clear
//                        .gradientBlur(
//                            color: extractedColors.reversed().first ?? .red,
//                            alignment: .top,
//                            gradientDirection: .bottomToTop,
//                            mask: .preset(.medium),
//                            heightStyle: .fixed(400)
//                        )
//                        .overlay(alignment: .leading) {
//                            
//                            Text("New Album")
//                                .foregroundStyle(.white)
//                                .appFont(with: .header(.h5))
//                                .offset(x: 48, y: -120)
//                            
//                        }
//                        .ignoresSafeArea()
//                    
//                }
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text("This is a test")
                    .foregroundStyle(.white)
                    .appFont(with: .header(.h5))
                
                Text("lorem ipsum dolor sit amet conorem ipsum dolor sit amet conorem ipsum dolor sit amet conorem ipsum dolor sit amet conorem ipsum dolor sit amet conorem ipsum dolor sit amet conorem ipsum dolor sit amet conorem ipsum dolor sit amet conorem ipsum dolor sit amet conorem ipsum dolor sit amet conorem ipsum dolor sit amet consectetur adipisicing elit. Quo, voluptatem! Lorem ipsum")
                    .lineLimit(nil)
                    .foregroundStyle(.white)
                    .appFont(with: .body(.b4))
                
            }
            .padding(.horizontal, .medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(LinearGradient(colors: extractedColors, startPoint: .top, endPoint: .bottom))
            
        }
        .onAppear() {
            extractColor()
        }
        
    }
    
    func extractColor() {
        
        // Heavy work off the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            
            do {
                
                let uiColors = try uiImage.extractColors(
                    numberOfColors: 2,
                    sortByProminence: true
                )
                
                let swiftUIColors = uiColors.map { Color($0) }
                
                DispatchQueue.main.async {
                    extractedColors = swiftUIColors
                }
                
            } catch {
                print("Failed to extract colors:", error)
            }
            
        }
        
    }
    
}

#Preview {
    TestVst2()
}
