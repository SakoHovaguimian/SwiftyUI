////
////  ModalTestCoordinator.swift
////  AsyncStreamDemo
////
////  Created by Sako Hovaguimian on 1/18/26.
////
//
//import SwiftUI
//
//@MainActor
//@Observable
//final class ModalTestCoordinator: @MainActor Coordinator {
//    
//    // **********************************
//    // MARK: - Routes
//    // **********************************
//    
//    enum Route: @MainActor Routable {
//        
//        case step(Int)
//        case deeperModal
//        
//        var id: String {
//            String(describing: self)
//        }
//        
//    }
//    
//    // **********************************
//    // MARK: - Properties
//    // **********************************
//    
//    let id = UUID()
//    var router = Router()
//    let isRoot = true
//    let depth: Int
//    
//    var color: Color {
//        let colors: [Color] = [.mint, .indigo, .teal]
//        return colors[(self.depth - 1) % colors.count]
//    }
//    
//    // **********************************
//    // MARK: - Init
//    // **********************************
//    
//    init(depth: Int) {
//        self.depth = depth
//    }
//    
//    // **********************************
//    // MARK: - Start
//    // **********************************
//    
//    func start() -> some View {
//        
//        TestScreen(
//            title: "Modal Lvl \(self.depth)",
//            color: self.color,
//            depth: self.depth
//        ) {
//            
//            Text("Sheet Root")
//            
//            Section("Internal") {
//                
//                Button("Push Step 1") {
//                    self.push(.step(1))
//                }
//                
//            }
//            
//            Section("Recursion") {
//                
//                Button("Present Deeper") {
//                    self.sheet(.deeperModal)
//                }
//                
//            }
//            
//            Section("Close") {
//                
//                Button("Dismiss") {
//                    self.dismiss()
//                }
//                
//            }
//            
//        }
//        .withProOverlay(
//            router: self.router,
//            id: self.id,
//            name: "Modal \(self.depth)"
//        )
//        
//    }
//    
//    // **********************************
//    // MARK: - Navigation
//    // **********************************
//    
//    func build(_ route: Route) -> AnyView? {
//        
//        switch route {
//        case .step(let step):
//            return AnyView(
//                TestScreen(
//                    title: "Modal Step \(step)",
//                    color: self.color.opacity(0.8),
//                    depth: self.depth
//                ) {
//                    
//                    Button("Next") {
//                        self.push(.step(step + 1))
//                    }
//                    
//                    Button("Pop Root") {
//                        self.popToRoot()
//                    }
//                    
//                }
//            )
//            
//        case .deeperModal:
//            return nil
//        }
//        
//    }
//    
//    func buildModal(_ route: Route) -> AnyView? {
//        
//        switch route {
//        case .deeperModal:
//            return AnyView(
//                CoordinatorHost(
//                    ModalTestCoordinator(depth: self.depth + 1)
//                )
//            )
//            
//        default:
//            return nil
//        }
//        
//    }
//    
//}
