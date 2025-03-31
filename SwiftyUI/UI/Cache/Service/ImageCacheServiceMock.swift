//
//  ImageCacheServiceMock.swift
//  FetchTakeHome
//
//  Created by Sako Hovaguimian on 2/13/25.
//

import UIKit

final class ImageCacheServiceMock: ImageCacheServiceProtocol {
    
    private var cache: [NSURL: Data] = [:]
    
    func image(for url: String) -> UIImage? {
        
        guard let url = NSURL(string: url) else { return nil }
        
        if let imageData = cache[url] {
            return UIImage(data: imageData)
        }
        
        return nil
        
    }
    
    func insertImage(_ data: Data?, for url: String) {
        
        if let data,
           let url = NSURL(string: url) {
            
            cache[url] = data
            
        }
        
    }
    
}
