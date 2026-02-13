//
//  StrokeModifier.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/12/26.
//

import SwiftUI

extension View {
    
    func stroke(color: Color,
                width: CGFloat = 1) -> some View {
        
        modifier(
            StrokeModifier(
                strokeSize: width,
                strokeColor: color
            )
        )
        
    }
    
}

struct StrokeModifier: ViewModifier {
    
    private let id = UUID()
    
    var strokeSize: CGFloat = 1
    var strokeColor: Color = .blue

    func body(content: Content) -> some View {
        if strokeSize > 0 {
            appliedStrokeBackground(content: content)
        } else {
            content
        }
    }

    private func appliedStrokeBackground(content: Content) -> some View {
        content
            .padding(strokeSize*2)
            .background(
                Rectangle()
                    .foregroundColor(strokeColor)
                    .mask(alignment: .center) {
                        mask(content: content)
                    }
            )
    }

    func mask(content: Content) -> some View {
        
        Canvas { context, size in
            
            context.addFilter(.alphaThreshold(min: 0.01))
            
            if let resolvedView = context.resolveSymbol(id: id) {
                context.draw(resolvedView, at: .init(x: size.width/2, y: size.height/2))
            }
            
        } symbols: {
            
            content
                .tag(id)
                .blur(radius: strokeSize)
            
        }
        
    }
    
}

#Preview {
    
    @Previewable @State var width: CGFloat = 1
    
    AppBaseView {
        
        VStack(spacing: 32) {
            
            Text("GlowPro")
                .font(.largeTitle)
                .foregroundStyle(.white)
                .stroke(color: .black, width: width)
            
            Text("🦧")
                .font(.largeTitle)
                .foregroundStyle(.white)
                .stroke(color: .black, width: width)
            
            Image(systemName: "house.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top, 2)
//                .clipShape(.rect(cornerRadius: 12))
                .foregroundStyle(.white)
                .stroke(color: .black, width: width)
            
            Slider(value: $width, in: 0...10)
            
        }
        .animation(.bouncy, value: width)
        .padding(.horizontal, .large)
        
    }
    
}
