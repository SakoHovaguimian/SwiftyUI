import SwiftUI

// **********************************
// MARK: - Lifecycle Logging
// **********************************

public enum LifecycleLog {

    public static func view(_ name: String, _ event: String) {
        print("🧬 [View] \(name) • \(event)")
    }

    public static func viewTask(_ name: String, _ event: String) {
        print("⏱️ [ViewTask] \(name) • \(event)")
    }

    public static func viewModel(_ name: String, _ event: String) {
        print("🧠 [ViewModel] \(name) • \(event)")
    }

}

// **********************************
// MARK: - Base ViewModel
// **********************************

@MainActor
open class LifecycleViewModel: ObservableObject {

    public let logName: String

    public init(logName: String) {
        self.logName = logName
        LifecycleLog.viewModel(self.logName, "init")
    }

    deinit {
        LifecycleLog.viewModel(self.logName, "deinit")
    }

    public func logInit() {
        LifecycleLog.viewModel(self.logName, "logInit()")
    }

}

// **********************************
// MARK: - View Modifiers
// **********************************

private extension View {

    func lifecycle(_ name: String) -> some View {
        self
            .task { LifecycleLog.view(name, "task") }
            .onDisappear { LifecycleLog.view(name, "onDisappear") }
    }

}

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
        super.init(
            router: Router(coordinatorName: "AppCoordinator")
        )
    }

    @ViewBuilder
    func start(context: NavigationContext = .standalone) -> some View {

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

    typealias Route = Destination
    typealias ModalRoute = Modal

    // MARK: - Route Types

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

    enum Modal: Routable {
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

        CoordinatorHost(router: self.router, context: context, coordinator: self) {

            HomeViewTest(coordinator: self)
                .navigationTitle("Home")
                .navigationDestination(for: Destination.self) { dest in
                    self.build(dest)
                }
                .coordinatorFullScreen(Modal.self, router: self.router) { route in
                    self.buildModal(route)
                }
                .coordinatorSheet(Modal.self, router: self.router) { route in
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
    func buildModal(_ route: Modal) -> some View {

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

// MARK: - CoordinatorLifecycle Example
extension HomeCoordinator: CoordinatorLifecycle {
    func coordinatorDidAppear() {
        CoordinatorLogger.lifecycle(router.coordinatorName, "HomeCoordinator appeared")
    }

    func coordinatorWillDisappear() {
        CoordinatorLogger.lifecycle(router.coordinatorName, "HomeCoordinator will disappear")
    }

    func coordinatorDidFinish() {
        CoordinatorLogger.lifecycle(router.coordinatorName, "HomeCoordinator finished")
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

    typealias Route = Destination

    @ViewBuilder
    func start(context: NavigationContext = .standalone) -> some View {

        CoordinatorHost(router: self.router, context: context, coordinator: self) {

            ProfileScreen()
                .navigationTitle("Profile")
                .navigationDestination(for: Destination.self) { dest in
                    self.build(dest)
                }

        }
        .environment(\.coordinator, self)

    }

    @ViewBuilder
    func build(_ route: Destination) -> some View {

        switch route {

        case .bio:
            ProfileBioView(coordinator: self)

        case .security:
            ProfileSecurityView(coordinator: self)

        }

    }

}

// MARK: - CoordinatorLifecycle Example
extension ProfileCoordinator: CoordinatorLifecycle {
    func coordinatorDidAppear() {
        CoordinatorLogger.lifecycle(router.coordinatorName, "ProfileCoordinator appeared")
    }

    func coordinatorWillDisappear() {
        CoordinatorLogger.lifecycle(router.coordinatorName, "ProfileCoordinator will disappear")
    }

    func coordinatorDidFinish() {
        CoordinatorLogger.lifecycle(router.coordinatorName, "ProfileCoordinator finished")
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

        CoordinatorHost(router: self.router, context: context, coordinator: self) {

            SettingsRootView(coordinator: self)
                .navigationTitle("Settings")
                .navigationDestination(for: Destination.self) { dest in
                    self.build(dest)
                }

        }

    }

    @ViewBuilder
    func build(_ route: Destination) -> some View {
        SettingsDetailView(coordinator: self, route: route)
    }

}

extension SettingsCoordinator: CoordinatorLifecycle {
    func coordinatorDidAppear() {
        CoordinatorLogger.lifecycle(router.coordinatorName, "SettingsCoordinator appeared")
    }

    func coordinatorWillDisappear() {
        CoordinatorLogger.lifecycle(router.coordinatorName, "SettingsCoordinator will disappear")
    }

    func coordinatorDidFinish() {
        CoordinatorLogger.lifecycle(router.coordinatorName, "SettingsCoordinator finished")
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
        CoordinatorHost(router: self.router, context: context, coordinator: self) {
            HomeModalRootView(coordinator: self)
        }
    }

    @ViewBuilder
    func build(_ route: Route) -> some View { EmptyView() }

}

@MainActor
@Observable
final class SupportCoordinator: BaseCoordinator, Coordinator {

    enum Route: Routable { case root; var id: String { "root" } }

    @ViewBuilder
    func start(context: NavigationContext) -> some View {
        CoordinatorHost(router: self.router, context: context, coordinator: self) {
            SupportRootView(coordinator: self)
        }
    }

    @ViewBuilder
    func build(_ route: Route) -> some View { EmptyView() }

}

// **********************************
// MARK: - Team CoordinatorHomeCoordinator
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
    func start(context: NavigationContext = .standalone) -> some View {
        self.build(.members)
    }

    @ViewBuilder
    func build(_ route: Route) -> some View {

        CoordinatorHost(router: self.router, context: .standalone, coordinator: self) {
            TeamRootView(coordinator: self, route: route)
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
        CoordinatorHost(router: self.router, context: context, coordinator: self) {
            SakoRootView()
                .navigationTitle("Sako")
        }
    }

    @ViewBuilder
    func build(_ route: Route) -> some View { EmptyView() }

}

// **********************************
// MARK: - UI Screens + ViewModels
// **********************************

// -----------------------------------
// MARK: - HomeViewTest
// -----------------------------------

@MainActor
final class HomeViewTestViewModel: LifecycleViewModel {
    init() { super.init(logName: "HomeViewTestViewModel") }
}

struct HomeViewTest: View {

    let coordinator: HomeCoordinator
    @StateObject private var viewModel = HomeViewTestViewModel()

    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
//        LifecycleLog.view("HomeViewTest", "init")
    }

    var body: some View {
        List {
            Section("Stack Navigation") {
                Button("Push Simple View") {
                    self.coordinator.navigation.push(.details("Simple View"))
                }
                Button("Push Profile Flow") {
                    self.coordinator.navigation.push(.profileFlow)
                }
                Button("Push Settings Flow") {
                    self.coordinator.navigation.push(.settingsFlow)
                }
            }

            Section("Pop Logic Tests") {
                Button("PopToRoot Test") {
                    self.coordinator.navigation.push(.details("1"))
                    self.coordinator.navigation.push(.details("2"))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.coordinator.navigation.popToRoot()
                    }
                }
            }

            Section("Modal Presentation") {
                Button("Full Screen Modal") {
                    self.coordinator.presentation.fullScreen(.homeModal)
                }
                Button("Sheet Modal") {
                    self.coordinator.presentation.sheet(.supportSheet)
                }
            }

            Section("Stack Surgery (1a)") {
                Button("Deep Pop (3) & Replace") {
                    coordinator.navigation.push(.details("Step 1"))
                    coordinator.navigation.push(.details("Step 2"))
                    coordinator.navigation.push(.details("Step 3"))

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        coordinator.navigation.replace(last: 3, with: .settingsFlow)
                    }
                }
            }

            Section("Coordinator Swap (1b)") {
                Button("Atomic Swap: Profile → Settings") {

                    coordinator.navigation.push(.details("Step 1"))

                    coordinator.swapFlow(
                        id: HomeCoordinator.Destination.details("Step 1"),
                        with: HomeCoordinator.Destination.settingsFlow
                    ) {
                        SettingsCoordinator(
                            parent: coordinator,
                            router: coordinator.router
                        )
                    }
                }
            }
        }
        .lifecycle("HomeViewTest")
        .task {
//            LifecycleLog.viewTask("HomeViewTest", "task begin -> viewModel.logInit()")
            self.viewModel.logInit()
        }
    }

}

// -----------------------------------
// MARK: - ProfileScreen
// -----------------------------------

@MainActor
final class ProfileScreenViewModel: LifecycleViewModel {
    init() { super.init(logName: "ProfileScreenViewModel") }
}

struct ProfileScreen: View {

    @Environment(\.coordinator) var coordinator: BaseCoordinator?
    @StateObject private var viewModel = ProfileScreenViewModel()

    init() {
        LifecycleLog.view("ProfileScreen", "init")
    }

    var body: some View {

        let _ = print(coordinator as Any)

        VStack(spacing: 20) {

            Text("Profile Root")

            Button("Go Bio") { self.coordinator?.router.push(ProfileCoordinator.Destination.bio) }
            Button("Go Security") { self.coordinator?.router.push(ProfileCoordinator.Destination.security) }

            Divider()

            Button("Finish Flow") { self.coordinator?.finish() }
        }
        .padding()
        .lifecycle("ProfileScreen")
        .task {
            LifecycleLog.viewTask("ProfileScreen", "task begin -> viewModel.logInit()")
            self.viewModel.logInit()
        }

    }

}

// -----------------------------------
// MARK: - Profile Bio / Security
// -----------------------------------

@MainActor
final class ProfileBioViewModel: LifecycleViewModel {
    init() { super.init(logName: "ProfileBioViewModel") }
}

struct ProfileBioView: View {

    let coordinator: ProfileCoordinator
    @StateObject private var viewModel = ProfileBioViewModel()

    init(coordinator: ProfileCoordinator) {
        self.coordinator = coordinator
        LifecycleLog.view("ProfileBioView", "init")
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("User Bio Screen")
            Button("PopToSelf & Finish") {
                self.coordinator.finish()
            }
        }
        .padding()
        .lifecycle("ProfileBioView")
        .task {
            LifecycleLog.viewTask("ProfileBioView", "task begin -> viewModel.logInit()")
            self.viewModel.logInit()
        }
    }

}

@MainActor
final class ProfileSecurityViewModel: LifecycleViewModel {
    init() { super.init(logName: "ProfileSecurityViewModel") }
}

struct ProfileSecurityView: View {

    let coordinator: ProfileCoordinator
    @StateObject private var viewModel = ProfileSecurityViewModel()

    init(coordinator: ProfileCoordinator) {
        self.coordinator = coordinator
        LifecycleLog.view("ProfileSecurityView", "init")
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Security Settings Screen")
            Button("Finish") { self.coordinator.finish() }
        }
        .padding()
        .lifecycle("ProfileSecurityView")
        .task {
            LifecycleLog.viewTask("ProfileSecurityView", "task begin -> viewModel.logInit()")
            self.viewModel.logInit()
        }
    }

}

// -----------------------------------
// MARK: - Settings Root / Detail
// -----------------------------------

@MainActor
final class SettingsRootViewModel: LifecycleViewModel {
    init() { super.init(logName: "SettingsRootViewModel") }
}

struct SettingsRootView: View {

    let coordinator: SettingsCoordinator
    @StateObject private var viewModel = SettingsRootViewModel()

    init(coordinator: SettingsCoordinator) {
        self.coordinator = coordinator
        LifecycleLog.view("SettingsRootView", "init")
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings Root")

            Button("Go General") { self.coordinator.navigation.push(.general) }
            Button("Go Advanced") { self.coordinator.navigation.push(.advanced) }

            Divider()

            Button("Finish & Detach") { self.coordinator.finish() }
        }
        .padding()
        .lifecycle("SettingsRootView")
        .task {
            LifecycleLog.viewTask("SettingsRootView", "task begin -> viewModel.logInit()")
            self.viewModel.logInit()
        }
    }

}

