//
//  ImageCacheServiceProtocol.swift
//  FetchTakeHome
//
//  Created by Sako Hovaguimian on 2/13/25.
//

import UIKit

protocol ImageCacheServiceProtocol: AnyObject {
    
    func image(for url: String) -> UIImage?
    func insertImage(_ data: Data?, for url: String)
    
}
