//
//  NavigationService.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/13/23.
//

import SwiftUI

enum Sheet: String, Identifiable {
    
    case purpleView
    
    var id: String {
        return self.rawValue
    }
    
}

enum FullScreenCover: String, Identifiable {
    
    case yellowView
    
    var id: String {
        return self.rawValue
    }
    
}

protocol Navigation {
    //
}
//
//protocol Coordinated {
//    
//    @ViewBuilder func build(route: Navigation) -> any View
//    @ViewBuilder func build(sheet: Sheet) -> any View
//    @ViewBuilder func build(fullScreenCover: FullScreenCover) -> any View
//    
//}
//
//enum HomeCoordinatorRoutes: Navigation {
//    
//    case redView
//    case blueView
//    case greenView
//    
//}
//
//class HomeCoordinator: CommonViewCoordinator<HomeCoordinatorRoutes> {
//    
//    override func build(route: Navigation) -> any View {
//        switch route as! HomeCoordinatorRoutes {
//        case .redView: ZStack { Color.red.ignoresSafeArea() }
//        case .blueView: ZStack { Color.red.ignoresSafeArea() }
//        case .greenView: ZStack { Color.red.ignoresSafeArea() }
//        }
//    }
//    
//}
//
//enum ProductCoordinatorRoutes: Navigation {
//    
//    case redView
//    case blueView
//    case greenView
//    
//}
//
//class ProductCoordinator: CommonViewCoordinator<ProductCoordinatorRoutes> {
//    
//    override func build(route: Navigation) -> any View {
//        switch route as! ProductCoordinatorRoutes {
//        case .redView: ZStack { Color.red.ignoresSafeArea() }
//        case .blueView: ZStack { Color.red.ignoresSafeArea() }
//        case .greenView: ZStack { Color.red.ignoresSafeArea() }
//        }
//    }
//    
//}
//
//class CommonViewCoordinator<N: Navigation>: Coordinated {
//    
//    @Published var pathItems: [N] = []
//    @Published var sheet: Sheet?
//    @Published var fullScreenCover : FullScreenCover?
//    
//    func navigate(to navigation: N) {
//        fatalError("You must override & implement navigate(to:)")
//    }
//    
//    func push(_ route: N) {
//        self.pathItems.append(route)
//    }
//    
//    func push(_ routes: [N]) {
//        self.pathItems.append(contentsOf: routes)
//    }
//    
//    func pop() {
//        self.pathItems.removeLast()
//    }
//    
//    func popToRoot() {
//        self.pathItems.removeAll()
//    }
//    
//    func swap(_ route: N) {
//        
//        self.pathItems.removeLast()
//        self.pathItems.append(route)
//        
//    }
//    
//    //weird. test.
//    func replaceStack(_ route: N) {
//        
//        self.pathItems.removeAll()
//        
//        Task { @MainActor in
//            //The time delay may be device/app specific.
//            try? await Task.sleep(nanoseconds: 400_000_000)
//            push(route)
//            
//        }
//        
//    }
//    
//    @ViewBuilder
//    func build(route: Navigation) -> any View {
//        switch route {
//        default: ZStack { }
//        }
//    }
//    
//    @ViewBuilder
//    func build(sheet: Sheet) -> any View {
//        ZStack{}
//    }
//    
//    @ViewBuilder
//    func build(fullScreenCover: FullScreenCover) -> any View {
//        ZStack{}
//    }
//    
//    // Sheets
//    
//    func dismissSheet() {
//        self.sheet = nil
//    }
//    
//    // FullScreenCover
//    
//    func dismissFullScreenCover() {
//        self.fullScreenCover = nil
//    }
//    
//}
//
//class CommonNavigationService: CommonViewCoordinator<HomeCoordinatorRoutes>, ObservableObject {
//    
//    @ViewBuilder
//    func build(route: HomeCoordinatorRoutes) -> some View {
//        switch route {
//        case .redView: ZStack { Color.red.ignoresSafeArea().onTapGesture { self.pathItems.append(.redView) }}
//        case .blueView: ZStack { Color.blue.ignoresSafeArea().onTapGesture { self.fullScreenCover = .yellowView }}
//        default: ZStack { Color.purple.ignoresSafeArea() }
//        }
//    }
//    
//    @ViewBuilder
//    func build(sheet: Sheet) -> some View {
//        switch sheet {
//        case .purpleView:
//            NavigationStack {
//                ZStack { Color.purple.ignoresSafeArea() }
//            }
//        }
//    }
//    
//    @ViewBuilder
//    func build(fullScreenCover: FullScreenCover) -> some View {
//        switch fullScreenCover {
//        case .yellowView:
//            NavigationStack {
//                ZStack { NewCoordinatorTestView().onTapGesture {
//                    self.dismissFullScreenCover()
//                } }
//            }
//        }
//    }
//    
//}

