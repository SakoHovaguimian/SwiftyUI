//
//  Router.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/26.
//

import SwiftUI
import Observation

@MainActor
@Observable
public final class Router {
    
    public var navigation: NavigationState
    public let presentation: PresentationState
    public let coordinatorName: String
    
    /// Tracks screens pushed specifically by this coordinator instance.
    private(set) var localPushCount: Int = 0
    
    public init(coordinatorName: String,
                navigation: NavigationState = NavigationState(),
                presentation: PresentationState = PresentationState()) {
        
        self.coordinatorName = coordinatorName
        self.navigation = navigation
        self.presentation = presentation
        
    }
    
    public func push<T: Routable>(_ destination: T) {
        
        self.navigation.path.append(destination)
        self.localPushCount += 1
        
    }
    
    public func pop() {
        
        guard self.localPushCount > 0,
              !self.navigation.path.isEmpty else { return }
        
        self.navigation.path.removeLast()
        self.localPushCount -= 1
        
    }
    
    public func popToSelf() {
        
        let safeCount = min(self.localPushCount, self.navigation.path.count)
        
        for _ in 0..<safeCount {
            self.navigation.path.removeLast()
        }
        
        self.localPushCount = 0
        
    }
    
    public func popToRoot() {
        
        self.navigation.path = NavigationPath()
        self.localPushCount = 0
        
    }
    
    public func pop(count: Int) {
        
        let safeCount = min(self.localPushCount, count)
        
        self.navigation.path.removeLast(safeCount)
        self.localPushCount = max(0, self.localPushCount - safeCount)
        
    }
    
    public func presentSheet(_ value: any Routable) {
        self.presentation.sheet = value
    }
    
    public func presentFullScreen(_ value: any Routable) {
        self.presentation.fullScreenCover = value
    }
    
    public func dismissModal() {
        self.presentation.dismiss()
    }
    
    public func replace<T: Routable>(last count: Int = 1,
                                     with destination: T) {
        
        let safeCount = min(self.localPushCount, count)
        
        if safeCount > 0 {
            self.navigation.path.removeLast(safeCount)
        }
        
        self.navigation.path.append(destination)
        self.localPushCount = (self.localPushCount - safeCount) + 1
        
    }
    
}
