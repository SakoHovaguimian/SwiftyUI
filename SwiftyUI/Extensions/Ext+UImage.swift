//
//  Ext+UImage.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import UIKit

extension UIImage {
    
    func scaleImage(scaleFactor: CGFloat = 0.05) -> UIImage? {
        
        let newSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let scaledImage = renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return scaledImage
        
    }
    
}
