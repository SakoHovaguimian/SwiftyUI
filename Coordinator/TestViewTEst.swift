//
//  VertigoFinal.swift
//  CoordinatorPattern
//
//  Created by Sako Hovaguimian on 1/18/26.
//  Architected by Gemini.
//

import SwiftUI
import Observation

// ***************************************************************
// MARK: - 1. CORE ARCHITECTURE
// ***************************************************************

@MainActor
public protocol Routable: Hashable, Identifiable {
    var id: String { get }
}

/// Concrete Type Erasure for Routes (Preserves ID for SwiftUI Bindings)
@MainActor
public struct AnyRoutable: Routable {
    public let id: String
    private let _base: AnyHashable
    
    public init<T: Routable>(_ base: T) {
        self.id = base.id
        self._base = AnyHashable(base)
    }
    
    public func hash(into hasher: inout Hasher) { _base.hash(into: &hasher) }
    public static func == (lhs: AnyRoutable, rhs: AnyRoutable) -> Bool { return lhs._base == rhs._base }
    public func `as`<T: Routable>(_ type: T.Type) -> T? { return _base as? T }
}

@MainActor
@Observable
public final class Router {
    
    public var path: [AnyRoutable] = []
    public var sheet: AnyRoutable?
    public var fullScreenCover: AnyRoutable?
    public var dismissRequest: Bool = false
    
    public private(set) var coordinatorScopes: [UUID: Int] = [:]
    private var viewResolvers: [UUID: (AnyRoutable) -> AnyView?] = [:]
    
    public init() {}
    
    // MARK: - Navigation
    
    public func push(_ route: any Routable, from id: UUID, isEmbedded: Bool) {
        trackScope(id: id, isEmbedded: isEmbedded)
        path.append(AnyRoutable(route))
    }
    
    public func push(_ routes: [any Routable], from id: UUID, isEmbedded: Bool) {
        guard !routes.isEmpty else { return }
        trackScope(id: id, isEmbedded: isEmbedded)
        path.append(contentsOf: routes.map { AnyRoutable($0) })
    }
    
    private func trackScope(id: UUID, isEmbedded: Bool) {
        // We only mark the "start" of a coordinator when it performs its first push
        if isEmbedded && coordinatorScopes[id] == nil {
            coordinatorScopes[id] = path.count
        }
    }
    
    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast(); pruneScopes()
    }
    
    public func popToRoot() {
        // Find the deepest active coordinator scope
        guard let deepestScope = coordinatorScopes.max(by: { $0.value < $1.value }) else {
            popAll()
            return
        }
        
        let targetCount = deepestScope.value
        if path.count > targetCount {
            path.removeLast(path.count - targetCount)
        }
        pruneScopes()
    }
    
    public func popAll() {
        path.removeAll(); pruneScopes()
    }
    
    public func popToSelf(from id: UUID) {
        if let startIndex = coordinatorScopes[id] {
            // Case A: This coordinator has pushed children.
            // We want to remove the children AND the start of the coordinator.
            // StartIndex is where children began. So StartIndex - 1 is the coordinator itself.
            let targetCount = max(0, startIndex - 1)
            let countToRemove = path.count - targetCount
            
            if countToRemove > 0 {
                path.removeLast(countToRemove)
            }
        } else {
            // Case B (THE FIX): This coordinator hasn't pushed any children yet.
            // It is likely the top-most view. We just pop once.
            pop()
        }
        pruneScopes()
    }
    
    public func replace(last count: Int, with route: any Routable) {
        let safeCount = min(path.count, count)
        if safeCount > 0 { path.removeLast(safeCount) }
        path.append(AnyRoutable(route)); pruneScopes()
    }
    
    // MARK: - Presentation
    
    public func presentSheet(_ route: any Routable) { self.sheet = AnyRoutable(route) }
    public func presentFullScreen(_ route: any Routable) { self.fullScreenCover = AnyRoutable(route) }
    
    public func dismiss() {
        if fullScreenCover != nil { fullScreenCover = nil; return }
        if sheet != nil { sheet = nil; return }
        dismissRequest = true
    }
    
    // MARK: - Resolution
    
    public func registerResolver(_ id: UUID, resolver: @escaping (AnyRoutable) -> AnyView?) {
        viewResolvers[id] = resolver
    }
    
    public func resolve(route: AnyRoutable) -> AnyView {
        let sortedScopes = coordinatorScopes.sorted { $0.value > $1.value }
        for (id, _) in sortedScopes {
            if let builder = viewResolvers[id], let view = builder(route) { return view }
        }
        for (_, builder) in viewResolvers {
            if let view = builder(route) { return view }
        }
        return AnyView(Text("❌ Unhandled: \(route.id)").frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.red.opacity(0.1)))
    }
    
    public func handleNativePopIfNeeded() { pruneScopes() }
    
    private func pruneScopes() {
        let currentPathCount = path.count
        let deadIDs = coordinatorScopes.filter { $0.value > currentPathCount }.map { $0.key }
        for id in deadIDs { coordinatorScopes.removeValue(forKey: id); viewResolvers.removeValue(forKey: id) }
    }
}

