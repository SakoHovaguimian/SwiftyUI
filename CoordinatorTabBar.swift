import SwiftUI
import Observation

// **********************************
// MARK: - Tab App Coordinator
// **********************************

@MainActor
@Observable
final class TabAppCoordinator: BaseCoordinator {
    enum RootFlow { case mainTab }

    init() {
        super.init(parent: nil, router: Router(coordinatorName: "TabAppCoordinator"))
    }
    
    override func start(context: NavigationContext) -> AnyView {
        let mainTab = self.child(id: RootFlow.mainTab) {
            PrimaryTabCoordinator(parent: self, router: Router(coordinatorName: "PrimaryTabCoordinator"))
        }
        return mainTab.eraseStart(context: .standalone)
    }
}

// **********************************
// MARK: - Primary Tab Coordinator
// **********************************

@MainActor
@Observable
final class PrimaryTabCoordinator: BaseCoordinator {
    enum Tab: Hashable, CaseIterable {
        case dashboard, search, account
        var title: String { "\(self)".capitalized }
        var icon: String {
            switch self {
            case .dashboard: return "square.grid.2x2"
            case .search: return "magnifyingglass"
            case .account: return "person.crop.circle"
            }
        }
    }

    public var selectedTab: Tab = .dashboard

    override func start(context: NavigationContext) -> AnyView {
        AnyView(
            TabView(selection: Bindable(self).selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    self.tabView(for: tab)
                        .tabItem { Label(tab.title, systemImage: tab.icon) }
                        .tag(tab)
                }
            }
        )
    }

    @ViewBuilder
    private func tabView(for tab: Tab) -> some View {
        switch tab {
        case .dashboard:
            self.child(id: Tab.dashboard) {
                DashboardCoordinator(parent: self, router: Router(coordinatorName: "Dashboard"))
            }.start(context: .standalone)
        case .search:
            self.child(id: Tab.search) {
                SearchCoordinator(parent: self, router: Router(coordinatorName: "Search"))
            }.start(context: .standalone)
        case .account:
            self.child(id: Tab.account) {
                AccountCoordinator(parent: self, router: Router(coordinatorName: "Account"))
            }.start(context: .standalone)
        }
    }
    
    func changeTab(to tab: Tab) { self.selectedTab = tab }
}

// **********************************
// MARK: - Dashboard Coordinator (Deep Pushing)
// **********************************

@MainActor
@Observable
final class DashboardCoordinator: BaseCoordinator {
    enum Destination: Routable {
        case detail(level: Int)
        case settings
        var id: String {
            switch self {
            case .detail(let level): return "detail_\(level)"
            case .settings: return "settings"
            }
        }
    }

    override func start(context: NavigationContext) -> AnyView {
        AnyView(
            CoordinatorHost(router: self.router, context: context) {
                DashboardRootView(coordinator: self)
                    .navigationDestination(for: Destination.self) { self.eraseBuild($0) }
            }
        )
    }
    
    override func build(_ destination: AnyRoutable) -> AnyView {
        guard let dest = destination as? Destination else { return AnyView(EmptyView()) }
        switch dest {
        case .detail(let level):
            return AnyView(DashboardDetailView(coordinator: self, level: level))
        case .settings:
            return AnyView(Text("Dashboard Settings").navigationTitle("Settings"))
        }
    }
}

// **********************************
// MARK: - Search Coordinator (Cross-Tab Jump)
// **********************************

@MainActor
@Observable
final class SearchCoordinator: BaseCoordinator {
    enum Destination: Routable {
        case results(query: String)
        var id: String { "results" }
    }

    override func start(context: NavigationContext) -> AnyView {
        AnyView(
            CoordinatorHost(router: self.router, context: context) {
                SearchView(coordinator: self)
                    .navigationDestination(for: Destination.self) { self.eraseBuild($0) }
            }
        )
    }

    override func build(_ destination: AnyRoutable) -> AnyView {
        guard let dest = destination as? Destination else { return AnyView(EmptyView()) }
        switch dest {
        case .results(let query):
            return AnyView(Text("Results for: \(query)").navigationTitle("Results"))
        }
    }
}

// **********************************
// MARK: - Account Coordinator (Modal + Stack)
// **********************************

@MainActor
@Observable
final class AccountCoordinator: BaseCoordinator {
    enum Destination: Routable {
        case profile, security
        var id: String { "\(self)" }
    }

    override func start(context: NavigationContext) -> AnyView {
        AnyView(
            CoordinatorHost(router: self.router, context: context) {
                AccountRootView(coordinator: self)
                    .navigationDestination(for: Destination.self) { self.eraseBuild($0) }
            }
        )
    }

    override func build(_ destination: AnyRoutable) -> AnyView {
        guard let dest = destination as? Destination else { return AnyView(EmptyView()) }
        return AnyView(Text("\(dest.id)".capitalized).navigationTitle(dest.id.capitalized))
    }
}

// **********************************
// MARK: - Test Views
// **********************************

struct DashboardRootView: View {
    let coordinator: DashboardCoordinator
    var body: some View {
        List {
            Section("Stack Testing") {
                Button("Push Detail (Level 1)") {
                    coordinator.router.push(DashboardCoordinator.Destination.detail(level: 1))
                }
            }
        }
        .navigationTitle("Dashboard")
    }
}

struct DashboardDetailView: View {
    let coordinator: DashboardCoordinator
    let level: Int
    var body: some View {
        VStack(spacing: 20) {
            Text("Stack Level: \(level)").font(.headline)
            
            Button("Push Deeper (Level \(level + 1))") {
                coordinator.router.push(DashboardCoordinator.Destination.detail(level: level + 1))
            }
            
            Button("Pop One Level") { coordinator.router.pop() }
            
            Button("Pop To Root") { coordinator.router.popToRoot() }
            
            Divider()
            
            Button("Jump to Search Tab") {
                (coordinator.parent as? PrimaryTabCoordinator)?.changeTab(to: .search)
            }
        }
        .navigationTitle("Level \(level)")
    }
}

struct SearchView: View {
    let coordinator: SearchCoordinator
    @State private var query = ""
    var body: some View {
        Form {
            TextField("Search query...", text: $query)
            Button("Search") {
                coordinator.router.push(SearchCoordinator.Destination.results(query: query))
            }
        }
        .navigationTitle("Search")
    }
}

struct AccountRootView: View {
    let coordinator: AccountCoordinator
    var body: some View {
        List {
            Button("Profile") { coordinator.router.push(AccountCoordinator.Destination.profile) }
            Button("Security") { coordinator.router.push(AccountCoordinator.Destination.security) }
        }
        .navigationTitle("Account")
    }
}

// **********************************
// MARK: - Preview
// **********************************

#Preview {
    TabAppCoordinator().start(context: .standalone)
}
