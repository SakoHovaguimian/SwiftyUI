//
//  ImagePrefetcher.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/18/26.
//

import ImageIO
import CryptoKit
import UIKit

actor ImagePrefetcher {
    
    static let shared = ImagePrefetcher()
    
    private var prefetchTasks: [URL: Task<Void, Never>] = [:]
    
    private init() {}
    
    // MARK: - Public API
    
    func prefetch(urls: [URL], targetSize: CGSize, scale: CGFloat = UIScreen.main.scale) {
        
        for url in urls {
            
            if self.prefetchTasks[url] != nil { continue }
            
            let task = Task(priority: .background) {
                
                _ = await RemoteImagePipeline.shared.image(for: url, targetSize: targetSize, scale: scale)
                
                self.prefetchTasks[url] = nil
                
            }
            
            self.prefetchTasks[url] = task
            
        }
        
    }
    
    func cancelPrefetching(for urls: [URL]) {
        
        for url in urls {
            
            if let task = self.prefetchTasks[url] {
                
                task.cancel()
                self.prefetchTasks[url] = nil
                
            }
            
        }
        
    }
    
    func cancelAll() {
        
        for task in self.prefetchTasks.values {
            task.cancel()
        }
        
        self.prefetchTasks.removeAll()
        
    }
    
}
