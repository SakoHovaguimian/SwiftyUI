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
        
    }
    
    public func finish() {
        
        self.applyFinishPolicy()
        self.childCoordinators.removeAll()
        self.childLookup.removeAll()
        self.parent?.removeChild(self.id)
        
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
        
    }
    
    public func child<C: ParentCoordinatorProtocol>(id key: AnyHashable,
                                                    factory: () -> C) -> C {
        
        if let existingId = self.childLookup[key],
           let existing = self.childCoordinators[existingId] as? C {
            
            return existing
            
        }
        
        let created = factory()
        self.childCoordinators[created.id] = created
        self.childLookup[key] = created.id
        
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
        
        return newChild
        
    }
    
    public func swapFlow<C: ParentCoordinatorProtocol, R: Routable>(id key: AnyHashable,
                                                                    with newRoute: R,
                                                                    factory: @escaping () -> C) {
        
        _ = self.replaceChild(id: key, with: factory)
        self.router.replace(last: 1, with: newRoute)
        
    }
    
}
