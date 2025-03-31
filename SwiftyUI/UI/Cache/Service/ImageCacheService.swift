//
//  ImageCacheService.swift
//  FetchTakeHome
//
//  Created by Sako Hovaguimian on 2/13/25.
//

import UIKit

final class ImageCacheService: ImageCacheServiceProtocol {
    
    private let fileManager = FileManager.default
    private var cacheDirectory: URL!
    
    init() {
        setupCacheDirectory()
    }
    
    // MARK: - PUBLIC -
    
    func image(for url: String) -> UIImage? {
        
        let encodedURL = encodeStrategy(url)
        let fileURL = cacheDirectory.appendingPathComponent(encodedURL)
        
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        return UIImage(data: data)
        
    }
    
    func insertImage(_ data: Data?,
                     for url: String) {
        
        let encodedURL = encodeStrategy(url)
        let fileURL = cacheDirectory.appendingPathComponent(encodedURL)
        
        if let data {
            
            do {
                try data.write(to: fileURL)
            } catch {
                print("Error writing PNG file to disk: \(error)")
            }
            
        }
        
    }
    
    // MARK: - PRIVATE -
    
    private func setupCacheDirectory() {
        
        guard let baseURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            
            print("Could not locate the Caches directory.")
            return
            
        }
        
        let directoryName = "ImageCache"
        let directoryURL = baseURL.appendingPathComponent(directoryName, isDirectory: true)
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            
            do {
                
                try fileManager.createDirectory(
                    at: directoryURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                
            } catch {
                print("Could not create DiskImageCache directory: \(error)")
            }
            
        }
        
        self.cacheDirectory = directoryURL
        
    }
    
    private func encodeStrategy(_ input: String) -> String {
        
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_."))
        let encodedURL = input.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""
        return encodedURL
        
    }
    
}