// MARK: - 3. COORDINATOR PROTOCOL

@MainActor
public protocol Coordinator: AnyObject, Identifiable {
    var id: UUID { get }
    var router: Router { get set }
    var isRoot: Bool { get }
    
    associatedtype Route: Routable
    associatedtype ContentView: View
    
    func start() -> ContentView
    func build(_ route: Route) -> AnyView?
    func buildModal(_ route: Route) -> AnyView?
}

extension Coordinator {
    public var id: UUID { UUID() }
    
    public func push(_ route: Route) { router.push(route, from: id, isEmbedded: !isRoot) }
    public func push(_ routes: [Route]) { router.push(routes, from: id, isEmbedded: !isRoot) }
    
    public func pop() { router.pop() }
    public func popToRoot() { router.popToRoot() }
    public func popAll() { router.popAll() }
    public func popToSelf() { router.popToSelf(from: id) }
    public func replace(last count: Int = 1, with route: Route) { router.replace(last: count, with: route) }
    
    public func sheet(_ route: Route) { router.presentSheet(route) }
    public func fullScreen(_ route: Route) { router.presentFullScreen(route) }
    public func dismiss() { router.dismiss() }
    public func finish() { if isRoot { router.dismiss() } else { popToSelf() } }
    
    public func registerSelf() {
        router.registerResolver(id) { [weak self] anyRoute in
            guard let self = self, let specific = anyRoute.as(Route.self) else { return nil }
            if let view = self.build(specific) { return view }
            return self.buildModal(specific)
        }
    }
}

// MARK: - 4. COORDINATOR HOST (Dumb Bindings)

public struct CoordinatorHost<C: Coordinator>: View {
    @State private var coordinator: C
    @Environment(\.dismiss) private var dismiss
    
    public init(_ coordinator: C) { self.coordinator = coordinator }
    
    public var body: some View {
        Group {
            if coordinator.isRoot { NavigationStack(path: $coordinator.router.path) { content } }
            else { content }
        }
        .task { coordinator.registerSelf() }
        .onChange(of: coordinator.router.path) { _, _ in coordinator.router.handleNativePopIfNeeded() }
        .onChange(of: coordinator.router.dismissRequest) { _, should in
            if should && coordinator.isRoot { dismiss(); coordinator.router.dismissRequest = false }
        }
    }
    
    @ViewBuilder private var content: some View {
        coordinator.start()
            .navigationDestination(for: AnyRoutable.self) { coordinator.router.resolve(route: $0) }
            // ✅ Dumb Binding: Syncs state without triggering side-effect logic
            .sheet(item: Binding(
                get: { coordinator.router.sheet },
                set: { coordinator.router.sheet = $0 }
            )) { coordinator.router.resolve(route: $0) }
            .fullScreenCover(item: Binding(
                get: { coordinator.router.fullScreenCover },
                set: { coordinator.router.fullScreenCover = $0 }
            )) { coordinator.router.resolve(route: $0) }
    }
}

// ***************************************************************
// MARK: - 5. SHOWCASE IMPLEMENTATION
// ***************************************************************

// --- 1. APP ROOT ---
class AppCoordinator: Coordinator {
    enum Route: Routable {
        case authFlow
        public var id: String { String(describing: self) }
    }
    
    // Root Coordinator always has a fresh router
    var router = Router()
    let isRoot = true
    
    func start() -> some View {
        // App Root usually starts the first flow immediately
        CoordinatorHost(AuthCoordinator(router: router))
    }
    
