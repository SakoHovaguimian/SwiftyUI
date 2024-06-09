//
//  Ext+NavigationController.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        interactivePopGestureRecognizer?.isEnabled = true
        interactivePopGestureRecognizer?.delegate = self
        
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    
}
