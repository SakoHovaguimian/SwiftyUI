import SwiftUI

class TestAppCoordinator: Coordinator {
    
    enum Route: Routable {
        case chaosStart(depth: Int)
        case modalTestStart
        case info
        public var id: String { String(describing: self) }
    }
    
    var router = Router()
    let isRoot = true
    
    func start() -> some View {
        TestScreen(title: "🧪 App Root", color: .gray, depth: 0) {
            Section("Standard Tests") {
                Button("Push Chaos (Nav Stack)") { self.push(.chaosStart(depth: 1)) }
            }
            
            Section("Modal Tests") {
                Button("Present Sheet (New Stack)") { self.sheet(.modalTestStart) }
                Button("Present Full Screen (New Stack)") { self.fullScreen(.modalTestStart) }
            }
        }
        .overlay(alignment: .bottom) { ProDebugOverlay(router: router, myID: id, name: "ROOT (Main)") }
    }
    
    func build(_ route: Route) -> AnyView? {
        switch route {
        case .chaosStart(let depth):
            return AnyView(CoordinatorHost(ChaosCoordinator(router: router, depth: depth)))
        case .info:
            return nil
        case .modalTestStart:
            return nil // ✅ CORRECT: Returns nil here, falls through to buildModal
        }
    }
    
    // ✅ Now this works because registerSelf looks here too!
    func buildModal(_ route: Route) -> AnyView? {
        switch route {
        case .modalTestStart:
            return AnyView(CoordinatorHost(ModalTestCoordinator(depth: 1)))
        default: return nil
        }
    }
}

class ModalTestCoordinator: Coordinator {
    enum Route: Routable {
        case step(Int)
        case deeperModal
        public var id: String { String(describing: self) }
    }
    let id = UUID()
    var router = Router()
    let isRoot = true
    let depth: Int
    
    var color: Color { let c: [Color] = [.mint, .indigo, .teal]; return c[(depth - 1) % c.count] }
    
    init(depth: Int) { self.depth = depth }
    
    func start() -> some View {
        TestScreen(title: "Modal Lvl \(depth)", color: color, depth: depth) {
            Text("Sheet Root")
            Section("Internal") {
                Button("Push Step 1") { self.push(.step(1)) }
            }
            Section("Recursion") {
                Button("Present Deeper") { self.sheet(.deeperModal) }
            }
            Section("Close") {
                Button("Dismiss") { self.dismiss() }
            }
        }
        .overlay(alignment: .bottom) { ProDebugOverlay(router: router, myID: id, name: "Modal \(depth)") }
    }
    
    func build(_ route: Route) -> AnyView? {
        switch route {
        case .step(let n):
            return AnyView(TestScreen(title: "Modal Step \(n)", color: color.opacity(0.8), depth: depth) {
                Button("Next") { self.push(.step(n + 1)) }
                Button("Pop Root") { self.popToRoot() }
            })
        case .deeperModal:
            return nil
        }
    }
    
    func buildModal(_ route: Route) -> AnyView? {
        switch route {
        case .deeperModal:
            return AnyView(CoordinatorHost(ModalTestCoordinator(depth: depth + 1)))
        default: return nil
        }
    }
}

class ChaosCoordinator: Coordinator {
    enum Route: Routable {
        case step(Int)
        case final
        case deeperChaos(Int)
        case swappedRoute
        public var id: String { String(describing: self) }
    }
    
    let id = UUID()
    var router: Router
    let isRoot = false
    let depth: Int
    
    var color: Color { let c: [Color] = [.blue, .purple, .orange, .pink, .green]; return c[(depth - 1) % c.count] }
    
    init(router: Router, depth: Int) { self.router = router; self.depth = depth }
    
    func start() -> some View {
        TestScreen(title: "Chaos Lvl \(depth)", color: color, depth: depth) {
            Text("ID: ...\(id.uuidString.suffix(4))")
            Section("Stack") {
                Button("Push Step 1") { self.push(.step(1)) }
                Button("Batch Push") { self.push([.step(1), .step(2), .final]) }
                Button("Embed Deeper") { self.push(.deeperChaos(self.depth + 1)) }
            }
            Section("Control") {
                Button("Pop") { self.pop() }
                Button("PopToSelf") { self.popToSelf() }
            }
        }
        .overlay(alignment: .bottom) { ProDebugOverlay(router: router, myID: id, name: "Chaos \(depth)") }
    }
    
