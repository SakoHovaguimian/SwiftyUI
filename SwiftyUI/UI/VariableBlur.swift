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
                .padding(.bottom, 8)
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
