import SwiftUI
import Observation

typealias Routable = Hashable & Identifiable
typealias AnyRoutable = any Routable
typealias AnyCoordinator = any Coordinator

// **********************************
// MARK: - Finish Policy
// **********************************

@MainActor
enum FinishPolicy: Hashable {

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
final class NavigationState {

    var path: NavigationPath = .init()

    init() {
        self.path = .init()
    }

}

@Observable
final class PresentationState {

    var sheet: AnyRoutable?
    var fullScreenCover: AnyRoutable?

    func dismiss() {
        self.sheet = nil
        self.fullScreenCover = nil
    }

}

@MainActor
@Observable
final class Router {

    var navigation: NavigationState
    let presentation: PresentationState

    // Context
    let coordinatorName: String
    
    /// Internal count of how many screens THIS specific coordinator instance has pushed.
    private(set) var localPushCount: Int = 0

    init(
        coordinatorName: String,
        navigation: NavigationState = NavigationState(),
        presentation: PresentationState = PresentationState()
    ) {
        self.coordinatorName = coordinatorName
        self.navigation = navigation
        self.presentation = presentation
    }

    // MARK: - Stack Operations

    func push<T: Hashable>(_ destination: T) {
        self.navigation.path.append(destination)
        self.localPushCount += 1
    }

    func push<T: Hashable>(_ destinations: [T]) {
        for dest in destinations {
            self.push(dest)
        }
    }

    func pop() {
        guard self.localPushCount > 0 else { return }
        guard !self.navigation.path.isEmpty else { return }
        
        self.navigation.path.removeLast()
        self.localPushCount -= 1
    }

    func popLast(count: Int) {
        let safeCount = min(count, self.localPushCount)
        guard safeCount > 0 else { return }

        for _ in 0..<safeCount {
            self.navigation.path.removeLast()
        }
        
        self.localPushCount -= safeCount
    }

    func popToSelf() {
        self.popLast(count: self.localPushCount)
    }

    func popToRoot() {
        self.navigation.path = NavigationPath()
        self.localPushCount = 0
    }

    // MARK: - Modal Operations

    func presentSheet(_ value: AnyRoutable) {
        self.presentation.sheet = value
    }

    func presentFullScreen(_ value: AnyRoutable) {
        self.presentation.fullScreenCover = value
    }

    func dismissModal() {
        self.presentation.dismiss()
    }

}

// **********************************
// MARK: - Coordinator Context
// **********************************

@MainActor
enum NavigationContext {

    /// Coordinator is responsible for creating its own NavigationStack.
    case standalone

    /// Coordinator should NOT create a NavigationStack and should share this navigation state.
    case embedded(state: NavigationState)

    var isStandalone: Bool {
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
protocol Coordinator: AnyObject, Observable {

    var id: UUID { get }
    var router: Router { get }
    var parent: AnyCoordinator? { get set }

    var finishPolicy: FinishPolicy { get }

    func finish()

}

@MainActor
protocol ParentCoordinator: AnyObject {
    func removeChild(_ childId: UUID)
}

// **********************************
// MARK: - Base Coordinator
// **********************************

@MainActor
@Observable
class BaseCoordinator: Coordinator, ParentCoordinator {

    let id: UUID = UUID()
    let router: Router
    weak var parent: AnyCoordinator?

    var finishPolicy: FinishPolicy

    // Cache children so pushes/modals don’t recreate flows accidentally.
    private(set) var childCoordinators: [UUID: AnyCoordinator] = [:]
    private var childLookup: [AnyHashable: UUID] = [:]

    init(
        parent: AnyCoordinator? = nil,
        router: Router,
        finishPolicy: FinishPolicy = .detach
    ) {
        self.parent = parent
        self.router = router
        self.finishPolicy = finishPolicy
    }

    func finish() {

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
            
            if let parentRouter = self.parent?.router {
                parentRouter.pop()
            }
            
        case .dismissModal:
            
            if let parent = self.parent {
                parent.router.dismissModal()
            } else {
                self.router.dismissModal()
            }
            
        case .popToRoot:
            self.router.popToRoot()

        case .pop(let count):
            self.router.popLast(count: count)
            
        case .popToSelf:
            
            self.router.popToSelf()

        case .custom:
            return

        }

    }

    func removeChild(_ childId: UUID) {
        self.childCoordinators.removeValue(forKey: childId)

        for (key, value) in self.childLookup where value == childId {
            self.childLookup.removeValue(forKey: key)
        }
    }

    func addChild(_ child: AnyCoordinator, key: AnyHashable? = nil) {

        self.childCoordinators[child.id] = child

        if let key {
            self.childLookup[key] = child.id
        }

    }

    func child<C: Coordinator>(
        id key: AnyHashable,
        factory: () -> C
    ) -> C {

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

struct CoordinatorHost<Root: View>: View {

    @Bindable var router: Router
    let context: NavigationContext
    let root: () -> Root

    init(
        router: Router,
        context: NavigationContext,
        @ViewBuilder root: @escaping () -> Root
    ) {
        self._router = Bindable(wrappedValue: router)
        self.context = context
        self.root = root
    }

    var body: some View {

        switch self.context {

        case .standalone:
            NavigationStack(path: $router.navigation.path) {
                self.root()
            }

        case .embedded:
            self.root()

        }

    }

}

// **********************************
// MARK: - Modal Helpers
// **********************************

extension View {

    func coordinatorSheet<Route: Routable, Content: View>(
        _ routeType: Route.Type,
        router: Router,
        @ViewBuilder build: @escaping (Route) -> Content
    ) -> some View {

        self.sheet(
            item: Binding(
                get: { router.presentation.sheet as? Route },
                set: { router.presentation.sheet = $0 }
            )
        ) { route in
            build(route)
        }

    }

    func coordinatorFullScreen<Route: Routable, Content: View>(
        _ routeType: Route.Type,
        router: Router,
        @ViewBuilder build: @escaping (Route) -> Content
    ) -> some View {

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
