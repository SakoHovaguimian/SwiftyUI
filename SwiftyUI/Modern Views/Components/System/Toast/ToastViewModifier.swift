//
//  ToastViewModifier.swift
//  Rival
//
//  Created by Sako Hovaguimian on 1/29/24.
//

import SwiftUI

struct ToastOverlayModifier: ViewModifier {
    
    @State private var overlayWindow: UIWindow?

    func body(content: Content) -> some View {
        content
            .onAppear {
                setupOverlayWindow()
            }
        
    }

    private func setupOverlayWindow() {
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           overlayWindow == nil {
            
            let window = PassthroughWindow(windowScene: windowScene)
            window.backgroundColor = .clear
            // View Controller
            let rootController = UIHostingController(rootView: ToastGroup())
            rootController.view.frame = windowScene.keyWindow?.frame ?? .zero
            rootController.view.backgroundColor = .clear
            window.rootViewController = rootController
            window.isHidden = false
            window.isUserInteractionEnabled = true
            window.tag = 1009
            
            overlayWindow = window
        }
        
    }
    
}

extension View {
    
    func withToastOverlay() -> some View {
        modifier(ToastOverlayModifier())
    }
    
}

fileprivate class PassthroughWindow: UIWindow {
    
    override func hitTest(_ point: CGPoint,
                          with event: UIEvent?) -> UIView? {
        
        guard let view = super.hitTest(point, with: event) else { return nil }
        
        return rootViewController?.view == view ? nil : view
        
    }
    
}