@MainActor
final class SettingsDetailViewModel: LifecycleViewModel {
    init() { super.init(logName: "SettingsDetailViewModel") }
}

struct SettingsDetailView: View {

    let coordinator: SettingsCoordinator
    let route: SettingsCoordinator.Destination
    @StateObject private var viewModel = SettingsDetailViewModel()

    init(coordinator: SettingsCoordinator, route: SettingsCoordinator.Destination) {
        self.coordinator = coordinator
        self.route = route
        LifecycleLog.view("SettingsDetailView", "init (route: \(route))")
    }

    var body: some View {
        VStack(spacing: 20) {

            Text(route == .general ? "General Settings" : "Advanced Settings")

            Button("Pop To Self") {
                self.coordinator.navigation.popToSelf()
            }

            if route == .general {
                Button("Push Advanced") { self.coordinator.navigation.push(.advanced) }
            }

            Divider()

            Button("Pop") {
                self.coordinator.navigation.pop()
            }
        }
        .padding()
        .lifecycle("SettingsDetailView")
        .task {
            LifecycleLog.viewTask("SettingsDetailView", "task begin -> viewModel.logInit()")
            self.viewModel.logInit()
        }
    }

}

// -----------------------------------
// MARK: - Home Modal Root
// -----------------------------------

@MainActor
final class HomeModalRootViewModel: LifecycleViewModel {
    init() { super.init(logName: "HomeModalRootViewModel") }
}

