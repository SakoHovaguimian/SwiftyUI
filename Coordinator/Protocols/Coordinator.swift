//
//  Coordinator.swift
//  AsyncStreamDemo
//
//  Created by Sako Hovaguimian on 1/18/26.
//

import SwiftUI

@MainActor
public protocol Coordinator: AnyObject, Identifiable {
    
    associatedtype Route: Routable
    associatedtype ContentView: View
    
    var id: UUID { get }
    var router: Router { get set }
    var isRoot: Bool { get }
    
    func start() -> ContentView
    func build(_ route: Route) -> AnyView?
    func buildModal(_ route: Route) -> AnyView?
    
}

extension Coordinator {
    
    public var id: UUID {
        UUID()
    }
    
    public func push(_ route: Route) {
        
        self.router.push(
            route,
            from: self.id,
            isEmbedded: !self.isRoot
        )
        
    }
    
    public func push(_ routes: [Route]) {
        
        self.router.push(
            routes,
            from: self.id,
            isEmbedded: !self.isRoot
        )
        
    }
    
    public func pop() {
        
        self.router
            .pop()
        
    }
    
    public func popToRoot() {
        
        self.router
            .popToRoot()
        
    }
    
    public func popAll() {
        
        self.router
            .popAll()
        
    }
    
    public func popToSelf() {
        
        self.router
            .popToSelf(from: self.id)
        
    }
    
    public func replace(last count: Int = 1,
                        with route: Route) {
        
        self.router
            .replace(
                last: count,
                with: route
            )
        
    }
    
    
    public func sheet(_ route: Route) {
        
        self.router
            .presentSheet(route)
        
    }
    
    public func fullScreen(_ route: Route) {
        
        self.router
            .presentFullScreen(route)
        
    }
    
    public func dismiss() {
        
        self.router
            .dismiss()
        
    }
    public func finish() {
        
        if self.isRoot {
            
            self.router
                .dismiss()
            
        }
        else {
            popToSelf()
        }
        
    }
    
    public func registerSelf() {
        
        self.router.registerResolver(id) { [weak self] anyRoute in
            
            guard let self = self,
                  let specific = anyRoute.as(Route.self) else { return nil }
            
            // 1. Try Build (Standard Push)
            if let view = self.build(specific) {
                return view
            }
            
            // 2. Try Build Modal (Sheet/Cover)
            return self.buildModal(specific)
            
        }
        
    }
    
}
