////
////  Router.ts.swift
////  AsyncStreamDemo
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