    func build(_ route: Route) -> AnyView? {
        switch route {
        case .step(let n):
            return AnyView(TestScreen(title: "Step \(n)", color: color.opacity(0.8), depth: depth) {
                Button("Next") { self.push(.step(n + 1)) }
                Button("Replace") { self.replace(with: .swappedRoute) }
                Button("Pop to Chaos Root") { self.popToRoot() }
            })
        case .final:
            return AnyView(TestScreen(title: "Final", color: color.opacity(0.6), depth: depth) {
                Button("Pop to Root") { self.popToRoot() }
                Button("Pop All") { self.popAll() }
            })
        case .swappedRoute:
            return AnyView(TestScreen(title: "Swapped", color: .red, depth: depth) { Button("Pop") { self.pop() } })
        case .deeperChaos(let d):
            return AnyView(CoordinatorHost(ChaosCoordinator(router: router, depth: d)))
        }
    }
    func buildModal(_ route: Route) -> AnyView? { return nil }
}

// ***************************************************************
// MARK: - 3. UI HELPERS (Unchanged)
// ***************************************************************

struct TestScreen<Content: View>: View {
    let title: String; let color: Color; let depth: Int; @ViewBuilder let content: Content
    var body: some View {
        ZStack {
            color.opacity(0.15).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 15) {
                    HStack { ForEach(0..<depth, id: \.self) { _ in Capsule().fill(.secondary).frame(width: 4, height: 20) }; Text(title).font(.title2).bold() }.padding(.top, 20)
                    content.buttonStyle(TestButtonStyle()).padding(.horizontal)
                }
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
    }
}
struct TestButtonStyle: ButtonStyle { func makeBody(configuration: Configuration) -> some View { configuration.label.frame(maxWidth: .infinity).padding().background(Color.primary.opacity(0.05)).cornerRadius(10).scaleEffect(configuration.isPressed ? 0.98 : 1.0) } }

struct ProDebugOverlay: View {
    let router: Router; let myID: UUID?; let name: String
    struct StackItem: Identifiable { let id = UUID(); let index: Int; let routeName: String; let ownerID: UUID?; let isScopeStart: Bool }
    var analyzedStack: [StackItem] {
        let scopes = router.coordinatorScopes.sorted { $0.value < $1.value }
        return router.path.enumerated().map { index, route in
            let owner = scopes.last { $0.value <= index }
            return StackItem(index: index, routeName: route.id, ownerID: owner?.key, isScopeStart: owner?.value == index)
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack { Circle().fill(Color.green).frame(width: 8, height: 8); Text(name).bold().font(.caption); Spacer(); Text("\(router.path.count)").font(.caption2).foregroundStyle(.secondary) }
                .padding(8).background(Color.black.opacity(0.05))
            Divider()
            ScrollView {
                VStack(spacing: 2) {
                    if router.path.isEmpty { Text("(Root)").font(.caption).padding(8).foregroundStyle(.secondary) }
                    ForEach(analyzedStack.reversed()) { item in
                        HStack(spacing: 6) {
                            Text("\(item.index)").font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary).frame(width: 15)
                            if let _ = item.ownerID { Rectangle().fill(Color.blue).frame(width: 2) } else { Rectangle().fill(Color.clear).frame(width: 2) }
                            Text(item.routeName).font(.caption2).lineLimit(1)
                            Spacer()
                            if item.isScopeStart { Image(systemName: "arrow.turn.down.right").font(.system(size: 8)).foregroundStyle(.blue); Text(item.ownerID?.uuidString.prefix(4) ?? "ROOT").font(.system(size: 8, design: .monospaced)).padding(2).background(Color.blue.opacity(0.2)).cornerRadius(2) }
                        }
                        .padding(.horizontal, 8).padding(.vertical, 4).background(item.ownerID == myID ? Color.green.opacity(0.1) : Color.clear)
                    }
                }
            }.frame(maxHeight: 200)
        }
        .background(.ultraThinMaterial).cornerRadius(12).shadow(radius: 5).padding()
    }
}

#Preview("Stress Test Fixed") { CoordinatorHost(TestAppCoordinator()) }
