//
//  SwiftUITestApp.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/11/23.
//

import SwiftUI

@main
struct SwiftUITestApp: App {
    
    var body: some Scene {
        WindowGroup {
            
            DevToolsView()
                .environmentObject(NavSettings())
            
        }
    }
    
}

extension UIApplication {
    
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
    
}
