import SwiftUI

// TODO: -
/// Opt out view that is not registered
/// Clear backstack

// **********************************
// MARK: - App Coordinator
// **********************************

@MainActor
@Observable
final class AppCoordinator: BaseCoordinator, Coordinator {

    enum Route: Routable {
        case root
        var id: String { "root" }
    }

    init() {
        // Requirement 1: Default to standalone.
        // We initialize with a specific router here to satisfy your naming convention.
        super.init(
            router: Router(coordinatorName: "AppCoordinator")
        )
    }
    
    @ViewBuilder
    func start(context: NavigationContext = .standalone) -> some View {
        
        // Requirement 2: No AnyView.
        let home = self.child(id: "home_root") {
            HomeCoordinator(parent: self)
        }
        
        home.start(context: .standalone)
        
    }

    @ViewBuilder
    func build(_ route: Route) -> some View {
        EmptyView()
    }

}

// **********************************
// MARK: - Home Coordinator
// **********************************

@MainActor
@Observable
final class HomeCoordinator: BaseCoordinator, Coordinator {

    enum Destination: Routable {

        enum FlowId: Hashable {
            case profile
            case settings
        }

        case details(String)
        case profileFlow
        case settingsFlow

        var id: String {
            switch self {
            case .details(let val): return "details_\(val)"
            case .profileFlow: return "profileFlow"
            case .settingsFlow: return "settingsFlow"
            }
        }

        var flowId: FlowId? {
            switch self {
            case .profileFlow: return .profile
            case .settingsFlow: return .settings
            default: return nil
            }
        }

    }

    enum ModalRoute: Routable {
        case homeModal
        case supportSheet
        
        var id: String {
            switch self {
            case .homeModal: return "homeModal"
            case .supportSheet: return "supportSheet"
            }
        }
    }

    // -----------------------------------
    // MARK: - Start
    // -----------------------------------

    @ViewBuilder
    func start(context: NavigationContext = .standalone) -> some View {

        CoordinatorHost(router: self.router, context: context) {

            HomeViewTest(coordinator: self)
                .navigationTitle("Home")
                .navigationDestination(for: Destination.self) { dest in
                    self.build(dest)
                }
                .coordinatorFullScreen(ModalRoute.self, router: self.router) { route in
                    self.buildModal(route)
                }
                .coordinatorSheet(ModalRoute.self, router: self.router) { route in
                    self.buildModal(route)
                }

        }

    }
    
    // -----------------------------------
    // MARK: - Build
    // -----------------------------------
    
    @ViewBuilder
    func build(_ route: Destination) -> some View {
        
        switch route {

        case .details(let text):
            DetailScreen(text: text)

        case .profileFlow:
            let profile = self.child(id: Destination.FlowId.profile) {
                ProfileCoordinator(
                    parent: self,
                    router: Router(
                        coordinatorName: "ProfileCoordinator",
                        navigation: self.router.navigation,
                        presentation: self.router.presentation
                    ),
                    finishPolicy: .detach()
                )
            }

            profile.start(context: .embedded(state: self.router.navigation))

        case .settingsFlow:
            let settings = self.child(id: Destination.FlowId.settings) {
                SettingsCoordinator(
                    parent: self,
                    router: Router(
                        coordinatorName: "SettingsCoordinator",
                        navigation: self.router.navigation,
                        presentation: self.router.presentation
                    ),
                    finishPolicy: .detach()
                )
            }

            settings.start(context: .embedded(state: self.router.navigation))

        }
    }

