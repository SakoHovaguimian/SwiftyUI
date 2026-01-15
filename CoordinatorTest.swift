import SwiftUI
import Observation

public typealias Routable = Hashable & Identifiable
public typealias AnyRoutable = any Routable
public typealias AnyCoordinator = any Coordinator
public typealias Coordinatable = Coordinator & BaseCoordinator
import SwiftUI
import Observation

// **********************************
// MARK: - Core Protocols
// **********************************

@MainActor
public protocol ParentCoordinator: AnyObject {
    var id: UUID { get }
    var router: Router { get }
    func removeChild(_ childId: UUID)
}

/// The UI contract. Moving start/build here allows for 'some View'
/// and typed Routes in the developer implementation.
@MainActor
public protocol Coordinator: ParentCoordinator, Observable {
    associatedtype Route: Routable
    associatedtype StartView: View
    associatedtype BuildView: View

    @ViewBuilder func start(context: NavigationContext) -> StartView
    @ViewBuilder func build(_ route: Route) -> BuildView
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

    // MARK: - Stack Operations

    public func push<T: Routable>(_ destination: T) {
        self.navigation.path.append(destination)
        self.localPushCount += 1
    }

    public func pop() {
        guard self.localPushCount > 0, !self.navigation.path.isEmpty else { return }
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

    // MARK: - Modal Operations

    public func presentSheet(_ value: any Routable) {
        self.presentation.sheet = value
    }

    public func presentFullScreen(_ value: any Routable) {
        self.presentation.fullScreenCover = value
    }

    public func dismissModal() {
        self.presentation.dismiss()
    }

}

// **********************************
// MARK: - Coordinator Context & Policy
// **********************************

public enum NavigationContext {
    case standalone
    case embedded(state: NavigationState)
}

public enum FinishPolicy: Hashable {
    case detach
    case dismissModal
    case popToRoot
    case popToSelf
}

// **********************************
// MARK: - Base Coordinator
// **********************************

@MainActor
@Observable
open class BaseCoordinator: ParentCoordinator {

    public let id: UUID = UUID()
    public let router: Router
    public weak var parent: (any ParentCoordinator)?
    public var finishPolicy: FinishPolicy

    private(set) var childCoordinators: [UUID: any ParentCoordinator] = [:]
    private var childLookup: [AnyHashable: UUID] = [:]

    public init(parent: (any ParentCoordinator)? = nil,
                router: Router? = nil,
                finishPolicy: FinishPolicy = .detach) {
        
        self.parent = parent
        
        // Requirement 1: Defaults to standalone.
        self.router = router ?? Router(coordinatorName: String(describing: Self.self))
        self.finishPolicy = finishPolicy
        
    }

    public func finish() {
        self.applyFinishPolicy()
        self.childCoordinators.removeAll()
        self.childLookup.removeAll()
        self.parent?.removeChild(self.id)
    }

    private func applyFinishPolicy() {
        switch self.finishPolicy {
        case .detach:
            self.router.popToSelf()
            self.parent?.router.pop()
        case .dismissModal:
            (self.parent?.router ?? self.router).dismissModal()
        case .popToRoot:
            self.router.popToRoot()
        case .popToSelf:
            self.router.popToSelf()
        }
    }

    public func removeChild(_ childId: UUID) {
        self.childCoordinators.removeValue(forKey: childId)
        self.childLookup.removeValue(forKey: childId)
    }

    public func child<C: ParentCoordinator>(id key: AnyHashable, factory: () -> C) -> C {
        if let existingId = self.childLookup[key],
           let existing = self.childCoordinators[existingId] as? C {
            return existing
        }

        let created = factory()
        self.childCoordinators[created.id] = created
        self.childLookup[key] = created.id
        return created
    }

}

// **********************************
// MARK: - UI Host
// **********************************

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
        case .embedded:
            self.content()
        }
    }

}

// **********************************
// MARK: - View Extensions
// **********************************

public extension View {

    /// Using isPresented logic avoids the 'any Routable' Identifiable requirement.
    func coordinatorSheet<Route: Routable, Content: View>(
        _ routeType: Route.Type,
        router: Router,
        @ViewBuilder build: @escaping (Route) -> Content
    ) -> some View {
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

    func coordinatorFullScreen<Route: Routable, Content: View>(
        _ routeType: Route.Type,
        router: Router,
        @ViewBuilder build: @escaping (Route) -> Content
    ) -> some View {
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