struct HomeModalRootView: View {

    let coordinator: HomeModalCoordinator
    @StateObject private var viewModel = HomeModalRootViewModel()

    init(coordinator: HomeModalCoordinator) {
        self.coordinator = coordinator
        LifecycleLog.view("HomeModalRootView", "init")
    }

    var body: some View {
        VStack {
            Text("Home Modal Flow")
            Button("Finish") { self.coordinator.finish() }
        }
        .lifecycle("HomeModalRootView")
        .task {
            LifecycleLog.viewTask("HomeModalRootView", "task begin -> viewModel.logInit()")
            self.viewModel.logInit()
        }
    }

}

// -----------------------------------
// MARK: - Support Root
// -----------------------------------

@MainActor
final class SupportRootViewModel: LifecycleViewModel {
    init() { super.init(logName: "SupportRootViewModel") }
}

struct SupportRootView: View {

    let coordinator: SupportCoordinator
    @StateObject private var viewModel = SupportRootViewModel()

    init(coordinator: SupportCoordinator) {
        self.coordinator = coordinator
        LifecycleLog.view("SupportRootView", "init")
    }

    var body: some View {
        VStack {
            Text("Support Sheet")
            Button("Dismiss") { self.coordinator.finish() }
        }
        .lifecycle("SupportRootView")
        .task {
            LifecycleLog.viewTask("SupportRootView", "task begin -> viewModel.logInit()")
            self.viewModel.logInit()
        }
    }

}

