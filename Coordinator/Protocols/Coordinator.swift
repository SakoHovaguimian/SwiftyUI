//
//  Coordinator.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/26.
//

import SwiftUI
import Observation

@MainActor
public protocol Coordinator: ParentCoordinatorProtocol, Observable {
    
    associatedtype Route: Routable
    associatedtype StartView: View
    associatedtype BuildView: View
    
    @ViewBuilder func start(context: NavigationContext) -> StartView
    @ViewBuilder func build(_ route: Route) -> BuildView
    
}
