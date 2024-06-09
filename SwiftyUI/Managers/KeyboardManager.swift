//
//  KeyboardManager.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/11/23.
//

import UIKit
import Combine

class KeyboardManager: ObservableObject {
    
    @Published var keyboardHeight: CGFloat = 0
    @Published var isVisible = false
    
    var keyboardCancellable = Set<AnyCancellable>()
    
    init() {
        
        NotificationCenter.default
            .publisher(for: UIWindow.keyboardWillShowNotification)
            .sink { [weak self] notification in
                
                guard let self = self else { return }
                
                guard let userInfo = notification.userInfo else { return }
                guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                
                self.isVisible = keyboardFrame.minY < UIScreen.main.bounds.height
                self.keyboardHeight = self.isVisible ? keyboardFrame.height : 0
                
            }
            .store(in: &self.keyboardCancellable)
        
        NotificationCenter.default
            .publisher(for: UIWindow.keyboardWillHideNotification)
            .sink { [weak self] notification in
                
                guard let self = self else { return }
                
                self.isVisible = false
                self.keyboardHeight = 0
                
            }
            .store(in: &self.keyboardCancellable)
    }
    
}
