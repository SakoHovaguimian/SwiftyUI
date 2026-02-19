//
//  RemoteImagePipeline.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/18/26.
//

import ImageIO
import CryptoKit
import Foundation
import UIKit

actor RemoteImagePipeline {
    
    static let shared = RemoteImagePipeline()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCache = DiskImageCache.shared
    
    // The dictionary that prevents redundant simultaneous downloads
    private var inFlightTasks: [String: Task<UIImage?, Never>] = [:]
    
    private init() {
        
        let limitMB = ImageCacheConfiguration.shared.maxMemoryCostLimitMB
        self.memoryCache.totalCostLimit = limitMB * 1024 * 1024
        
    }
    
    // MARK: - Public API
    
    func image(for url: URL, targetSize: CGSize, scale: CGFloat = UIScreen.main.scale) async -> UIImage? {
        
        let width = Int(targetSize.width * scale)
        let height = Int(targetSize.height * scale)
        let cacheKey = "\(url.absoluteString)|w=\(width)|h=\(height)"
        
        // 1. Memory
        if let cached = self.memoryCache.object(forKey: cacheKey as NSString) {
            return cached
        }
        
        // 2. Coalesce: If a task is already running for this exact image, await it
        if let existingTask = self.inFlightTasks[cacheKey] {
            return await existingTask.value
        }
        
        // 3. Disk & Network
        // FIX: We use a detached task so the download isn't cancelled if a single view disappears.
        // This ensures the cache still gets primed for the next view that asks for it.
        let task = Task.detached(priority: .userInitiated) { () -> UIImage? in
            
            if let diskData = await DiskImageCache.shared.readData(forKey: cacheKey),
               let diskImage = UIImage(data: diskData) {
                
                await self.cacheInMemory(diskImage, forKey: cacheKey)
                return diskImage
                
            }
            
            do {
                
                let request = URLRequest(url: url)
                let (data, _) = try await URLSession.shared.data(for: request)
                
                let maxPixel = Int(max(targetSize.width, targetSize.height) * scale)
                
                guard let downsampled = self.downsampleImage(data: data, maxPixelSize: maxPixel) else {
                    return nil
                }
                
                await self.cacheInMemory(downsampled, forKey: cacheKey)
                
                // FIX: Preserve alpha channels for PNGs, default to JPEG for everything else
                let isPNG = url.pathExtension.lowercased() == "png"
                
                if isPNG, let pngData = downsampled.pngData() {
                    await DiskImageCache.shared.writeData(pngData, forKey: cacheKey)
                } else if let jpegData = downsampled.jpegData(compressionQuality: 0.9) {
                    await DiskImageCache.shared.writeData(jpegData, forKey: cacheKey)
                }
                
                return downsampled
                
            } catch {
                return nil
            }
            
        }
        
        self.inFlightTasks[cacheKey] = task
        
        defer { self.inFlightTasks[cacheKey] = nil }
        
        return await task.value
        
    }
    
    // MARK: - Helpers
    
    private func cacheInMemory(_ image: UIImage, forKey key: String) {
        
        let cost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        self.memoryCache.setObject(image, forKey: key as NSString, cost: cost)
        
    }
    
    nonisolated private func downsampleImage(data: Data, maxPixelSize: Int) -> UIImage? {
        
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false
        ]
        
        guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
            return nil
        }
        
        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true
        ]
        
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions as CFDictionary) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
        
    }
    
}
