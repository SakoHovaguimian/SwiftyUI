import SwiftUI
import Observation

public typealias Routable = Hashable & Identifiable
public typealias AnyRoutable = any Routable
public typealias AnyCoordinator = any Coordinator
public typealias Coordinatable = Coordinator & BaseCoordinator

// **********************************
// MARK: - Finish Policy
// **********************************

@MainActor
public enum FinishPolicy: Hashable {

    /// Removes the coordinator from its parent only (default).
    case detach

    /// Dismisses current modal context (sheet/fullScreenCover) then detaches.
    case dismissModal

    /// Pops to root of current navigation stack then detaches.
    case popToRoot

    /// Pops `count` then detaches.
    case pop(count: Int)
    
    /// Pops to root of the current coordinator in a push context
    /// This is different than popToRoot since root can we several coordinator pushes deep
    case popToSelf

    /// Custom escape hatch for edge cases.
    case custom(id: String)

}

// **********************************
// MARK: - Navigation Core
// **********************************

@Observable
public final class NavigationState {

    public var path: NavigationPath = .init()

    public init() {
        self.path = .init()
    }

}

@Observable
public final class PresentationState {

    public var sheet: AnyRoutable?
    public var fullScreenCover: AnyRoutable?
    
    public init(sheet: AnyRoutable? = nil,
                fullScreenCover: AnyRoutable? = nil) {
        
        self.sheet = sheet
        self.fullScreenCover = fullScreenCover
        
    }

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
    
    // Context
    public let coordinatorName: String
    
    /// Internal count of how many screens THIS specific coordinator instance has pushed.
    private(set) var localPushCount: Int = 0
    
    public init(coordinatorName: String,
         navigation: NavigationState = NavigationState(),
         presentation: PresentationState = PresentationState()) {
        
        self.coordinatorName = coordinatorName
        self.navigation = navigation
        self.presentation = presentation
        
    }
    
    // MARK: - Stack Operations

    public func push<T: Routable>(_ destination: T) {
        
        self.navigation.path.append(destination)
        self.localPushCount += 1
        
    }

    public func push<T: Routable>(_ destinations: [T]) {
        
        for dest in destinations {
            self.push(dest)
        }
        
    }

    public func pop() {
        
        guard self.localPushCount > 0 else { return }
        guard !self.navigation.path.isEmpty else { return }
        
        self.navigation.path.removeLast()
        self.localPushCount -= 1
        
    }

    public func popLast(count: Int) {
        
        let safeCount = min(count, self.localPushCount)
        guard safeCount > 0 else { return }

        for _ in 0..<safeCount {
            self.navigation.path.removeLast()
        }
        
        self.localPushCount -= safeCount
        
    }

    public func popToSelf() {
        self.popLast(count: self.localPushCount)
    }

    public func popToRoot() {
        
        self.navigation.path = NavigationPath()
        self.localPushCount = 0
        
    }

    // MARK: - Modal Operations

    public func presentSheet(_ value: AnyRoutable) {
        self.presentation.sheet = value
    }

    public func presentFullScreen(_ value: AnyRoutable) {
        self.presentation.fullScreenCover = value
    }

    public func dismissModal() {
        self.presentation.dismiss()
    }

}

// **********************************
// MARK: - Coordinator Context
// **********************************

@MainActor
public enum NavigationContext {

    /// Coordinator is responsible for creating its own NavigationStack.
    case standalone

    /// Coordinator should NOT create a NavigationStack and should share this navigation state.
    case embedded(state: NavigationState)

    public var isStandalone: Bool {
        
        switch self {
        case .standalone: return true
        case .embedded: return false
        }
        
    }

}

// **********************************
// MARK: - Coordinator Protocols
// **********************************

@MainActor
public protocol Coordinator: AnyObject, Observable {
    
    associatedtype Content: View

    var id: UUID { get }
    var router: Router { get }
    var parent: AnyCoordinator? { get set }

    var finishPolicy: FinishPolicy { get }

    @ViewBuilder func build(_ destination: AnyRoutable) -> Content
    @ViewBuilder func start(context: NavigationContext) -> Content
    
    // Bridge methods to allow AnyCoordinator to work
    func eraseBuild(_ destination: AnyRoutable) -> AnyView
    func eraseStart(context: NavigationContext) -> AnyView
    
    func finish()

}

// Default implementation to automatically handle type erasure
extension Coordinator {
    
    public func eraseBuild(_ destination: AnyRoutable) -> AnyView {
        return AnyView(self.build(destination))
    }
    
