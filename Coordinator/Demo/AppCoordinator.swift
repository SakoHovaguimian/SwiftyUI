////
////  AppCoordinator.swift
////  AsyncStreamDemo
////
////  Created by Sako Hovaguimian on 1/18/26.
////
//
//import SwiftUI
//
//@MainActor
//@Observable
//final class AppCoordinator: @MainActor Coordinator {
//    
//    enum Route: @MainActor Routable {
//        
//        case chaosStart(depth: Int)
//        case modalTestStart
//        case info
//        
//        public var id: String {
//            return String(describing: self)
//        }
//        
//    }
//    
//    var router = Router()
//    let isRoot = true
//    
//    func start() -> some View {
//        
//        TestScreen(title: "🧪 App Root", color: .gray, depth: 0) {
//            
//            Section("Standard Tests") {
//                
//                Button("Push Chaos (Nav Stack)") {
//                    self.push(.chaosStart(depth: 1))
//                }
//                
//            }
//            
//            Section("Modal Tests") {
//                
//                Button("Present Sheet (New Stack)") {
//                    self.sheet(.modalTestStart)
//                }
//                
//                Button("Present Full Screen (New Stack)") {
//                    self.fullScreen(.modalTestStart)
//                }
//                
//            }
//            
//        }
//        .withProOverlay(
//            router: router,
//            id: id,
//            name: "ROOT (Main)"
//        )
//        
//    }
//    
//    func build(_ route: Route) -> AnyView? {
//        
//        switch route {
//        case .chaosStart(let depth):
//            return AnyView(CoordinatorHost(ChaosCoordinator(router: router, depth: depth)))
//        case .info: return nil
//        case .modalTestStart: return nil
//        }
//        
//    }
//    
//    func buildModal(_ route: Route) -> AnyView? {
//        
//        switch route {
//        case .modalTestStart:
//            return AnyView(CoordinatorHost(ModalTestCoordinator(depth: 1)))
//        default: return nil
//        }
//        
//    }
//    
//}
//
//#Preview {
//    
//    CoordinatorHost(AppCoordinator())
//    
//}
