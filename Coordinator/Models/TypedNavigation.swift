//
//  TypedNavigation.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/17/26.
//

import SwiftUI

/// Type-safe navigation wrapper scoped to a coordinator's Route type.
///
/// This wrapper enables dot-syntax navigation by constraining all navigation
/// operations to a specific route type at compile time:
///
/// ```swift
/// // ✅ Compiles - Route type is inferred
/// navigation.push(.profile)
/// navigation.push(.details(id: "123"))
///
/// // ❌ Won't compile - type mismatch
/// navigation.push(OtherCoordinator.Route.someRoute)
/// ```
@MainActor
public struct TypedNavigation<Route: Routable> {

    /// The underlying router instance for infrastructure operations
    public let router: Router

    public init(router: Router) {
        self.router = router
    }

    // MARK: - Push Operations

    /// Pushes a route onto the navigation stack.
    /// - Parameter route: The destination route (supports dot-syntax)
    public func push(_ route: Route) {
        router.push(route)
    }

    // MARK: - Pop Operations

    /// Pops the top view from this coordinator's portion of the stack.
    public func pop() {
        router.pop()
    }

    /// Pops all views pushed by this coordinator, returning to its root.
    public func popToSelf() {
        router.popToSelf()
    }

    /// Pops to the root of the entire navigation stack.
    public func popToRoot() {
        router.popToRoot()
    }

    /// Pops a specific number of views from the stack.
    /// - Parameter count: Number of views to pop
    public func pop(count: Int) {
        router.pop(count: count)
    }

    // MARK: - Replace Operations

    /// Replaces the top N views with a new route.
    /// - Parameters:
    ///   - count: Number of views to remove (default: 1)
    ///   - route: The replacement route (supports dot-syntax)
    public func replace(last count: Int = 1, with route: Route) {
        router.replace(last: count, with: route)
    }

}
