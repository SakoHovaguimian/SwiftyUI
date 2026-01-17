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

        CoordinatorLogger.lifecycle(coordinatorName, "Router initialized")

    }

    /// Call this when the coordinator's root view appears to snapshot the current path depth.
    /// This establishes the "floor" from which localPushCount is calculated.
    public func recordBasePathCount() {
        let previousBase = self.basePathCount
        self.basePathCount = self.navigation.path.count
        CoordinatorLogger.debug(self.coordinatorName, "Base path count recorded: \(previousBase) -> \(self.basePathCount)")
    }

    public func push<T: Routable>(_ destination: T) {
        self.navigation.path.append(destination)
        CoordinatorLogger.navigation(self.coordinatorName, "Push", "\(destination)")
    }

    public func pop() {

        guard self.localPushCount > 0 else {
            CoordinatorLogger.error(
                self.coordinatorName,
                "Pop",
                "No views to pop (localPushCount: \(self.localPushCount), totalPathCount: \(self.navigation.path.count))"
            )
            return
        }

        self.navigation.path.removeLast()
        CoordinatorLogger.navigation(self.coordinatorName, "Pop", "localPushCount: \(self.localPushCount)")
    }

    public func popToSelf() {

        let countToPop = self.localPushCount

        guard countToPop > 0 else {
            CoordinatorLogger.error(
                self.coordinatorName,
                "PopToSelf",
                "No views to pop (localPushCount: \(countToPop))"
            )
            return
        }

        self.navigation.path.removeLast(countToPop)
        CoordinatorLogger.navigation(self.coordinatorName, "PopToSelf", "Popped \(countToPop) views")
    }

    public func popToRoot() {

        let previousCount = self.navigation.path.count
        self.navigation.path = NavigationPath()
        self.basePathCount = 0

        CoordinatorLogger.navigation(
            self.coordinatorName,
            "PopToRoot",
            "Cleared \(previousCount) views from path"
        )
    }

    public func pop(count: Int) {

        let safeCount = min(self.localPushCount, count)

        guard safeCount > 0 else {
            CoordinatorLogger.error(
                self.coordinatorName,
                "Pop(count: \(count))",
                "Invalid count: requested \(count), available \(self.localPushCount)"
            )
            return
        }

        self.navigation.path.removeLast(safeCount)
        CoordinatorLogger.navigation(
            self.coordinatorName,
            "Pop(count: \(count))",
            "Popped \(safeCount) views (requested: \(count))"
        )
    }

    public func presentSheet(_ value: any Routable) {
        self.presentation.sheet = value
        CoordinatorLogger.navigation(self.coordinatorName, "PresentSheet", "\(value)")
    }

    public func presentFullScreen(_ value: any Routable) {
        self.presentation.fullScreenCover = value
        CoordinatorLogger.navigation(self.coordinatorName, "PresentFullScreen", "\(value)")
    }

    public func dismissModal() {

        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            self.popToSelf()
        }

        self.presentation.dismiss()
        CoordinatorLogger.navigation(self.coordinatorName, "DismissModal", "Modal dismissed")
    }

    public func replace<T: Routable>(last count: Int = 1,
                                     with destination: T) {

        let safeCount = min(self.localPushCount, count)

        if safeCount > 0 {
            self.navigation.path.removeLast(safeCount)
        }

        self.navigation.path.append(destination)

        CoordinatorLogger.navigation(
            self.coordinatorName,
            "Replace",
            "Replaced last \(safeCount) views with \(destination)"
        )
    }

}
