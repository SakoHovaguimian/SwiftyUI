//
//  CoordinatorHost.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/26.
//

import SwiftUI
import Observation

public struct CoordinatorHost<Content: View>: View {

    @Bindable var router: Router
    let context: NavigationContext
    let coordinator: BaseCoordinator?
    let content: () -> Content

    public init(router: Router,
                context: NavigationContext,
                coordinator: BaseCoordinator? = nil,
                @ViewBuilder content: @escaping () -> Content) {

        self.router = router
        self.context = context
        self.coordinator = coordinator
        self.content = content

    }

    public var body: some View {

        switch self.context {
        case .standalone:

            NavigationStack(path: $router.navigation.path) {
                self.content()
                    .onAppear {
                        self.coordinator?.notifyDidAppear()
                    }
                    .onDisappear {
                        self.coordinator?.notifyWillDisappear()
                    }
            }

        case .embedded:

            self.content()
                .onAppear {
                    self.router.recordBasePathCount()
                    self.coordinator?.notifyDidAppear()
                }
                .onDisappear {
                    self.coordinator?.notifyWillDisappear()
                }

        }

    }

}

public extension View {

    /// Using isPresented logic avoids the 'any Routable' Identifiable requirement.
    func coordinatorSheet<Route: Routable, Content: View>(_ routeType: Route.Type,
                                                          router: Router,
                                                          @ViewBuilder build: @escaping (Route) -> Content) -> some View {

        self.sheet(
            isPresented: Binding(
                get: { router.presentation.sheet is Route },
                set: { if !$0 { router.presentation.dismiss() } }
            )
        ) {

            if let route = router.presentation.sheet as? Route {
                build(route)
            }

        }

    }

    func coordinatorFullScreen<Route: Routable, Content: View>(_ routeType: Route.Type,
                                                               router: Router,
                                                               @ViewBuilder build: @escaping (Route) -> Content) -> some View {

        self.fullScreenCover(
            isPresented: Binding(
                get: { router.presentation.fullScreenCover is Route },
                set: { if !$0 { router.presentation.dismiss() } }
            )
        ) {

            if let route = router.presentation.fullScreenCover as? Route {
                build(route)
            }

        }

    }

}
