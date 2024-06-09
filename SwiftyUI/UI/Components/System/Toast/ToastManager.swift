//
//  ToastManager.swift
//  Rival
//
//  Created by Sako Hovaguimian on 1/29/24.
//

import SwiftUI

@Observable
class ToastManager {
    
    enum Style {
        
        case standard
        case custom
        
    }
    
    static let shared = ToastManager()
    var toasts: [ToastItem] = []
    
    func present(toastItem: ToastItem) {
        
        withAnimation(.snappy) {
            self.toasts.append(toastItem)
        }
        
    }
    
}