// -----------------------------------
// MARK: - Team Root
// -----------------------------------

@MainActor
final class TeamRootViewModel: LifecycleViewModel {
    init() { super.init(logName: "TeamRootViewModel") }
}

struct TeamRootView: View {

    let coordinator: TeamCoordinator
    let route: TeamCoordinator.Route
    @StateObject private var viewModel = TeamRootViewModel()

    init(coordinator: TeamCoordinator, route: TeamCoordinator.Route) {
        self.coordinator = coordinator
        self.route = route
        LifecycleLog.view("TeamRootView", "init (route: \(route))")
    }

    var body: some View {
        VStack(spacing: 20) {
            switch route {
            case .members: Text("All Team Members")
            case .memberDetails(let id): Text("Showing Details for: \(id)")
            case .stats: Text("Team Statistics")
            }

            Button("Finish") { self.coordinator.finish() }
        }
        .lifecycle("TeamRootView")
        .task {
            LifecycleLog.viewTask("TeamRootView", "task begin -> viewModel.logInit()")
            self.viewModel.logInit()
        }
    }

}

// -----------------------------------
// MARK: - Sako Root
// -----------------------------------

@MainActor
final class SakoRootViewModel: LifecycleViewModel {
    init() { super.init(logName: "SakoRootViewModel") }
}