    public func eraseStart(context: NavigationContext) -> AnyView {
        return AnyView(self.start(context: context))
    }
    
}

@MainActor
public protocol ParentCoordinator: AnyObject {
    func removeChild(_ childId: UUID)
}

// **********************************
// MARK: - Base Coordinator
// **********************************

@MainActor
@Observable
open class BaseCoordinator: Coordinator, ParentCoordinator {

    public let id: UUID = UUID()
    public let router: Router
    public weak var parent: AnyCoordinator?

    public var finishPolicy: FinishPolicy

    // Cache children so pushes/modals don’t recreate flows accidentally.
    private(set) var childCoordinators: [UUID: AnyCoordinator] = [:]
    private var childLookup: [AnyHashable: UUID] = [:]

    public init(parent: AnyCoordinator? = nil,
        router: Router,
        finishPolicy: FinishPolicy = .detach) {
        
        self.parent = parent
        self.router = router
        self.finishPolicy = finishPolicy
        
    }
    
    open func build(_ destination: AnyRoutable) -> AnyView {
        return AnyView(EmptyView())
    }
    
    open func start(context: NavigationContext = .standalone) -> AnyView {
        return AnyView(EmptyView())
    }
    
    public func finish() {

        self.applyFinishPolicy(self.finishPolicy)

        self.childCoordinators.removeAll()
        self.childLookup.removeAll()

        if let parent = self.parent as? any ParentCoordinator {
            parent.removeChild(self.id)
        }

    }

    private func applyFinishPolicy(_ policy: FinishPolicy) {

        switch policy {
        case .detach:
            
            self.router.popToSelf()
            
            Task { @MainActor in
                
                try? await Task.sleep(for: .seconds(0.3))
                
                if let parentRouter = self.parent?.router {
                    parentRouter.pop()
                }
                
            }
            
        case .dismissModal:
            
            if let parent = self.parent {
                parent.router.dismissModal()
            } else {
                self.router.dismissModal()
            }
            
        case .popToRoot: self.router.popToRoot()
        case .pop(let count): self.router.popLast(count: count)
        case .popToSelf: self.router.popToSelf()
        case .custom: return
        }

    }

    public func removeChild(_ childId: UUID) {
        self.childCoordinators.removeValue(forKey: childId)

        for (key, value) in self.childLookup where value == childId {
            self.childLookup.removeValue(forKey: key)
        }
    }

    public func addChild(_ child: AnyCoordinator, key: AnyHashable? = nil) {

        self.childCoordinators[child.id] = child

        if let key {
            self.childLookup[key] = child.id
        }

    }

    public func child<C: Coordinator>(id key: AnyHashable,
                                      factory: () -> C) -> C {

        if let existingId = self.childLookup[key],
           let existing = self.childCoordinators[existingId] as? C {
            
            return existing
            
        }

        let created = factory()
        self.addChild(created, key: key)
        return created

    }

}

// **********************************
// MARK: - Coordinator Host
// **********************************

public struct CoordinatorHost<Root: View>: View {

    @Bindable public var router: Router
    
    public let context: NavigationContext
    public let root: () -> Root

    public init(router: Router,
         context: NavigationContext,
         @ViewBuilder root: @escaping () -> Root) {
        
        self._router = Bindable(wrappedValue: router)
        self.context = context
        self.root = root
        
    }

    public var body: some View {

        switch self.context {
        case .standalone:
            
            NavigationStack(path: $router.navigation.path) {
                self.root()
            }

        case .embedded: self.root()
        }

    }

}

// **********************************
// MARK: - Modal Helpers
// **********************************

public extension View {

    func coordinatorSheet<Route: Routable, Content: View>(_ routeType: Route.Type,
                                                          router: Router,
                                                          @ViewBuilder build: @escaping (Route) -> Content) -> some View {

        self.sheet(
            item: Binding(
                get: { router.presentation.sheet as? Route },
                set: { router.presentation.sheet = $0 }
            )
        ) { route in
            build(route)
        }

    }

    func coordinatorFullScreen<Route: Routable, Content: View>(_ routeType: Route.Type,
                                                               router: Router,
                                                               @ViewBuilder build: @escaping (Route) -> Content) -> some View {

        self.fullScreenCover(
            item: Binding(
                get: { router.presentation.fullScreenCover as? Route },
                set: { router.presentation.fullScreenCover = $0 }
            )
        ) { route in
            build(route)
        }

    }

}