    func build(_ route: Route) -> AnyView? {
        // Auth is embedded, it shares this router.
        // It might push routes that bubble up here, or handle them itself.
        return nil
    }
    func buildModal(_ route: Route) -> AnyView? { nil }
}

class AuthCoordinator: Coordinator {
    enum Route: Routable {
        case login, forgotPassword, dashboard
        public var id: String { String(describing: self) }
    }
    
    var router: Router
    let isRoot: Bool
    
    init(router: Router? = nil) {
        if let router { self.router = router; self.isRoot = false }
        else { self.router = Router(); self.isRoot = true }
    }
    
    func start() -> some View {
        Screen(title: "🔒 Login", color: .black) {
            Button("Log In (Push Dashboard)") { self.push(.dashboard) }
                .tint(.green)
            Button("Forgot Password (Sheet)") { self.sheet(.forgotPassword) }
        }
        .overlay(alignment: .bottom) { DebugOverlay(router: router, name: "AUTH") }
    }
    
    func build(_ route: Route) -> AnyView? {
        switch route {
        case .dashboard:
            // ✅ CRITICAL: Must pass 'self.router' to embed it
            return AnyView(CoordinatorHost(DashboardCoordinator(router: router)))
        default: return nil
        }
    }
    
    func buildModal(_ route: Route) -> AnyView? {
        switch route {
        case .forgotPassword:
            // ✅ CRITICAL: Pass 'nil' (or don't pass anything) to make it a new Modal Root
            return AnyView(CoordinatorHost(ForgotPasswordCoordinator()))
        default: return nil
        }
    }
}

// --- 3. FORGOT PASSWORD (Modal) ---
class ForgotPasswordCoordinator: Coordinator {
    enum Route: Routable { case sent; var id: String { "sent" } }
    
    var router: Router
    let isRoot: Bool
    
    init(router: Router? = nil) {
        if let router { self.router = router; self.isRoot = false }
        else { self.router = Router(); self.isRoot = true }
    }
    
    func start() -> some View {
        Screen(title: "Reset Password", color: .gray) {
            Button("Send Email") { self.push(.sent) }
            Button("Cancel") { self.dismiss() }
        }
        .overlay(alignment: .bottom) { DebugOverlay(router: router, name: "FORGOT PW") }
    }
    
    func build(_ route: Route) -> AnyView? {
        return AnyView(Screen(title: "Email Sent", color: .green) {
            Button("Done") { self.finish() }
        })
    }
    func buildModal(_ route: Route) -> AnyView? { nil }
}

// --- 4. DASHBOARD (Linear) ---
class DashboardCoordinator: Coordinator {
    enum Route: Routable {
        case detail(Int), settings, wizard
        public var id: String { String(describing: self) }
    }
    
    var router: Router
    let isRoot: Bool
    
    // ✅ Logic: If I get a router, I join the stack (isRoot=false).
    init(router: Router? = nil) {
        if let router { self.router = router; self.isRoot = false }
        else { self.router = Router(); self.isRoot = true }
    }
    
    func start() -> some View {
        Screen(title: "🏠 Dashboard", color: .blue) {
            Section("Content") {
                Button("Item 1") { self.push(.detail(1)) }
            }
            Section("Flows") {
                Button("Wizard (Push)") { self.push(.wizard) }
                Button("Settings (Sheet)") { self.sheet(.settings) }
            }
            Section("Session") {
                // ✅ Now works due to Case B in popToSelf
                Button("Log Out (Pop Self)") { self.popToSelf() }
                    .tint(.red)
            }
        }
        .overlay(alignment: .bottom) { DebugOverlay(router: router, name: "DASHBOARD") }
    }
    
    func build(_ route: Route) -> AnyView? {
        switch route {
        case .detail(let i):
            return AnyView(Screen(title: "Item \(i)", color: .blue.opacity(0.8)) {
                Button("Next") { self.push(.detail(i + 1)) }
                Button("Pop to Dashboard") { self.popToRoot() }
            })
        case .wizard:
            return AnyView(CoordinatorHost(WizardCoordinator(router: router)))
        default: return nil
        }
    }
    
    func buildModal(_ route: Route) -> AnyView? {
        switch route {
        case .settings:
            return AnyView(CoordinatorHost(SettingsCoordinator()))
        default: return nil
        }
    }
}

