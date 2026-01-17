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

    /// The path count when this coordinator was initialized or started.
    /// All "local" push counts are derived by comparing current path count to this base.
    /// This approach is resilient to @dismiss and interactive swipe-to-dismiss.
    private(set) var basePathCount: Int = 0

    /// Computed property that returns how many screens this coordinator "owns"
    /// by comparing current path count to the base count.
    /// This automatically stays in sync even when SwiftUI dismisses views directly.
    public var localPushCount: Int {
        max(0, self.navigation.path.count - self.basePathCount)
    }

    public init(coordinatorName: String,
                navigation: NavigationState = NavigationState(),
                presentation: PresentationState = PresentationState()) {

        self.coordinatorName = coordinatorName
        self.navigation = navigation
        self.presentation = presentation

    }

    /// Call this when the coordinator's root view appears to snapshot the current path depth.
    /// This establishes the "floor" from which localPushCount is calculated.
    public func recordBasePathCount() {
        self.basePathCount = self.navigation.path.count
    }

    public func push<T: Routable>(_ destination: T) {
        self.navigation.path.append(destination)
    }

    public func pop() {
    
        guard self.localPushCount > 0 else { return }
        self.navigation.path.removeLast()
        
    }

    public func popToSelf() {
        
        let countToPop = self.localPushCount
        
        guard countToPop > 0 else { return }
        self.navigation.path.removeLast(countToPop)
        
    }

    public func popToRoot() {
        
        self.navigation.path = NavigationPath()
        self.basePathCount = 0
        
    }

    public func pop(count: Int) {
        
        let safeCount = min(self.localPushCount, count)
        
        guard safeCount > 0 else { return }
        self.navigation.path.removeLast(safeCount)
        
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
        
    }

}
