//
//  NavigationState.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/26.
//

import SwiftUI
import Observation

@Observable
public final class NavigationState {
    
    public var path: NavigationPath = .init()
    
    public init() {
        self.path = .init()
    }
    
}
