//
//  Extension+NavigationController.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/27/23.
//

import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