// --- 5. SETTINGS (Modal) ---
class SettingsCoordinator: Coordinator {
    enum Route: Routable { case profile, danger; var id: String { String(describing: self) } }
    
    var router: Router
    let isRoot: Bool
    
    init(router: Router? = nil) {
        if let router { self.router = router; self.isRoot = false }
        else { self.router = Router(); self.isRoot = true }
    }
    
    func start() -> some View {
        Screen(title: "⚙️ Settings", color: .orange) {
            Button("Profile") { self.push(.profile) }
            Button("Danger Zone (Deep Modal)") { self.fullScreen(.danger) }
            Button("Done") { self.dismiss() }
        }
        .overlay(alignment: .bottom) { DebugOverlay(router: router, name: "SETTINGS") }
    }
    
    func build(_ route: Route) -> AnyView? {
        switch route {
        case .profile:
            return AnyView(Screen(title: "Profile", color: .orange.opacity(0.7)) {
                Text("User Info")
            })
        default: return nil
        }
    }
    
    func buildModal(_ route: Route) -> AnyView? {
        switch route {
        case .danger:
            return AnyView(CoordinatorHost(DangerZoneCoordinator()))
        default: return nil
        }
    }
}

// --- 6. DANGER ZONE (Level 2 Modal) ---
class DangerZoneCoordinator: Coordinator {
    enum Route: Routable { case none; var id: String { "none" } }
    
    var router: Router
    let isRoot: Bool
    
    init(router: Router? = nil) {
        if let router { self.router = router; self.isRoot = false }
        else { self.router = Router(); self.isRoot = true }
    }
    
    func start() -> some View {
        Screen(title: "☢️ Danger Zone", color: .red) {
            Text("I am a Full Screen Cover on top of a Sheet.")
            Button("Escape (Dismiss)") { self.dismiss() }
        }
        .overlay(alignment: .bottom) { DebugOverlay(router: router, name: "DANGER") }
    }
    func build(_ route: Route) -> AnyView? { nil }
    func buildModal(_ route: Route) -> AnyView? { nil }
}

// --- 7. WIZARD (Linear) ---
class WizardCoordinator: Coordinator {
    enum Route: Routable { case step2, finish; var id: String { String(describing: self) } }
    
    var router: Router
    let isRoot: Bool
    
    init(router: Router? = nil) {
        if let router { self.router = router; self.isRoot = false }
        else { self.router = Router(); self.isRoot = true }
    }
    
    func start() -> some View {
        Screen(title: "🧙‍♂️ Wizard Start", color: .purple) {
            Button("Step 2") { self.push(.step2) }
            // ✅ Now works due to Case B in popToSelf
            Button("Exit Wizard") { self.finish() }
        }
        .overlay(alignment: .bottom) { DebugOverlay(router: router, name: "WIZARD") }
    }
    
    func build(_ route: Route) -> AnyView? {
        switch route {
        case .step2:
            return AnyView(Screen(title: "Step 2", color: .purple.opacity(0.7)) {
                Button("Finish (Swap)") { self.replace(with: .finish) }
            })
        case .finish:
            return AnyView(Screen(title: "Done!", color: .green) {
                Button("Complete") { self.finish() }
            })
        }
    }
    func buildModal(_ route: Route) -> AnyView? { nil }
}

// ***************************************************************
// MARK: - 6. UI HELPERS
// ***************************************************************

struct Screen<Content: View>: View {
    let title: String; let color: Color; @ViewBuilder let content: Content
    var body: some View {
        ZStack {
            color.opacity(0.2).ignoresSafeArea()
            VStack(spacing: 20) {
                Text(title).font(.largeTitle).bold()
                content.buttonStyle(.borderedProminent).controlSize(.large)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
    }
}

struct DebugOverlay: View {
    var router: Router; let name: String
    var body: some View {
        HStack {
            Circle().fill(Color.green).frame(width: 8, height: 8)
            Text(name).bold().font(.caption)
            Spacer()
            Text("Stack: \(router.path.count)").font(.caption2).monospaced()
        }
        .padding(8).background(.thinMaterial).cornerRadius(8).padding()
    }
}

#Preview {
    CoordinatorHost(AppCoordinator())
}
