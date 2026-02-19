//
//  CachedAsyncImage.swift
//  GlowPro
//
//  Created by AI on 11/6/25.
//

import SwiftUI
import ImageIO
import CryptoKit
import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - SwiftUI View Interface

fileprivate enum ImageLoadState: Equatable {
    case loading
    case thumbnail(UIImage)
    case loaded(UIImage)
}

public struct CachedAsyncImage<Placeholder: View>: View {
    
    let url: URL
    let thumbnailURL: URL?
    let targetSize: CGSize
    let scale: CGFloat
    let contentMode: ContentMode
    let placeholder: Placeholder
    
    @State private var state: ImageLoadState = .loading
    
    public init(
        url: URL,
        thumbnailURL: URL? = nil,
        targetSize: CGSize,
        scale: CGFloat = UIScreen.main.scale,
        contentMode: ContentMode = .fill,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.targetSize = targetSize
        self.scale = scale
        self.contentMode = contentMode
        self.placeholder = placeholder()
        
    }
    
    public var body: some View {
        
        ZStack {
            
            switch self.state {
                
            case .loading:
                self.placeholder
                
            case .thumbnail(let uiImage):
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: self.contentMode)
                    .blur(radius: 10)
                    .clipped()
                    .opacity(0.8)
                
            case .loaded(let uiImage):
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: self.contentMode)
                    .clipped()
                    .transition(.opacity)
                
            }
            
        }
        .animation(.easeIn(duration: 0.3), value: self.state)
        .task(id: self.cacheKey) {
            await self.load()
        }
        
    }
    
    private var cacheKey: String {
        
        let width = Int(self.targetSize.width * self.scale)
        let height = Int(self.targetSize.height * self.scale)
        
        return "\(self.url.absoluteString)|w=\(width)|h=\(height)"
        
    }
    
    @MainActor
    private func load() async {
        
        if let thumbURL = self.thumbnailURL {
            
            Task {
                
                let thumbSize = CGSize(width: 30, height: 30)
                
                if let thumbImage = await RemoteImagePipeline.shared.image(for: thumbURL, targetSize: thumbSize) {
                    
                    if self.state == .loading {
                        self.state = .thumbnail(thumbImage)
                    }
                    
                }
                
            }
            
        }
        
        if let fullImage = await RemoteImagePipeline.shared.image(for: self.url, targetSize: self.targetSize) {
            
            if Task.isCancelled { return }
            
            self.state = .loaded(fullImage)
            
        }
        
    }
    
}

// MARK: - Previews

#Preview {
    ScrollView {
        VStack(spacing: 40) {
            
            // Example 1: Standard usage with simple placeholder
            VStack(alignment: .leading) {
                Text("Standard Load").font(.headline)
                CachedAsyncImage(
                    url: URL(string: "https://picsum.photos/600/600?random=1")!,
                    targetSize: CGSize(width: 300, height: 300)
                ) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(ProgressView())
                }
                .frame(width: 300, height: 300)
                .cornerRadius(12)
            }
            
            // Example 2: With a Thumbnail Blur-hash simulation
            // In reality, thumbnailURL would point to a highly compressed, tiny file on your server
            VStack(alignment: .leading) {
                Text("With Blur-hash Thumbnail").font(.headline)
                CachedAsyncImage(
                    url: URL(string: "https://picsum.photos/600/600?random=2")!,
                    thumbnailURL: URL(string: "https://picsum.photos/30/30?random=2")!,
                    targetSize: CGSize(width: 300, height: 300)
                ) {
                    Color.clear
                }
                .frame(width: 300, height: 300)
                .cornerRadius(12)
            }
            
            // Example 3: Small Avatar
            VStack(alignment: .leading) {
                Text("Small Avatar").font(.headline)
                CachedAsyncImage(
                    url: URL(string: "https://picsum.photos/200/200?random=3")!,
                    targetSize: CGSize(width: 50, height: 50)
                ) {
                    Circle().fill(Color.blue.opacity(0.2))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            }
            
        }
        .padding()
    }
}
