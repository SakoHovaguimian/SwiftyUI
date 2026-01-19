//
//  BaseCoordinator.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/26.
//

import SwiftUI
import Observation

@MainActor
@Observable
open class BaseCoordinator: ParentCoordinatorProtocol {
    
    public let id: UUID = UUID()
    public let router: Router
    
    private var isFinishing: Bool = false
    
    private(set) var finishPolicy: FinishPolicy
    private(set) weak var parent: (any ParentCoordinatorProtocol)?
    
    private var childCoordinators: [UUID: any ParentCoordinatorProtocol] = [:]
    private var childLookup: [AnyHashable: UUID] = [:]
    
    public init(parent: (any ParentCoordinatorProtocol)? = nil,
                router: Router? = nil,
                finishPolicy: FinishPolicy = .detach()) {
        
        self.parent = parent
        
        self.router = router ?? Router(coordinatorName: String(describing: Self.self))
        self.finishPolicy = finishPolicy
        
        CoordinatorLogger.lifecycle(self.router.coordinatorName, "BaseCoordinator initialized")
    }
    
    public func finish() {
        // 1. Mark as finishing so onDisappear knows it was explicit
        self.isFinishing = true
        
        CoordinatorLogger.lifecycle(self.router.coordinatorName, "Finish called explicitely")
        
        // 2. Notify Lifecycle
        (self as? CoordinatorLifecycle)?.coordinatorDidFinish()
        
        // 3. Manipulate the Router (Visuals)
        // This will eventually trigger onDisappear, but we want to clean up parent references immediately
        // to prevent race conditions where a user might try to push this coordinator again instantly.
        withAnimation(.easeInOut(duration: 0.3)) {
            self.applyFinishPolicy()
        }
        
        // 4. Run Cleanup
        self.performCleanup()
        
    }
    
    public func finishWithCustomPolicy(_ policy: FinishPolicy) {
        
        self.finishPolicy = policy
        finish()
        
    }
    
    private func applyFinishPolicy() {
        
        switch self.finishPolicy {
        case .detach(let isAnimated):
            
            self.router.popToSelf()
            
            if isAnimated {
                
                Task { [weak self] in
                    
                    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
                    
                    guard let self else { return }
                    guard !Task.isCancelled else { return }
                    
                    self.parent?.router.pop()
                    
                }
                
            } else {
                self.parent?.router.pop()
            }
            
        case .dismissModal: (self.parent?.router ?? self.router).dismissModal()
        case .popToRoot: self.router.popToRoot()
        case .popToSelf: self.router.popToSelf()
        case .popCount(let count): self.router.pop(count: count)
        }
        
    }
    
    public func removeChild(_ childId: UUID) {
        
        self.childCoordinators.removeValue(forKey: childId)
        self.childLookup.removeValue(forKey: childId)
        
        CoordinatorLogger.debug(self.router.coordinatorName, "Child coordinator removed: \(childId)")
    }
    
    public func child<C: ParentCoordinatorProtocol>(id key: AnyHashable,
                                                    factory: () -> C) -> C {
        
        if let existingId = self.childLookup[key],
           let existing = self.childCoordinators[existingId] as? C {
            
            CoordinatorLogger.debug(
                self.router.coordinatorName,
                "Reusing existing child coordinator: \(key) (id: \(existingId))"
            )
            return existing
        }
        
        let created = factory()
        self.childCoordinators[created.id] = created
        self.childLookup[key] = created.id
        
        CoordinatorLogger.debug(
            self.router.coordinatorName,
            "Created new child coordinator: \(key) (id: \(created.id))"
        )
        
        return created
    }
    
    private func replaceChild<C: ParentCoordinatorProtocol>(id key: AnyHashable,
                                                            with factory: () -> C) -> C {
        
        if let oldId = self.childLookup[key] {
            self.removeChild(oldId)
        }
        
        let newChild = factory()
        self.childCoordinators[newChild.id] = newChild
        self.childLookup[key] = newChild.id
        
        CoordinatorLogger.debug(
            self.router.coordinatorName,
            "Replaced child coordinator: \(key) (new id: \(newChild.id))"
        )
        
        return newChild
    }
    
    public func swapFlow<C: ParentCoordinatorProtocol, R: Routable>(id key: AnyHashable,
                                                                    with newRoute: R,
                                                                    factory: @escaping () -> C) {
        
        CoordinatorLogger.navigation(
            self.router.coordinatorName,
            "SwapFlow",
            "Swapping flow \(key) with route \(newRoute)"
        )
        
        _ = self.replaceChild(id: key, with: factory)
        self.router.replace(last: 1, with: newRoute)
    }
    
    /// Called automatically by CoordinatorHost via onDisappear
    public func didNavigateAway() {
        // If we are already running finish(), we don't need to do this again.
        guard !self.isFinishing else { return }
        
        // Check for modals (Covered vs Popped)
        if self.router.presentation.sheet != nil || self.router.presentation.fullScreenCover != nil {
            return
        }
        
        CoordinatorLogger.lifecycle(self.router.coordinatorName, "Implicit cleanup detected (Swipe/Pop)")
        
        (self as? CoordinatorLifecycle)?.coordinatorDidFinish()
        self.performCleanup()
    }
    
    /// Idempotent cleanup method. Safe to call multiple times.
    private func performCleanup() {
        
        // removeAll is safe to call on empty
        self.childCoordinators.removeAll()
        self.childLookup.removeAll()
        
        // removeChild checks if key exists, so this is safe
        self.parent?.removeChild(self.id)
        
        CoordinatorLogger.lifecycle(self.router.coordinatorName, "Cleanup References Complete")
    }
    
    // MARK: - Lifecycle Helpers
    
    /// Call this from CoordinatorHost when the coordinator appears
    internal func notifyDidAppear() {
        if let lifecycleCoordinator = self as? CoordinatorLifecycle {
            lifecycleCoordinator.coordinatorDidAppear()
        }
    }
    
    /// Call this from CoordinatorHost when the coordinator will disappear
    internal func notifyWillDisappear() {
        if let lifecycleCoordinator = self as? CoordinatorLifecycle {
            lifecycleCoordinator.coordinatorWillDisappear()
        }
    }
}