struct SakoRootView: View {

    @StateObject private var viewModel = SakoRootViewModel()

    init() {
        LifecycleLog.view("SakoRootView", "init")
    }

    var body: some View {
        Text("Sako Coordinator Root")
            .lifecycle("SakoRootView")
            .task {
                LifecycleLog.viewTask("SakoRootView", "task begin -> viewModel.logInit()")
                self.viewModel.logInit()
            }
    }

}

// -----------------------------------
// MARK: - DetailScreen
// -----------------------------------

@MainActor
final class DetailScreenViewModel: LifecycleViewModel {
    init() { super.init(logName: "DetailScreenViewModel") }
}

struct DetailScreen: View {

    let text: String
    @StateObject private var viewModel = DetailScreenViewModel()

    init(text: String) {
        self.text = text
        LifecycleLog.view("DetailScreen", "init (text: \(text))")
    }

    var body: some View {
        VStack {
            Text(text).font(.largeTitle)
        }
        .navigationTitle("Details")
        .lifecycle("DetailScreen")
        .task {
            LifecycleLog.viewTask("DetailScreen", "task begin -> viewModel.logInit()")
            self.viewModel.logInit()
        }
    }

}

// **********************************
// MARK: - Preview (KEEP EXISTING)
// **********************************

#Preview {
    AppCoordinator().start()
}

// **********************************
// MARK: - Nested Full Screen A
// **********************************

@MainActor
@Observable
final class NestedFullScreenACoordinator: BaseCoordinator, Coordinator {

    typealias Route = Destination
    typealias ModalRoute = Modal

    enum Destination: Routable {
        case root
        case step(String)

        var id: String {
            switch self {
            case .root: return "root"
            case .step(let value): return "step_\(value)"
            }
        }
    }

    enum Modal: Routable {
        case nestedFullScreenB

        var id: String {
            switch self {
            case .nestedFullScreenB: return "nestedFullScreenB"
            }
        }
    }

    @ViewBuilder
    func start(context: NavigationContext) -> some View {

        CoordinatorHost(router: self.router, context: context, coordinator: self) {

            NestedFullScreenARootView(coordinator: self)
                .navigationTitle("Full Screen A")
                .navigationDestination(for: Route.self) { route in
                    self.build(route)
                }
                .coordinatorFullScreen(Modal.self, router: self.router) { route in
                    self.buildModal(route)
                }

        }

    }

    @ViewBuilder
    func build(_ route: Route) -> some View {

        switch route {

        case .root:
            NestedFullScreenARootView(coordinator: self)

        case .step(let value):
            VStack(spacing: 16) {
                Text("A Step: \(value)")

                Button("Push Next") {
                    self.navigation.push(.step("\(value)+1"))
                }

                Button("Pop") {
                    self.navigation.pop()
                }

                Button("Pop To Self") {
                    self.navigation.popToSelf()
                }

                Divider()

                Button("Finish (Dismiss A)") {
                    self.finish()
                }
            }
            .padding()

        }

    }

    @ViewBuilder
    func buildModal(_ route: Modal) -> some View {

        switch route {

        case .nestedFullScreenB:

            let flowB = self.child(id: route) {
                NestedFullScreenBCoordinator(
                    parent: self,
                    router: Router(
                        coordinatorName: "NestedFullScreenBCoordinator",
                        navigation: self.router.navigation,
                        presentation: self.router.presentation
                    ),
                    finishPolicy: .dismissModal
                )
            }

            flowB.start(context: .standalone)

        }

    }

}

private struct NestedFullScreenARootView: View {

    let coordinator: NestedFullScreenACoordinator

