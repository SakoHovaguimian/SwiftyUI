import SwiftUI
import Observation

// **********************************
// MARK: - Tab App Coordinator
// **********************************

@MainActor
@Observable
final class TabAppCoordinator: BaseCoordinator, Coordinator {

    enum Route: Routable {
        case mainTab
        var id: String { "mainTab" }
    }

    init() {
        super.init(router: Router(coordinatorName: "TabAppCoordinator"))
    }
    
    @ViewBuilder
    func start(context: NavigationContext = .standalone) -> some View {
        
        let mainTab = self.child(id: "main_tab_container") {
            PrimaryTabCoordinator(parent: self)
        }
        
        mainTab.start(context: .standalone)
        
    }

    @ViewBuilder
    func build(_ route: Route) -> some View {
        EmptyView()
    }

}

// **********************************
// MARK: - Primary Tab Coordinator
// **********************************

@MainActor
@Observable
final class PrimaryTabCoordinator: BaseCoordinator, Coordinator {

    enum Route: Routable {
        case none
        var id: String { "none" }
    }

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

    @ViewBuilder
    func start(context: NavigationContext = .standalone) -> some View {
        
        TabView(selection: Bindable(self).selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                self.viewForTab(tab)
                    .tabItem { Label(tab.title, systemImage: tab.icon) }
                    .tag(tab)
            }
        }
        
    }

    @ViewBuilder
    private func viewForTab(_ tab: Tab) -> some View {
        
        switch tab {
        case .dashboard:
            self.child(id: "tab_dashboard") {
                DashboardCoordinator(parent: self)
            }.start(context: .standalone)

        case .search:
            self.child(id: "tab_search") {
                SearchCoordinator(parent: self)
            }.start(context: .standalone)

        case .account:
            self.child(id: "tab_account") {
                AccountCoordinator(parent: self)
            }.start(context: .standalone)
        }
        
    }
    
    @ViewBuilder
    func build(_ route: Route) -> some View {
        EmptyView()
    }

    func changeTab(to tab: Tab) {
        self.selectedTab = tab
    }
}

// **********************************
// MARK: - Dashboard Coordinator
// **********************************

@MainActor
@Observable
final class DashboardCoordinator: BaseCoordinator, Coordinator {

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

    @ViewBuilder
    func start(context: NavigationContext = .standalone) -> some View {
        
        CoordinatorHost(router: self.router, context: context) {
            DashboardRootView(coordinator: self)
                .navigationDestination(for: Destination.self) { dest in
                    self.build(dest)
                }
        }
        
    }

    @ViewBuilder
    func build(_ route: Destination) -> some View {
        
        switch route {
        case .detail(let level):
            DashboardDetailView(coordinator: self, level: level)
        case .settings:
            Text("Dashboard Settings")
                .navigationTitle("Settings")
        }
        
    }
}

// **********************************
// MARK: - Search Coordinator
// **********************************

@MainActor
@Observable
final class SearchCoordinator: BaseCoordinator, Coordinator {

    enum Destination: Routable {
        case results(query: String)
        var id: String { "results" }
    }

    @ViewBuilder
    func start(context: NavigationContext = .standalone) -> some View {
        
        CoordinatorHost(router: self.router, context: context) {
            SearchView(coordinator: self)
                .navigationDestination(for: Destination.self) { dest in
                    self.build(dest)
                }
        }
        
    }

    @ViewBuilder
    func build(_ route: Destination) -> some View {
        
        switch route {
        case .results(let query):
            Text("Results for: \(query)")
                .navigationTitle("Results")
        }
        
    }
}

// **********************************
// MARK: - Account Coordinator
// **********************************

@MainActor
@Observable
final class AccountCoordinator: BaseCoordinator, Coordinator {

    enum Destination: Routable {
        case profile, security
        var id: String { "\(self)" }
    }

    @ViewBuilder
    func start(context: NavigationContext = .standalone) -> some View {
        
        CoordinatorHost(router: self.router, context: context) {
            AccountRootView(coordinator: self)
                .navigationDestination(for: Destination.self) { dest in
                    self.build(dest)
                }
        }
        
    }

    @ViewBuilder
    func build(_ route: Destination) -> some View {
        Text("\(route.id)".capitalized)
            .navigationTitle(route.id.capitalized)
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
            
            Button("Push Deeper") {
                coordinator.router.push(DashboardCoordinator.Destination.detail(level: level + 1))
            }
            
            Button("Pop One Level") { coordinator.router.pop() }
            Button("Pop To Root") { coordinator.router.popToRoot() }
            
            Divider()
            
            Button("Jump to Search Tab") {
                if let tabParent = coordinator.parent as? PrimaryTabCoordinator {
                    tabParent.changeTab(to: .search)
                }
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
    TabAppCoordinator().start()
}
