//
//  TypedPresentation.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/17/26.
//

import SwiftUI

/// Type-safe presentation wrapper scoped to a coordinator's ModalRoute type.
///
/// This wrapper enables dot-syntax modal presentation by constraining all
/// presentation operations to a specific modal route type at compile time:
///
/// ```swift
/// // ✅ Compiles - ModalRoute type is inferred
/// presentation.sheet(.settings)
/// presentation.fullScreen(.onboarding)
///
/// // ❌ Won't compile - type mismatch
/// presentation.sheet(OtherCoordinator.ModalRoute.someModal)
/// ```
@MainActor
public struct TypedPresentation<ModalRoute: Routable> {

    /// The underlying router instance for infrastructure operations
    public let router: Router

    public init(router: Router) {
        self.router = router
    }

    // MARK: - Present Operations

    /// Presents a route as a sheet.
    /// - Parameter route: The modal route (supports dot-syntax)
    public func sheet(_ route: ModalRoute) {
        router.presentSheet(route)
    }

    /// Presents a route as a full-screen cover.
    /// - Parameter route: The modal route (supports dot-syntax)
    public func fullScreen(_ route: ModalRoute) {
        router.presentFullScreen(route)
    }

    // MARK: - Dismiss Operations

    /// Dismisses the currently presented modal.
    public func dismiss() {
        router.dismissModal()
    }

}