    var body: some View {
        VStack(spacing: 16) {
            Text("Full Screen A Root")

            Button("Push A Step 1") {
                self.coordinator.navigation.push(.step("1"))
            }

            Divider()

            Button("Present Full Screen B") {
                self.coordinator.presentation.fullScreen(.nestedFullScreenB)
            }

            Divider()

            Button("Finish (Dismiss A)") {
                self.coordinator.finish()
            }
        }
        .padding()
    }
}

// **********************************
// MARK: - Nested Full Screen B
// **********************************

@MainActor
@Observable
final class NestedFullScreenBCoordinator: BaseCoordinator, Coordinator {

    typealias Route = Destination
    typealias ModalRoute = Destination

    enum Destination: Routable {
        case root
        case step(String)

        var id: String {
            switch self {
            case .root: return "root"
            case .step(let value): return "step_\(value)"
            }
        }
    }

    @ViewBuilder
    func start(context: NavigationContext) -> some View {

        CoordinatorHost(router: self.router, context: context, coordinator: self) {

            NestedFullScreenBRootView(coordinator: self)
                .navigationTitle("Full Screen B")
                .navigationDestination(for: Route.self) { route in
                    self.build(route)
                }

        }

    }

    @ViewBuilder
    func build(_ route: Route) -> some View {

        switch route {

        case .root:
            NestedFullScreenBRootView(coordinator: self)

        case .step(let value):
            VStack(spacing: 16) {
                Text("B Step: \(value)")

                Button("Push Next") {
                    self.navigation.push(.step("\(value)+1"))
                }

                Button("Pop") {
                    self.navigation.pop()
                }

                Button("Pop To Self") {
                    self.navigation.popToSelf()
                }

                Divider()

                Button("Finish (Dismiss B)") {
                    self.finish()
                }
            }
            .padding()

        }

    }

}

private struct NestedFullScreenBRootView: View {

    let coordinator: NestedFullScreenBCoordinator

    var body: some View {
        VStack(spacing: 16) {
            Text("Full Screen B Root")

            Button("Push B Step 1") {
                self.coordinator.navigation.push(.step("1"))
            }

            Divider()

            Button("Finish (Dismiss B)") {
                self.coordinator.finish()
            }
        }
        .padding()
    }
}

// **********************************
// MARK: - Nested Sheet A
// **********************************

@MainActor
@Observable
final class NestedSheetACoordinator: BaseCoordinator, Coordinator {

    typealias Route = Destination
    typealias ModalRoute = Modal

    enum Destination: Routable {
        case root
        case screen(String)

        var id: String {
            switch self {
            case .root: return "root"
            case .screen(let v): return "screen_\(v)"
            }
        }
    }

    enum Modal: Routable {
        case nestedSheetB

        var id: String {
            switch self {
            case .nestedSheetB: return "nestedSheetB"
            }
        }
    }

    @ViewBuilder
    func start(context: NavigationContext) -> some View {

        CoordinatorHost(router: self.router, context: context, coordinator: self) {

            NestedSheetARootView(coordinator: self)
                .navigationTitle("Sheet A")
                .navigationDestination(for: Route.self) { route in
                    self.build(route)
                }
                .coordinatorSheet(Modal.self, router: self.router) { route in
                    self.buildModal(route)
                }

        }

    }

    @ViewBuilder
    func build(_ route: Route) -> some View {

        switch route {

        case .root:
            NestedSheetARootView(coordinator: self)

        case .screen(let v):
            VStack(spacing: 16) {
                Text("Sheet A Screen: \(v)")

                Button("Push Next") {
                    self.navigation.push(.screen("\(v)+1"))
                }

                Button("Pop") {
                    self.navigation.pop()
                }

                Button("Pop To Self") {
                    self.navigation.popToSelf()
                }

                Divider()

                Button("Present Sheet B") {
                    self.presentation.sheet(.nestedSheetB)
                }

                Divider()

                Button("Finish (Dismiss Sheet A)") {
                    self.finish()
                }
            }
            .padding()

        }

    }

