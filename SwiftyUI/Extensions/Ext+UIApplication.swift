//
//  Ext+UIApplication.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import UIKit

extension UIApplication {
    
    static var release: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String? ?? "x.x"
    }
    static var build: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String? ?? "x"
    }
    static var version: String {
        return "\(self.release) (\(self.build))"
    }
    
    var firstKeyWindow: UIWindow? {
        
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
        
    }
    
    var originalKeyWindow: UIWindow? {
        
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.keyWindow
        
    }
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}

extension UIDevice {
    
    static var isModernDevice: Bool {
        
        let keyWindow = UIApplication.shared.originalKeyWindow
        return keyWindow?.safeAreaInsets.bottom ?? 0 > 0
        
    }

}
