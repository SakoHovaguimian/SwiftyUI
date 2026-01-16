import SwiftUI
import Observation

public typealias Routable = Hashable & Identifiable
public typealias Coordinatable = Coordinator & BaseCoordinator

@MainActor
public protocol ParentCoordinator: AnyObject {
    
    var id: UUID { get }
    var router: Router { get }
    func removeChild(_ childId: UUID)
    
}

@MainActor
public protocol Coordinator: ParentCoordinator, Observable {
    
    associatedtype Route: Routable
    associatedtype StartView: View
    associatedtype BuildView: View

    @ViewBuilder func start(context: NavigationContext) -> StartView
    @ViewBuilder func build(_ route: Route) -> BuildView
    
}

@Observable
public final class NavigationState {

    public var path: NavigationPath = .init()

    public init() {
        self.path = .init()
    }

}

@Observable
public final class PresentationState {

    public var sheet: (any Routable)?
    public var fullScreenCover: (any Routable)?

    public init() {}

    public func dismiss() {
        
        self.sheet = nil
        self.fullScreenCover = nil
        
    }

}

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

public enum NavigationContext {
    
    case standalone
    case embedded(state: NavigationState)
    
}

public enum FinishPolicy: Hashable {
    
    case detach(isAnimated: Bool = false)
    case dismissModal
    case popToRoot
    case popToSelf
    case popCount(Int)
    
}

@MainActor
@Observable
open class BaseCoordinator: ParentCoordinator {

    public let id: UUID = UUID()
    
    public let router: Router
    public var finishPolicy: FinishPolicy
    
    public weak var parent: (any ParentCoordinator)?

    private(set) var childCoordinators: [UUID: any ParentCoordinator] = [:]
    private var childLookup: [AnyHashable: UUID] = [:]

    public init(parent: (any ParentCoordinator)? = nil,
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

    public func child<C: ParentCoordinator>(id key: AnyHashable,
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
    
    private func replaceChild<C: ParentCoordinator>(id key: AnyHashable,
                                                   with factory: () -> C) -> C {
        
        if let oldId = self.childLookup[key] {
            self.removeChild(oldId)
        }
        
        let newChild = factory()
        self.childCoordinators[newChild.id] = newChild
        self.childLookup[key] = newChild.id
        
        return newChild
        
    }
    
    public func swapFlow<C: ParentCoordinator, R: Routable>(id key: AnyHashable,
                                                            with newRoute: R,
                                                            factory: @escaping () -> C) {
        
        _ = self.replaceChild(id: key, with: factory)
        self.router.replace(last: 1, with: newRoute)
        
    }

}

public struct CoordinatorHost<Content: View>: View {

    @Bindable var router: Router
    let context: NavigationContext
    let content: () -> Content

    public init(router: Router,
                context: NavigationContext,
                @ViewBuilder content: @escaping () -> Content) {
        
        self.router = router
        self.context = context
        self.content = content
        
    }

    public var body: some View {
        
        switch self.context {
        case .standalone:
            
            NavigationStack(path: $router.navigation.path) {
                self.content()
            }
            
        case .embedded: self.content()
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
