//
//  Coordinator.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/26.
//

import SwiftUI
import Observation

@MainActor
public protocol Coordinator: ParentCoordinatorProtocol, Observable {

    associatedtype Route: Routable
    associatedtype ModalRoute: Routable = Never
    associatedtype StartView: View
    associatedtype BuildView: View

    @ViewBuilder func start(context: NavigationContext) -> StartView
    @ViewBuilder func build(_ route: Route) -> BuildView

}

/// Default implementations for typed navigation access
public extension Coordinator {

    /// Type-safe navigation scoped to this coordinator's Route type.
    /// Enables dot-syntax: `navigation.push(.profile)`
    var navigation: TypedNavigation<Route> {
        TypedNavigation(router: router)
    }

    /// Type-safe presentation scoped to this coordinator's ModalRoute type.
    /// Enables dot-syntax: `presentation.sheet(.settings)`
    var presentation: TypedPresentation<ModalRoute> {
        TypedPresentation(router: router)
    }

}
