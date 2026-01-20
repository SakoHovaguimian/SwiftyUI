////
////  SinglePageContextCode.swift
////  SwiftyUI
////
////  Created by Sako Hovaguimian on 1/18/26.
////
//
//import SwiftUI
//
//@MainActor
//@Observable
//public final class Router {
//    
//    public var path: [AnyRoutable] = []
//    public var sheet: AnyRoutable?
//    public var fullScreenCover: AnyRoutable?
//    public var dismissRequest: Bool = false
//    
//    public private(set) var coordinatorScopes: [UUID: Int] = [:]
//    private var viewResolvers: [UUID: (AnyRoutable) -> AnyView?] = [:]
//    
//    public init() {
//        
//    }
//    
//    public func push(_ route: any Routable,
//                     from id: UUID,
//                     isEmbedded: Bool) {
//        
//        if isEmbedded,
//           self.coordinatorScopes[id] == nil {
//            
//            self.coordinatorScopes[id] = path.count
//            
//        }
//        
//        self.path.append(AnyRoutable(route))
//        
//    }
//    
//    public func push(_ routes: [any Routable],
//                     from id: UUID,
//                     isEmbedded: Bool) {
//        
//        guard !routes.isEmpty else { return }
//        
//        if isEmbedded,
//           self.coordinatorScopes[id] == nil {
//            
//            self.coordinatorScopes[id] = path.count
//            
//        }
//        
//        self.path.append(contentsOf: routes.map { AnyRoutable($0) })
//        
//    }
//    
//    public func pop() {
//        
//        guard !self.path.isEmpty else { return }
//        
//        self.path.removeLast()
//        pruneScopes()
//        
//    }
//    
//    public func popToRoot() {
//        
//        guard let deepestScope = self.coordinatorScopes.max(by: { $0.value < $1.value }) else {
//            
//            popAll()
//            return
//            
//        }
//        
//        let targetCount = deepestScope.value
//        
//        if self.path.count > targetCount {
//            self.path.removeLast(self.path.count - targetCount)
//        }
//        
//        pruneScopes()
//        
//    }
//    
//    public func popAll() {
//        
//        self.path.removeAll()
//        pruneScopes()
//        
//    }
//    
//    public func popToSelf(from id: UUID) {
//        
//        guard let startIndex = self.coordinatorScopes[id] else { return }
//        
//        let countToRemove = self.path.count - startIndex
//        guard countToRemove > 0 else { return }
//        
//        self.path.removeLast(countToRemove)
//        pruneScopes()
//        
//    }
//    
//    public func replace(last count: Int,
//                        with route: any Routable) {
//        
//        let safeCount = min(path.count, count)
//        
//        if safeCount > 0 {
//            self.path.removeLast(safeCount)
//        }
//        
//        self.path.append(AnyRoutable(route))
//        pruneScopes()
//        
//    }
//    
//    public func presentSheet(_ route: any Routable) {
//        self.sheet = AnyRoutable(route)
//    }
//    
//    public func presentFullScreen(_ route: any Routable) {
//        self.fullScreenCover = AnyRoutable(route)
//    }
//    
//    public func dismiss() {
//        
//        if self.sheet != nil || self.fullScreenCover != nil {
//            
//            self.sheet = nil
//            self.fullScreenCover = nil
//            
//        }
//        else {
//            self.dismissRequest = true
//        }
//        
//    }
//    
//    public func registerResolver(_ id: UUID,
//                                 resolver: @escaping (AnyRoutable) -> AnyView?) {
//        
//        self.viewResolvers[id] = resolver
//        
//    }
//    
//    public func resolve(route: AnyRoutable) -> AnyView {
//        
//        let sortedScopes = self.coordinatorScopes.sorted { $0.value > $1.value }
//        
//        // 1. Ask Deepest Children
//        for (id, _) in sortedScopes {
//            
//            if let builder = self.viewResolvers[id],
//               let view = builder(route) {
//                return view
//            }
//            
//        }
//        
//        // 2. Ask Root
//        for (_, builder) in self.viewResolvers {
//            
//            if let view = builder(route) {
//                return view
//            }
//            
//        }
//        
//        return AnyView(Text("❌ Unhandled Route: \(route.id)").background(Color.red.opacity(0.35)))
//        
//    }
//    
//    public func handleNativePopIfNeeded() {
//        pruneScopes()
//    }
//    
//    private func pruneScopes() {
//        
//        let currentPathCount = self.path.count
//        
//        let deadIDs = self.coordinatorScopes.filter { $0.value > currentPathCount }.map { $0.key }
//        
//        for id in deadIDs {
//            
//            self.coordinatorScopes.removeValue(forKey: id)
//            self.viewResolvers.removeValue(forKey: id)
//            
//        }
//        
//    }
//    
//}
//
////
////  CoordinatorHost.swift
////  AsyncStreamDemo
////
////  Created by Sako Hovaguimian on 1/18/26.
////
//
//import SwiftUI
//
//public struct CoordinatorHost<C: Coordinator>: View {
//    
//    @State private var coordinator: C
//    @Environment(\.dismiss) private var dismiss
//    
//    public init(_ coordinator: C) {
//        self.coordinator = coordinator
//    }
//    
//    public var body: some View {
//        
//        Group {
//            
//            if self.coordinator.isRoot {
//                
//                NavigationStack(path: self.$coordinator.router.path) {
//                    content
//                }
//                
//            }
//            else {
//                self.content
//            }
//            
//        }
//        
//        // Lifecycle
//        
//        .task {
//            
//            self.coordinator
//                .registerSelf()
//            
//        }
//        
//        // On Change
//        
//        .onChange(of: self.coordinator.router.path) { _, _ in
//            
//            self.coordinator
//                .router
//                .handleNativePopIfNeeded()
//            
//        }
//        
//        .onChange(of: self.coordinator.router.dismissRequest) { _, newValue in
//            
//            if newValue,
//               self.coordinator.isRoot {
//                
//                dismiss()
//                
//                self.coordinator
//                    .router
//                    .dismissRequest = false
//                
//            }
//            
//        }
//        
//        // Environment
//        
//        .environment(\.coordinator, self.coordinator)
//        
//    }
//    
//    @ViewBuilder private var content: some View {
//        
//        self.coordinator
//            .start()
//            .navigationDestination(for: AnyRoutable.self) {
//                
//                self.coordinator
//                    .router
//                    .resolve(route: $0)
//                
//            }
//        
//            .sheet(item: Binding(
//                get: { self.coordinator.router.sheet },
//                set: { if $0 == nil { self.coordinator.router.dismiss() }})) {
//                    
//                    self.coordinator
//                        .router
//                        .resolve(route: $0)
//                }
//        
//                .fullScreenCover(item: Binding(
//                    get: { self.coordinator.router.fullScreenCover },
//                    set: { if $0 == nil { self.coordinator.router.dismiss() } })) {
//                        
//                        self.coordinator
//                            .router
//                            .resolve(route: $0)
//                        
//                    }
//        
//    }
//    
//}
//
//
//public extension EnvironmentValues {
//    
//    @Entry var coordinator: AnyCoordinator!
//    
//}
//
//@MainActor
//public struct AnyRoutable: @MainActor Routable {
//    
//    public let id: String
//    private let _base: AnyHashable
//    
//    public init<T: Routable>(_ base: T) {
//        
//        self.id = base.id
//        self._base = AnyHashable(base)
//        
//    }
//    
//    public func hash(into hasher: inout Hasher) {
//        self._base.hash(into: &hasher)
//    }
//    
//    public static func == (lhs: AnyRoutable,
//                           rhs: AnyRoutable) -> Bool {
//        
//        return lhs._base == rhs._base
//        
//    }
//    
//    public func `as`<T: Routable>(_ type: T.Type) -> T? {
//        return self._base as? T
//    }
//    
//}
//
//public typealias AnyCoordinator = (any Coordinator)
//
//
//import SwiftUI
//
//@MainActor
//public protocol Coordinator: AnyObject, Identifiable {
//    
//    associatedtype Route: Routable
//    associatedtype ContentView: View
//    
//    var id: UUID { get }
//    var router: Router { get set }
//    var isRoot: Bool { get }
//    
//    func start() -> ContentView
//    func build(_ route: Route) -> AnyView?
//    func buildModal(_ route: Route) -> AnyView?
//    
//}
//
//extension Coordinator {
//    
//    public var id: UUID {
//        UUID()
//    }
//    
//    public func push(_ route: Route) {
//        
//        self.router.push(
//            route,
//            from: self.id,
//            isEmbedded: !self.isRoot
//        )
//        
//    }
//    
//    public func push(_ routes: [Route]) {
//        
//        self.router.push(
//            routes,
//            from: self.id,
//            isEmbedded: !self.isRoot
//        )
//        
//    }
//    
//    public func pop() {
//        
//        self.router
//            .pop()
//        
//    }
//    
//    public func popToRoot() {
//        
//        self.router
//            .popToRoot()
//        
//    }
//    
//    public func popAll() {
//        
//        self.router
//            .popAll()
//        
//    }
//    
//    public func popToSelf() {
//        
//        self.router
//            .popToSelf(from: self.id)
//        
//    }
//    
//    public func replace(last count: Int = 1,
//                        with route: Route) {
//        
//        self.router
//            .replace(
//                last: count,
//                with: route
//            )
//        
//    }
//    
//    
//    public func sheet(_ route: Route) {
//        
//        self.router
//            .presentSheet(route)
//        
//    }
//    
//    public func fullScreen(_ route: Route) {
//        
//        self.router
//            .presentFullScreen(route)
//        
//    }
//    
//    public func dismiss() {
//        
//        self.router
//            .dismiss()
//        
//    }
//    
//    public func finish() {
//        
//        if self.isRoot {
//            
//            self.router
//                .dismiss()
//            
//        }
//        else {
//            popToSelf()
//        }
//        
//    }
//    
//    public func registerSelf() {
//        
//        self.router.registerResolver(id) { [weak self] anyRoute in
//            
//            guard let self = self,
//                  let specific = anyRoute.as(Route.self) else { return nil }
//            
//            // 1. Try Build (Standard Push)
//            if let view = self.build(specific) {
//                return view
//            }
//            
//            // 2. Try Build Modal (Sheet/Cover)
//            return self.buildModal(specific)
//            
//        }
//        
//    }
//    
//}
//
//import Foundation
//
//@MainActor
//public protocol Routable: Hashable, Identifiable {
//    var id: String { get }
//}
