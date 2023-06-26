//
//  Extension+UIApplication.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/24/23.
//

import UIKit

extension UIApplication {
    
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
    
}
