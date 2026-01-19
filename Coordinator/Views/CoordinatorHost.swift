//
//  CoordinatorHost.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/26.
//

import SwiftUI
import Observation

public struct CoordinatorHost<Content: View>: View {
    
    @Environment(\.isPresented) var isPresented
    
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
                    self.handleEmbeddedDisappearance()
                }
            
        }
        
    }
    
    private func handleEmbeddedDisappearance() {
        
        self.coordinator?.notifyWillDisappear()
        
        guard let coordinator = self.coordinator else { return }
        
        // CHECK 1: The "Self-Coverage" Check
        // If WE are presenting a modal, we are just in the background. We are safe.
        if coordinator.router.presentation.sheet != nil ||
            coordinator.router.presentation.fullScreenCover != nil {
            return
        }
        
        // CHECK 2: The "Explicit Dismissal" Check (Fixes Pull-Down)
        // If SwiftUI tells us we are no longer presented, we are definitely dead.
        // This catches: Drag-to-dismiss, Back Button, and Popping.
        if !self.isPresented {
            coordinator.didNavigateAway()
            return
        }
        
        // CHECK 3: The "Tab Switch / Replace" Check
        // If we are still 'presented' (according to SwiftUI), but we disappeared:
        // It's likely a Tab Switch or an internal View Replacement.
        // We verify our existence in the path to be sure.
        let currentPathCount = coordinator.router.navigation.path.count
        let myBaseCount = coordinator.router.basePathCount
        
        // If the path is smaller than our base, we were popped programmatically
        // (and isPresented might not have updated yet in some rare race conditions).
        if currentPathCount < (myBaseCount + 1) {
            coordinator.didNavigateAway()
            return
        }
        
        CoordinatorLogger.lifecycle(coordinator.router.coordinatorName, "Disappear ignored (Tab Switch or Replace detected)")
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
                set: { if !$0 { router.dismissModal() } }
            ),
            onDismiss: { router.dismissModal() }
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
                set: { if !$0 { router.dismissModal() } }
            ),
            onDismiss: { router.dismissModal() }
        ) {
            
            if let route = router.presentation.fullScreenCover as? Route {
                build(route)
            }
            
        }
        
    }
    
}
