import SwiftUI

// **********************************
// MARK: - App Coordinator
// **********************************

@MainActor
@Observable
final class AppCoordinator: BaseCoordinator {

    enum RootFlow {
        case home
    }

    init() {
        super.init(
            parent: nil,
            router: Router(
                coordinatorName: "AppCoordinator"
            )
        )
    }
    
    override func start(context: NavigationContext) -> AnyView {
        
        let home = self.child(id: RootFlow.home) {
            HomeCoordinator(parent: self, router: Router(coordinatorName: "HomeCoordinator"))
        }
        
        return home.eraseStart(context: .standalone)
        
    }

}

// **********************************
// MARK: - Home Coordinator
// **********************************

@MainActor
@Observable
final class HomeCoordinator: BaseCoordinator {

    enum Destination: Routable {

        enum FlowId: Hashable {
            case profile
            case settings
        }

        var id: String {
            switch self {
            case .details(let val): return "details_\(val)"
            case .profileFlow: return "profileFlow"
            case .settingsFlow: return "settingsFlow"
            }
        }

        case details(String)
        case profileFlow
        case settingsFlow

        var flowId: FlowId? {
            switch self {
            case .profileFlow: return .profile
            case .settingsFlow: return .settings
            default: return nil
            }
        }

    }

    enum ModalRoute: Hashable, Identifiable {

        var id: String {
            switch self {
            case .homeModal: return "homeModal"
            case .supportSheet: return "supportSheet"
            }
        }

        case homeModal
        case supportSheet
    }

    // -----------------------------------
    // MARK: - Convenience Routing
    // -----------------------------------

    func push(_ route: Destination) {
        self.router.push(route)
    }

    func presentFullScreen(_ route: ModalRoute) {
        self.router.presentFullScreen(route)
    }

    func presentSheet(_ route: ModalRoute) {
        self.router.presentSheet(route)
    }

    // -----------------------------------
    // MARK: - Start
    // -----------------------------------

    override func start(context: NavigationContext) -> AnyView {

        return AnyView(
            CoordinatorHost(router: self.router, context: context) {

                HomeViewTest(coordinator: self)
                    .navigationTitle("Home")
                    .navigationDestination(for: HomeCoordinator.Destination.self) { dest in
                        self.eraseBuild(dest)
                    }
                    .coordinatorFullScreen(HomeCoordinator.ModalRoute.self, router: self.router) { route in
                        self.buildModal(route)
                    }
                    .coordinatorSheet(HomeCoordinator.ModalRoute.self, router: self.router) { route in
                        self.buildModal(route)
                    }

            }
        )

    }
    
    override func build(_ destination: AnyRoutable) -> AnyView {
        guard let dest = destination as? Destination else { return AnyView(EmptyView()) }
        
        switch dest {

        case .details(let text):
            return AnyView(DetailScreen(text: text))

        case .profileFlow:

            let profile = self.child(id: Destination.FlowId.profile) {
                ProfileCoordinator(
                    parent: self,
                    router: Router(
                        coordinatorName: "ProfileCoordinator",
                        navigation: self.router.navigation,
                        presentation: self.router.presentation
                    ),
                    finishPolicy: .popToSelf
                )
            }

            return profile.eraseStart(context: .embedded(state: self.router.navigation))

        case .settingsFlow:

            let settings = self.child(id: Destination.FlowId.settings) {
                SettingsCoordinator(
                    parent: self,
                    router: Router(
                        coordinatorName: "SettingsCoordinator",
                        navigation: self.router.navigation,
                        presentation: self.router.presentation
                    ),
                    finishPolicy: .detach
                )
            }

            return settings.eraseStart(context: .embedded(state: self.router.navigation))

        }
    }

    @ViewBuilder
    func buildModal(_ route: ModalRoute) -> some View {

        switch route {

        case .homeModal:

            let modalHome = self.child(id: ModalRoute.homeModal) {

                let modalRouter = Router(
                    coordinatorName: "HomeCoordinator.Modal"
                )

                let coordinator = HomeModalCoordinator(
                    parent: self,
                    router: modalRouter,
                    finishPolicy: .dismissModal
                )

                return coordinator
            }

            modalHome.start(context: .standalone)

        case .supportSheet:

            let support = self.child(id: ModalRoute.supportSheet) {
                SupportCoordinator(
                    parent: self,
                    router: Router(
                        coordinatorName: "SupportCoordinator"
                    ),
                    finishPolicy: .dismissModal
                )
            }

            support.start(context: .standalone)

        }

    }

}

// **********************************
// MARK: - Profile Coordinator
// **********************************

@MainActor
@Observable
final class ProfileCoordinator: BaseCoordinator {

    enum Destination: Routable {
        
        var id: String {
            switch self {
            case .bio: return "bio"
            case .security: return "security"
            }
        }
        
        case bio
        case security
        
    }

    func push(_ route: Destination) {
        self.router.push(route)
    }

    override func start(context: NavigationContext) -> AnyView {

        return AnyView(
            CoordinatorHost(router: self.router, context: context) {

                ProfileScreen(coordinator: self)
                    .navigationTitle("Profile")
                    .navigationDestination(for: ProfileCoordinator.Destination.self) { dest in
                        self.eraseBuild(dest)
                    }

            }
        )

    }

    override func build(_ destination: AnyRoutable) -> AnyView {
        guard let dest = destination as? Destination else { return AnyView(EmptyView()) }

        switch dest {
        case .bio:
            return AnyView(
                VStack(spacing: 16) {
                    Text("User Bio Screen")
                    Button("PopToSelf & Finish") { self.finish() }
                }
                .padding()
            )

        case .security:
            return AnyView(
                VStack(spacing: 16) {
                    Text("Security Settings Screen")
                    Button("Finish") { self.finish() }
                }
                .padding()
            )
        }

    }

}

