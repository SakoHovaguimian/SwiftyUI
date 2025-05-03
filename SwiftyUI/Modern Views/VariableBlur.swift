//
//  VariableBlur.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/25.
//

import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins
import QuartzCore

public enum VariableBlurDirection {
    
    case top
    case bottom
    
}

public struct VariableBlurView: UIViewRepresentable {
    
    var maxBlurRadius: CGFloat = 20
    var direction: VariableBlurDirection = .top
    var startOffset: CGFloat = 0
    
    init(maxBlurRadius: CGFloat = 20,
         direction: VariableBlurDirection = .top,
         startOffset: CGFloat = 0) {
        
        self.maxBlurRadius = maxBlurRadius
        self.direction = direction
        self.startOffset = startOffset
        
    }
    
    public func makeUIView(context: Context) -> VariableBlurUIView {
        
        VariableBlurUIView(
            maxBlurRadius: maxBlurRadius,
            direction: direction,
            startOffset: startOffset
        )
        
    }
    
    public func updateUIView(_ uiView: VariableBlurUIView, context: Context) {}
    
}

open class VariableBlurUIView: UIVisualEffectView {
    
    public init(maxBlurRadius: CGFloat = 20,
                direction: VariableBlurDirection = .top,
                startOffset: CGFloat = 0) {
        
        super.init(effect: UIBlurEffect(style: .regular))
        
        // `CAFilter` is a private QuartzCore class that dynamically create using Objective-C runtime.
        guard let CAFilter = NSClassFromString("CAFilter")! as? NSObject.Type else {
            
            print("[VariableBlur] Error: Can't find CAFilter class")
            return
            
        }
        
        guard let variableBlur = CAFilter.self.perform(NSSelectorFromString("filterWithType:"), with: "variableBlur").takeUnretainedValue() as? NSObject else {
            
            print("[VariableBlur] Error: CAFilter can't create filterWithType: variableBlur")
            return
            
        }
        
        // The blur radius at each pixel depends on the alpha value of the corresponding pixel in the gradient mask.
        // An alpha of 1 results in the max blur radius, while an alpha of 0 is completely unblurred.
        let gradientImage = makeGradientImage(startOffset: startOffset, direction: direction)
        
        variableBlur.setValue(maxBlurRadius, forKey: "inputRadius")
        variableBlur.setValue(gradientImage, forKey: "inputMaskImage")
        variableBlur.setValue(true, forKey: "inputNormalizeEdges")
        
        // We use a `UIVisualEffectView` here purely to get access to its `CABackdropLayer`,
        // which is able to apply various, real-time CAFilters onto the views underneath.
        let backdropLayer = subviews.first?.layer
        
        // Replace the standard filters (i.e. `gaussianBlur`, `colorSaturate`, etc.) with only the variableBlur.
        backdropLayer?.filters = [variableBlur]
        
        // Get rid of the visual effect view's dimming/tint view, so we don't see a hard line.
        for subview in subviews.dropFirst() {
            subview.alpha = 0
        }
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func didMoveToWindow() {
        
        // fixes visible pixelization at unblurred edge (https://github.com/nikstar/VariableBlur/issues/1)
        guard let window, let backdropLayer = subviews.first?.layer else { return }
        backdropLayer.setValue(window.screen.scale, forKey: "scale")
        
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // `super.traitCollectionDidChange(previousTraitCollection)` crashes the app
    }
    
    private func makeGradientImage(width: CGFloat = 100,
                                   height: CGFloat = 100,
                                   startOffset: CGFloat,
                                   direction: VariableBlurDirection) -> CGImage {
        
        let ciGradientFilter =  CIFilter.linearGradient()
        ciGradientFilter.color0 = CIColor.black
        ciGradientFilter.color1 = CIColor.clear
        ciGradientFilter.point0 = CGPoint(x: 0, y: height)
        ciGradientFilter.point1 = CGPoint(x: 0, y: startOffset * height)
        
        if case .top = direction {
            
            ciGradientFilter.point0.y = 0
            ciGradientFilter.point1.y = height - ciGradientFilter.point1.y
            
        }
        
        return CIContext()
            .createCGImage(
                ciGradientFilter.outputImage!,
                from: CGRect(
                    x: 0,
                    y: 0,
                    width: width,
                    height: height
                ))!
        
    }
    
}

#Preview {
    
    Image(.image4)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 300, height: 200)
        .overlay(alignment: .bottom) {
            
            Text("Blur View")
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.top, 32)
                .padding(.bottom, 16)
                .background {
                    
                    LinearGradient(
                        colors: [
                            .blue.opacity(1),
                            .blue.opacity(0.01)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    
                }
            
        }
        .cornerRadius(.medium)
    
}

#Preview {
    
    AppBaseView {
        
        ScrollView {
            
            Rectangle()
                .fill(.darkBlue)
                .frame(height: 400)
            
            Rectangle()
                .fill(.mint)
                .frame(height: 400)
            
            Rectangle()
                .fill(.yellow)
                .frame(height: 400)
            
        }
        .safeAreaInset(edge: .bottom) {
            
            Text("Blur View")
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.top, 32)
                .padding(.bottom, 120)
                .background {
                    
                    LinearGradient(
                        colors: [
                            .indigo.opacity(1),
                            .clear
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .blur(radius: 1)
                    
                }
            
        }
        
    }
    .ignoresSafeArea()
    
}

#Preview {
    
    VStack(alignment: .leading, spacing: 8) {
        
        BlurImageItemView(
            title: "New Track #1",
            image: Image(.image3)
        )
        
        BlurImageItemView(
            title: "New Track #2",
            image: Image(.image2)
        )
        
        BlurImageItemView(
            title: "New Track #3",
            image: Image(.image1)
        )
        
        BlurImageItemView(
            title: "New Track #4",
            image: Image(.image4)
        )
        
    }
    
}

fileprivate struct BlurImageItemView: View {
    
    let title: String
    let image: Image
    
    var body: some View {
        
        HStack {
            
            self.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(.extraSmall)
                .frame(width: 120, height: 80)
            
            Text(self.title)
                .appFont(with: .header(.h10))
                .foregroundStyle(.white)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .backgroundImageBlur(self.image)
        .cornerRadius(.small)
        .padding(.horizontal, 32)
        
    }
    
}

struct BackgroundImageBlurViewModifier: ViewModifier {
    
    let image: Image
    let radius: CGFloat
    
    init(image: Image,
         radius: CGFloat = 18) {
        
        self.image = image
        self.radius = radius
        
    }
    
    func body(content: Content) -> some View {
    
        content
            .background {
                
                self.image
                    .resizable()
                    .blur(radius: self.radius)
                
            }
        
    }
    
}

extension View {
    
    public func backgroundImageBlur(_ image: Image,
                                    radius: CGFloat = 18) -> some View {
        
        modifier(BackgroundImageBlurViewModifier(
            image: image,
            radius: radius
        ))
        
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

// SwiftUI usage:
struct VisionColorDemo: View {
    
    let uiImage: UIImage
    @State private var dominant: Color = .clear

    var body: some View {
        
        ZStack {
            
            dominant
                .opacity(0.8)
                .ignoresSafeArea()
            
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .onAppear {
                    
                    if let color = uiImage.averageColor {
                        dominant = Color(color)
                    }
                    
                }
                .cornerRadius(.medium)
                .padding(.horizontal, .large)
            
        }
        
    }
    
}

#Preview {
    
    VisionColorDemo(uiImage: UIImage(named: "image_1")!)
    
}
