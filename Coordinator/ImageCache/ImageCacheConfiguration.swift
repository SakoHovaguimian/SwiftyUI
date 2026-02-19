//
//  ImageCacheConfiguration.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/18/26.
//

import Foundation

public struct ImageCacheConfiguration {
    
    public var maxDiskAgeDays: Int
    public var maxMemoryCostLimitMB: Int
    
    public init(maxDiskAgeDays: Int = 7, maxMemoryCostLimitMB: Int = 500) {
        
        self.maxDiskAgeDays = maxDiskAgeDays
        self.maxMemoryCostLimitMB = maxMemoryCostLimitMB
        
    }
    
    public static var shared = ImageCacheConfiguration()
    
}
