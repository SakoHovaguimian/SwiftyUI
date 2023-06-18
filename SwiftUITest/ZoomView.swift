//
//  ZoomView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/15/23.
//

import SwiftUI

public struct ZoomView: View {
    
    let image: Image
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    
    @State private var offset: CGPoint = .zero
    @State private var lastTranslation: CGSize = .zero
    
    public init(image: Image) {
        self.image = image
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                self.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(self.scale)
                    .offset(x: self.offset.x, y: self.offset.y)
                    .gesture(self.makeDragGesture(size: proxy.size))
                    .gesture(self.makeMagnificationGesture(size: proxy.size))
//                    .cornerRadius(23)
//                    .shadow(color: .pink, radius: 11)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    private func makeMagnificationGesture(size: CGSize) -> some Gesture {
        
        MagnificationGesture()
            .onChanged { value in
                let delta = value / self.lastScale
                self.lastScale = value
                
                // To minimize jittering
                if abs(1 - delta) > 0.01 {
                    self.scale *= delta
                }
            }
            .onEnded { _ in
                self.lastScale = 1
                if self.scale < 1 {
                    withAnimation {
                        self.scale = 1
                    }
                }
                adjustMaxOffset(size: size)
            }
        
    }
    
    private func makeDragGesture(size: CGSize) -> some Gesture {
        
        DragGesture()
            .onChanged { value in
                let diff = CGPoint(
                    x: value.translation.width - self.lastTranslation.width,
                    y: value.translation.height - self.lastTranslation.height
                )
                self.offset = .init(x: self.offset.x + diff.x, y: self.offset.y + diff.y)
                self.lastTranslation = value.translation
            }
            .onEnded { _ in
                adjustMaxOffset(size: size)
            }
        
    }
    
    private func adjustMaxOffset(size: CGSize) {
        
        let maxOffsetX = (size.width * (self.scale - 1)) / 2
        let maxOffsetY = (size.height * (self.scale - 1)) / 2
        
        var newOffsetX = self.offset.x
        var newOffsetY = self.offset.y
        
        if abs(newOffsetX) > maxOffsetX {
            newOffsetX = maxOffsetX * (abs(newOffsetX) / newOffsetX)
        }
        if abs(newOffsetY) > maxOffsetY {
            newOffsetY = maxOffsetY * (abs(newOffsetY) / newOffsetY)
        }
        
        let newOffset = CGPoint(x: newOffsetX, y: newOffsetY)
        if newOffset != self.offset {
            withAnimation {
                self.offset = newOffset
            }
        }
        self.lastTranslation = .zero
    }
    
}
