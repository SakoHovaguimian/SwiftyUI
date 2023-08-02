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
    
}

//// TEST
//struct NewCoordinatorTestView: View {
//    
//    // Pass optional binding property to coordinator class
//    // Make dimiss function that turns the bidning to false
//    // Test nested coordinators dismiss and creating nested contexts of themeselves
//    
//    @EnvironmentObject var previousNavigationService: NavigationService
//    @StateObject private var newNavigationService = NavigationService()
//    
//    var body: some View {
//        NavigationStack(path: self.$newNavigationService.pathItems) {
//            ZStack { Color.red.ignoresSafeArea() }
//                .overlay(content: {
//                    
//                    VStack {
//                        
//                        Button("Dismiss") {
//                            self.previousNavigationService.dismissFullScreenCover()
//                        }
//                        
//                        Button("New Coordinator Screen") {
//                            self.newNavigationService.push(.blueView)
//                        }
//                        
//                    }
//
//                    
//                })
//                .withNavigationDestination()
//                .withSheetDestination(self.$newNavigationService.sheet)
//                .withFullScreenCover(self.$newNavigationService.fullScreenCover)
//        }
//    }
//    
//}

struct TestEmbedView: View {
    
    @EnvironmentObject var navigationService: NavigationService
    
    @State private var sampleText: String = ""
    
    var body: some View {
        
        ZStack {
            
            Color.mint
                .opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                
                CustomTextField(
                    placeholder: "Password",
                    text: self.$sampleText,
                    isFocused: false
                )
                
                Button("Test") {
                    self.navigationService.push(.blueView)
                }
                
                
            }
            
        }
//        .onAppear {
//            self.navigationService.shouldHideTabBar = true
//        }
//        .onDisappear {
//            self.navigationService.shouldHideTabBar = false
//        }
        
    }
}

extension View {
    
    func withNavigationDestination() -> some View {
        
        navigationDestination(for: NavigationService.Route.self) { route in
            
            switch route {
                
            case .redView: TestEmbedView()
                    .navigationBarBackButtonHidden()
                
            case .blueView: TestEmbedView()
                    .navigationBarBackButtonHidden()
                
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