    @ViewBuilder
    func buildModal(_ route: Modal) -> some View {

        switch route {

        case .nestedSheetB:

            let sheetB = self.child(id: route) {
                NestedSheetBCoordinator(
                    parent: self,
                    router: Router(
                        coordinatorName: "NestedSheetBCoordinator",
                        navigation: self.router.navigation,
                        presentation: self.router.presentation
                    ),
                    finishPolicy: .dismissModal
                )
            }

            sheetB.start(context: .standalone)

        }

    }

}

private struct NestedSheetARootView: View {

    let coordinator: NestedSheetACoordinator

    var body: some View {
        VStack(spacing: 16) {
            Text("Sheet A Root")

            Button("Push Screen 1") {
                self.coordinator.navigation.push(.screen("1"))
            }

            Divider()

            Button("Present Sheet B") {
                self.coordinator.presentation.sheet(.nestedSheetB)
            }

            Divider()

            Button("Finish (Dismiss Sheet A)") {
                self.coordinator.finish()
            }
        }
        .padding()
    }
}

// **********************************
// MARK: - Nested Sheet B
// **********************************

@MainActor
@Observable
final class NestedSheetBCoordinator: BaseCoordinator, Coordinator {

    enum Route: Routable {
        case root
        case screen(String)

        var id: String {
            switch self {
            case .root: return "root"
            case .screen(let v): return "screen_\(v)"
            }
        }
    }

    @ViewBuilder
    func start(context: NavigationContext) -> some View {

        CoordinatorHost(router: self.router, context: context, coordinator: self) {

            NestedSheetBRootView(coordinator: self)
                .navigationTitle("Sheet B")
                .navigationDestination(for: Route.self) { route in
                    self.build(route)
                }

        }

    }

    @ViewBuilder
    func build(_ route: Route) -> some View {

        switch route {

        case .root:
            NestedSheetBRootView(coordinator: self)

        case .screen(let v):
            VStack(spacing: 16) {
                Text("Sheet B Screen: \(v)")

                Button("Push Next") {
                    self.navigation.push(.screen("\(v)+1"))
                }

                Button("Pop") {
                    self.navigation.pop()
                }

                Button("Pop To Self") {
                    self.navigation.popToSelf()
                }

                Divider()

                Button("Finish (Dismiss Sheet B)") {
                    self.finish()
                }
            }
            .padding()

        }

    }

}

private struct NestedSheetBRootView: View {

    let coordinator: NestedSheetBCoordinator

    var body: some View {
        VStack(spacing: 16) {
            Text("Sheet B Root")

            Button("Push Screen 1") {
                self.coordinator.navigation.push(.screen("1"))
            }

            Divider()

            Button("Finish (Dismiss Sheet B)") {
                self.coordinator.finish()
            }
        }
        .padding()
    }
}

// **********************************
// MARK: - HomeViewTest Buttons (Additive)
// **********************************
//
// Add these two buttons inside your existing "Modal Presentation" section:
//
// Button("Nested Full Screen Flow") {
//     self.coordinator.presentation.fullScreen(.nestedFullScreenA)
// }
//
// Button("Nested Sheet Flow") {
//     self.coordinator.presentation.sheet(.nestedSheetA)
// }

// **********************************
// MARK: - Additional Previews (Do Not Remove Existing)
// **********************************

#Preview("Nested Full Screen A (Direct)") {
    let router = Router(coordinatorName: "Preview_NestedFullScreenA")
    let coordinator = NestedFullScreenACoordinator(
        parent: nil,
        router: router,
        finishPolicy: .dismissModal
    )
    return coordinator.start(context: .standalone)
}

#Preview("Nested Sheet A (Direct)") {
    let router = Router(coordinatorName: "Preview_NestedSheetA")
    let coordinator = NestedSheetACoordinator(
        parent: nil,
        router: router,
        finishPolicy: .dismissModal
    )
    return coordinator.start(context: .standalone)
}