// **********************************
// MARK: - Settings Coordinator
// **********************************

@MainActor
@Observable
final class SettingsCoordinator: BaseCoordinator {
    
    enum Destination: Routable {
        
        var id: String {
            switch self {
            case .general: return "general"
            case .advanced: return "advanced"
            }
        }
        
        case general
        case advanced
    }

    override func start(context: NavigationContext) -> AnyView {

        return AnyView(
            CoordinatorHost(router: self.router, context: context) {

                VStack(spacing: 20) {
                    Text("Settings Root")
                    Button("Go General") { self.router.push(Destination.general) }
                    Button("Go Advanced") { self.router.push(Destination.advanced) }
                    
                    Divider()
                    
                    Button("Finish & Detach") { self.finish() }
                }
                .padding()
                .navigationTitle("Settings")
                .navigationDestination(for: Destination.self) { dest in
                    self.eraseBuild(dest)
                }

            }
        )

    }
    
    override func build(_ destination: AnyRoutable) -> AnyView {
        guard let dest = destination as? Destination else { return AnyView(EmptyView()) }
        
        return AnyView(
            VStack(spacing: 20) {
                Text(dest == .general ? "General Settings" : "Advanced Settings")
                
                Button("Pop To Self (Start of Settings)") {
                    self.router.popToSelf()
                }
                
                if dest == .general {
                    Button("Push Advanced") { self.router.push(Destination.advanced) }
                }
            }
            .padding()
        )
    }

}

// **********************************
// MARK: - Home Modal & Support Coordinators
// **********************************

@MainActor
@Observable
final class HomeModalCoordinator: BaseCoordinator {
    override func start(context: NavigationContext) -> AnyView {
        AnyView(
            CoordinatorHost(router: self.router, context: context) {
                VStack {
                    Text("Home Modal Flow")
                    Button("Finish") { self.finish() }
                }
            }
        )
    }
}

@MainActor
@Observable
final class SupportCoordinator: BaseCoordinator {
    override func start(context: NavigationContext) -> AnyView {
        AnyView(
            CoordinatorHost(router: self.router, context: context) {
                VStack {
                    Text("Support Sheet")
                    Button("Dismiss") { self.finish() }
                }
            }
        )
    }
}

// **********************************
// MARK: - Team Coordinator (Custom Start Context Example)
// **********************************

@MainActor
@Observable
final class TeamCoordinator: BaseCoordinator {
    
    enum StartContext {
        case members
        case memberDetails(id: String)
        case stats
    }
    
    // Default override required by Base
    override func start(context: NavigationContext) -> AnyView {
        return self.start(context: context, startWith: .members)
    }
    
    // Custom entry point
    func start(context: NavigationContext, startWith: StartContext) -> AnyView {
        AnyView(
            CoordinatorHost(router: self.router, context: context) {
                VStack(spacing: 20) {
                    switch startWith {
                    case .members:
                        Text("All Team Members")
                    case .memberDetails(let id):
                        Text("Showing Details for: \(id)")
                    case .stats:
                        Text("Team Statistics")
                    }
                    
                    Button("Finish") { self.finish() }
                }
                .navigationTitle("Team")
            }
        )
    }
}

#Preview {
    AppCoordinator().start(context: .standalone)
}

// **********************************
// MARK: - Profile Screen
// **********************************

struct ProfileScreen: View {
    let coordinator: ProfileCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Profile Root")
            Button("Go Bio") { self.coordinator.push(.bio) }
            Button("Go Security") { self.coordinator.push(.security) }
            Button("Pop One") { self.coordinator.router.pop() }
            
            Divider()
            
            Button("Finish Flow") { self.coordinator.finish() }
        }
        .padding()
    }
}

// **********************************
// MARK: - Detail Screen
// **********************************

struct DetailScreen: View {
    let text: String
    
    var body: some View {
        VStack {
            Text("Detail Content:")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.largeTitle)
        }
        .navigationTitle("Details")
    }
}

// **********************************
// MARK: - Sako Coordinator
// **********************************

final class SakoCoordinator: BaseCoordinator {
    
    // Subclasses of BaseCoordinator must at least override start
    override func start(context: NavigationContext) -> AnyView {
        return AnyView(
            CoordinatorHost(router: self.router, context: context) {
                Text("Sako Coordinator Root")
                    .navigationTitle("Sako")
            }
        )
    }
}

// **********************************
// MARK: - Preview
// **********************************

#Preview {
    // We call eraseStart because the AppCoordinator start returns AnyView
    // to satisfy the Coordinator protocol requirements.
    AppCoordinator().start(context: .standalone)
}

// **********************************
// MARK: - Home View Test
// **********************************

struct HomeViewTest: View {

    let coordinator: HomeCoordinator

    var body: some View {

        List {

            Section("Stack Navigation") {

                Button("Push Simple View") {
                    self.coordinator.push(.details("Simple View"))
                }

                Button("Push Profile Flow (PopToSelf Finish)") {
                    self.coordinator.push(.profileFlow)
                }
                
                Button("Push Settings Flow (Manual PopToSelf)") {
                    self.coordinator.push(.settingsFlow)
                }

            }

            Section("Pop Logic Tests") {

                Button("Push 3 views then PopToRoot after 1s") {
                    self.coordinator.push(.details("1"))
                    self.coordinator.push(.details("2"))
                    self.coordinator.push(.details("3"))

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.coordinator.router.popToRoot()
                    }
                }

            }

            Section("Modal Presentation") {

                Button("Full Screen Modal") {
                    self.coordinator.presentFullScreen(.homeModal)
                }

                Button("Sheet Modal") {
                    self.coordinator.presentSheet(.supportSheet)
                }

            }

        }

    }

}
