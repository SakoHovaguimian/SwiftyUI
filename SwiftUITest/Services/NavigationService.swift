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

// FOR TAB BARS:
// WE NEED TO HAVE MULTIPLE PATH_ITEMS arrays and a top level enum
// THEN WE CAN DO A DOUBLE SWITCH OR BREAKOUT FUNCTIONS FOR
// WITHNAVIGATION EXTENSION
// HAVEN'T TESTED BELOW
/*

enum TabNavigation {
    
    enum HomeNavigation {
        case home
    }
    
    enum StoreNavigation {
        case store
    }
    
    enum ProfileNavigation {
        case profile
    }
    
    case home(HomeNavigation)
    case store(StoreNavigation)
    case profile(ProfileNavigation)
    
}
 
*/

@MainActor
class NavigationService: ObservableObject {
    
    enum Route: Navigation {
        
        case redView
        case blueView
        
    }
    
    @Published var pathItems: [Route] = []
    @Published var sheet: Sheet?
    @Published var fullScreenCover : FullScreenCover?
    @Binding var shouldHideTabBar: Bool
    
    init() {
        self._shouldHideTabBar = .constant(false)
    }
    
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
    
    func bindTabBarVisibility(_ shouldHideTabBar: Binding<Bool>) {
        self._shouldHideTabBar = shouldHideTabBar
    }
    
//    @ViewBuilder
//    func build(route: Route) -> some View {
//        switch route {
//        case .redView: ZStack { Color.red.ignoresSafeArea().onTapGesture { self.pathItems.append(.redView) }}
//        case .blueView: ZStack { Color.blue.ignoresSafeArea().onTapGesture { self.fullScreenCover = .yellowView }}
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
//                ZStack { NewCoordinatorTestView().environmentObject(self) }
//            }
//        }
//    }
    
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
            ZStack { Color.red.ignoresSafeArea() }
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
                .withNavigationDestination()
                .withSheetDestination(self.$newNavigationService.sheet)
                .withFullScreenCover(self.$newNavigationService.fullScreenCover)
        }
    }
    
}

struct TestEmbedView: View {
    
    @EnvironmentObject var navigationService: NavigationService
    
    var body: some View {
        
        ZStack {
            
            Color.mint
                .opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                
                Button("Test") {
                    self.navigationService.push(.blueView)
                }
                
            }
            
        }
        .onAppear {
            self.navigationService.shouldHideTabBar = true
        }
        .onDisappear {
            self.navigationService.shouldHideTabBar = false
        }
        
    }
}

extension View {
    
    func withNavigationDestination() -> some View {
        
        navigationDestination(for: NavigationService.Route.self) { route in
            
            switch route {
            case .redView: TestEmbedView()
            case .blueView: TestEmbedView()
            }
            
        }
        
    }
    
    func withSheetDestination(_ customSheet: Binding<Sheet?>) -> some View {
        
        sheet(item: customSheet) { sheet in
            
            switch sheet {
            case .purpleView: NavigationStack { ZStack { Color.purple.ignoresSafeArea() } }
            }
                
        }
        
    }
    
    func withFullScreenCover(_ customFullScreenCover: Binding<FullScreenCover?>) -> some View {
        
        fullScreenCover(item: customFullScreenCover) { sheet in
            
            switch sheet {
            case .yellowView: NavigationStack { ZStack { Color.yellow.ignoresSafeArea() } }
            }
                
        }
        
    }
    
}
