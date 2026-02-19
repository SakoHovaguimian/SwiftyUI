//
//  DiskImageCache.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/18/26.
//

import ImageIO
import CryptoKit
import Foundation

actor DiskImageCache {
    
    static let shared = DiskImageCache()
    
    private let fileManager = FileManager.default
    
    // Convert days from configuration into seconds
    private var maxAge: TimeInterval {
        return TimeInterval(ImageCacheConfiguration.shared.maxDiskAgeDays * 24 * 60 * 60)
    }
    
    // Directory in Library/Caches where we store disk images
    private lazy var directoryURL: URL = {
        
        let baseURL = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? self.fileManager.temporaryDirectory
        
        let dir = baseURL.appendingPathComponent("DownsampledImageCache", isDirectory: true)
        
        if self.fileManager.fileExists(atPath: dir.path) == false {
            try? self.fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        
        return dir
        
    }()
    
    private init() {
        
        Task {
            await self.cleanExpiredFiles()
        }
        
    }
    
    // MARK: - Public API
    
    func readData(forKey key: String) -> Data? {
        
        let fileURL = self.fileURL(forKey: key)
        
        guard self.fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        return try? Data(contentsOf: fileURL)
        
    }
    
    func writeData(_ data: Data, forKey key: String) {
        
        let fileURL = self.fileURL(forKey: key)
        
        do {
            
            try data.write(to: fileURL, options: [.atomic])
            
        } catch {
            // print("Disk cache write error: \(error)")
        }
        
    }
    
    func clearAll() {
        
        do {
            
            if self.fileManager.fileExists(atPath: self.directoryURL.path) {
                try self.fileManager.removeItem(at: self.directoryURL)
            }
            
            try self.fileManager.createDirectory(
                at: self.directoryURL,
                withIntermediateDirectories: true
            )
            
        } catch {
            // print("Disk cache clear error: \(error)")
        }
        
    }
    
    // MARK: - Expiration Logic
    
    private func cleanExpiredFiles() {
        
        guard let fileURLs = try? self.fileManager.contentsOfDirectory(
            at: self.directoryURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        ) else {
            return
        }
        
        let expirationDate = Date().addingTimeInterval(-self.maxAge)
        
        for fileURL in fileURLs {
            
            do {
                
                let resourceValues = try fileURL.resourceValues(forKeys: [.contentModificationDateKey])
                
                if let modificationDate = resourceValues.contentModificationDate,
                   modificationDate < expirationDate {
                    
                    try self.fileManager.removeItem(at: fileURL)
                    
                }
                
            } catch {
                // print("Failed to remove expired file: \(error)")
            }
            
        }
        
    }
    
    // MARK: - Helpers
    
    private func fileURL(forKey key: String) -> URL {
        
        let hash = SHA256.hash(data: Data(key.utf8))
        let hexString = hash.compactMap { String(format: "%02x", $0) }.joined()
        
        return self.directoryURL
            .appendingPathComponent(hexString)
            .appendingPathExtension("jpg")
        
    }
    
}