    @ViewBuilder
    func buildModal(_ route: ModalRoute) -> some View {

        switch route {

        case .homeModal:
            let modalHome = self.child(id: route) {
                HomeModalCoordinator(parent: self, finishPolicy: .dismissModal)
            }
            modalHome.start(context: .standalone)

        case .supportSheet:
            let support = self.child(id: route) {
                SupportCoordinator(parent: self, finishPolicy: .dismissModal)
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
final class ProfileCoordinator: BaseCoordinator, Coordinator {

    enum Destination: Routable {
        case bio
        case security
        
        var id: String { "\(self)" }
    }

    @ViewBuilder
    func start(context: NavigationContext = .standalone) -> some View {

        CoordinatorHost(router: self.router, context: context) {

            ProfileScreen(coordinator: self)
                .navigationTitle("Profile")
                .navigationDestination(for: Destination.self) { dest in
                    self.build(dest)
                }

        }

    }

    @ViewBuilder
    func build(_ route: Destination) -> some View {
        
        switch route {
        case .bio:
            VStack(spacing: 16) {
                Text("User Bio Screen")
                Button("PopToSelf & Finish") {
                    self.finish()
                }
            }
            .padding()

        case .security:
            VStack(spacing: 16) {
                Text("Security Settings Screen")
                Button("Finish") { self.finish() }
            }
            .padding()
        }

    }

}

// **********************************
// MARK: - Settings Coordinator
// **********************************

@MainActor
@Observable
final class SettingsCoordinator: BaseCoordinator, Coordinator {
    
    enum Destination: Routable {
        case general
        case advanced
        var id: String { "\(self)" }
    }

    @ViewBuilder
    func start(context: NavigationContext = .standalone) -> some View {

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
                self.build(dest)
            }

        }

    }
    
    @ViewBuilder
    func build(_ route: Destination) -> some View {
        VStack(spacing: 20) {
            Text(route == .general ? "General Settings" : "Advanced Settings")
            
            Button("Pop To Self") {
                self.router.popToSelf()
            }
            
            if route == .general {
                Button("Push Advanced") { self.router.push(Destination.advanced) }
            }
        }
        .padding()
    }

}

// **********************************
// MARK: - Home Modal & Support Coordinators
// **********************************

@MainActor
@Observable
final class HomeModalCoordinator: BaseCoordinator, Coordinator {
    enum Route: Routable { case root; var id: String { "root" } }

    @ViewBuilder
    func start(context: NavigationContext) -> some View {
        CoordinatorHost(router: self.router, context: context) {
            VStack {
                Text("Home Modal Flow")
                Button("Finish") { self.finish() }
            }
        }
    }
    
    @ViewBuilder func build(_ route: Route) -> some View { EmptyView() }
}

@MainActor
@Observable
final class SupportCoordinator: BaseCoordinator, Coordinator {
    enum Route: Routable { case root; var id: String { "root" } }

    @ViewBuilder
    func start(context: NavigationContext) -> some View {
        CoordinatorHost(router: self.router, context: context) {
            VStack {
                Text("Support Sheet")
                Button("Dismiss") { self.finish() }
            }
        }
    }
    
    @ViewBuilder func build(_ route: Route) -> some View { EmptyView() }
}

// **********************************
// MARK: - Team Coordinator
// **********************************

@MainActor
@Observable
final class TeamCoordinator: BaseCoordinator, Coordinator {
    
    enum Route: Routable {
        case members
        case memberDetails(id: String)
        case stats
        var id: String { "\(self)" }
    }
    
    @ViewBuilder
    func start(context: NavigationContext) -> some View {
        self.build(.members) // Default entry
    }
    
    @ViewBuilder
    func build(_ route: Route) -> some View {
        CoordinatorHost(router: self.router, context: .standalone) {
            VStack(spacing: 20) {
                switch route {
                case .members: Text("All Team Members")
                case .memberDetails(let id): Text("Showing Details for: \(id)")
                case .stats: Text("Team Statistics")
                }
                Button("Finish") { self.finish() }
            }
            .navigationTitle("Team")
        }
    }
}

// **********************************
// MARK: - Sako Coordinator
// **********************************

@MainActor
@Observable
final class SakoCoordinator: BaseCoordinator, Coordinator {
    enum Route: Routable { case root; var id: String { "root" } }

    @ViewBuilder
    func start(context: NavigationContext) -> some View {
        CoordinatorHost(router: self.router, context: context) {
            Text("Sako Coordinator Root")
                .navigationTitle("Sako")
        }
    }

    @ViewBuilder func build(_ route: Route) -> some View { EmptyView() }
}

// **********************************
// MARK: - UI Screens
// **********************************

struct HomeViewTest: View {

    let coordinator: HomeCoordinator

    var body: some View {
        List {
            Section("Stack Navigation") {
                Button("Push Simple View") {
                    self.coordinator.router.push(HomeCoordinator.Destination.details("Simple View"))
                }
                Button("Push Profile Flow") {
                    self.coordinator.router.push(HomeCoordinator.Destination.profileFlow)
                }
                Button("Push Settings Flow") {
                    self.coordinator.router.push(HomeCoordinator.Destination.settingsFlow)
                }
            }

            Section("Pop Logic Tests") {
                Button("PopToRoot Test") {
                    self.coordinator.router.push(HomeCoordinator.Destination.details("1"))
                    self.coordinator.router.push(HomeCoordinator.Destination.details("2"))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.coordinator.router.popToRoot()
                    }
                }
            }

            Section("Modal Presentation") {
                Button("Full Screen Modal") {
                    self.coordinator.router.presentFullScreen(HomeCoordinator.ModalRoute.homeModal)
                }
                Button("Sheet Modal") {
                    self.coordinator.router.presentSheet(HomeCoordinator.ModalRoute.supportSheet)
                }
            }
            
            Section("Stack Surgery (1a)") {
                            Button("Deep Pop (3) & Replace") {
                                // Simulate a deep stack
                                coordinator.router.push(HomeCoordinator.Destination.details("Step 1"))
                                coordinator.router.push(HomeCoordinator.Destination.details("Step 2"))
                                coordinator.router.push(HomeCoordinator.Destination.details("Step 3"))
                                
                                // After a delay, pop all 3 and replace with one success screen
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    coordinator.router.replace(
                                        last: 3,
                                        with: HomeCoordinator.Destination.settingsFlow
                                    )
                                }
                            }
            }
            
            Section("Coordinator Swap (1b)") {
                Button("Atomic Swap: Profile → Settings") {
                    
                    coordinator.router.push(HomeCoordinator.Destination.details("Step 1"))
                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        
                        // We swap the memory instance AND the navigation route in one go
                        coordinator.swapFlow(
                            id: HomeCoordinator.Destination.details("Step 1"),
                            with: HomeCoordinator.Destination.settingsFlow
                        ) {
                            SettingsCoordinator(
                                parent: coordinator,
                                router: coordinator.router
                            )
                        }
                        
//                    }
                }
            }
        }
    }
}

struct ProfileScreen: View {
    let coordinator: ProfileCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Profile Root")
            Button("Go Bio") { self.coordinator.router.push(ProfileCoordinator.Destination.bio) }
            Button("Go Security") { self.coordinator.router.push(ProfileCoordinator.Destination.security) }
            Divider()
            Button("Finish Flow") { self.coordinator.finish() }
        }
        .padding()
    }
}

struct DetailScreen: View {
    let text: String
    
    var body: some View {
        VStack {
            Text(text).font(.largeTitle)
        }
        .navigationTitle("Details")
    }
}

// **********************************
// MARK: - Preview
// **********************************

#Preview {
    AppCoordinator().start()
}