//@MainActor
class NavigationService: ObservableObject {
    
    enum Route: Navigation {
        
        case redView
        case blueView
        
    }
    
    @Published var pathItems: [Route] = []
    @Published var sheet: Sheet?
    @Published var fullScreenCover : FullScreenCover?
//    @Binding var dismiss: Bool = false
    
    func push(_ route: Route) {
        self.pathItems.append(route)
    }
    
    func push(_ routes: [Route]) {
        self.pathItems.append(contentsOf: routes)
    }
    
    func pop() {
        self.pathItems.removeLast()
    }
    
    func popToRoot() {
        self.pathItems.removeAll()
    }
    
    func swap(_ route: Route) {
        
        self.pathItems.removeLast()
        self.pathItems.append(route)
        
    }
    
    // Sheets
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    // FullScreenCover
    
    func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }
    
    //weird. test.
    func replaceStack(_ route: Route) {
        
        self.pathItems.removeAll()
        
        Task { @MainActor in
            //The time delay may be device/app specific.
            try? await Task.sleep(nanoseconds: 400_000_000)
            push(route)
            
        }
        
    }
    
    @ViewBuilder
    func build(route: Route) -> some View {
        switch route {
        case .redView: ZStack { Color.red.ignoresSafeArea().onTapGesture { self.pathItems.append(.redView) }}
        case .blueView: ZStack { Color.blue.ignoresSafeArea().onTapGesture { self.fullScreenCover = .yellowView }}
        }
    }
    
    @ViewBuilder
    func build(sheet: Sheet) -> some View {
        switch sheet {
        case .purpleView:
            NavigationStack {
                ZStack { Color.purple.ignoresSafeArea() }
            }
        }
    }
    
    @ViewBuilder
    func build(fullScreenCover: FullScreenCover) -> some View {
        switch fullScreenCover {
        case .yellowView:
            NavigationStack {
                ZStack { NewCoordinatorTestView().environmentObject(self) }
            }
        }
    }
    
}

// TEST
struct NewCoordinatorTestView: View {
    
    // Pass optional binding property to coordinator class
    // Make dimiss function that turns the bidning to false
    // Test nested coordinators dismiss and creating nested contexts of themeselves
    
    @EnvironmentObject var previousNavigationService: NavigationService
    @StateObject private var newNavigationService = NavigationService()
    
    var body: some View {
        NavigationStack(path: self.$newNavigationService.pathItems) {
            self.previousNavigationService.build(route: .redView)
                .overlay(content: {
                    
                    VStack {
                        
                        Button("Dismiss") {
                            self.previousNavigationService.dismissFullScreenCover()
                        }
                        
                        Button("New Coordinator Screen") {
                            self.newNavigationService.push(.blueView)
                        }
                        
                    }

                    
                })
                .navigationDestination(for: NavigationService.Route.self) { route in
                    self.newNavigationService.build(route: route)
                }
                .sheet(item: self.$newNavigationService.sheet) { sheet in
                    self.newNavigationService.build(sheet: sheet)
                }
                .fullScreenCover(item: self.$newNavigationService.fullScreenCover) { fullScreenCover in
                    self.newNavigationService.build(fullScreenCover: fullScreenCover)
                }
        }
    }
    
}
