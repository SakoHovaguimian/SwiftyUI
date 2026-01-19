////
////  ChaosCoordinator.swift
////  AsyncStreamDemo
////
////  Created by Sako Hovaguimian on 1/18/26.
////
//
//import SwiftUI
//
//@MainActor
//@Observable
//final class ChaosCoordinator: @MainActor Coordinator {
//    
//    // **********************************
//    // MARK: - Routes
//    // **********************************
//    
//    enum Route: @MainActor Routable {
//        
//        case step(Int)
//        case final
//        case deeperChaos(Int)
//        case swappedRoute
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
//    var router: Router
//    let isRoot = false
//    let depth: Int
//    
//    var color: Color {
//        let colors: [Color] = [.blue, .purple, .orange, .pink, .green]
//        return colors[(self.depth - 1) % colors.count]
//    }
//    
//    // **********************************
//    // MARK: - Init
//    // **********************************
//    
//    init(
//        router: Router,
//        depth: Int
//    ) {
//        self.router = router
//        self.depth = depth
//    }
//    
//    // **********************************
//    // MARK: - Start
//    // **********************************
//    
//    func start() -> some View {
//        ChaosStartView()
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
//            return AnyView(ChaosStepView(step: step))
//            
//        case .final:
//            return AnyView(ChaosFinalView())
//            
//        case .swappedRoute:
//            return AnyView(ChaosSwappedView())
//            
//        case .deeperChaos(let depth):
//            return AnyView(
//                CoordinatorHost(
//                    ChaosCoordinator(
//                        router: self.router,
//                        depth: depth
//                    )
//                )
//            )
//        }
//        
//        func buildModal(_ route: Route) -> AnyView? {
//            nil
//        }
//        
//    }
//    
//    // **********************************
//    // MARK: - Chaos Start View
//    // **********************************
//    
//    private struct ChaosStartView: View {
//        
//        // **********************************
//        // MARK: - Environment
//        // **********************************
//        
//        @Environment(\.coordinator) private var coordinator
//        
//        // **********************************
//        // MARK: - Body
//        // **********************************
//        
//        var body: some View {
//            
//            TestScreen(
//                title: "Chaos Lvl \(self.coordinator.depth)",
//                color: self.coordinator.color ?? .black,
//                depth: self.coordinator?.depth ?? 0
//            ) {
//                
//                Text("ID: ...\(self.coordinator?.id.uuidString.suffix(4))")
//                
//                Section("Stack") {
//                    
//                    Button("Push Step 1") {
//                        self.coordinator?.push(.step(1))
//                    }
//                    
//                    Button("Batch Push") {
//                        self.coordinator?.push([.step(1), .step(2), .final])
//                    }
//                    
//                    Button("Embed Deeper") {
//                        self.coordinator?.push(.deeperChaos(self.coordinator.depth + 1))
//                    }
//                    
//                }
//                
//                Section("Control") {
//                    
//                    Button("Pop") {
//                        self.coordinator.pop()
//                    }
//                    
//                    Button("PopToSelf") {
//                        self.coordinator.popToSelf()
//                    }
//                    
//                }
//                
//            }
//            .withProOverlay(
//                router: self.coordinator?.router ?? Router(),
//                id: self.coordinator?.id ?? UUID(),
//                name: "Chaos \(self.coordinator?.depth)" ?? "NONE"
//            )
//            
//        }
//        
//    }
//    
//    // **********************************
//    // MARK: - Chaos Step View
//    // **********************************
//    
//    private struct ChaosStepView: View {
//        
//        // **********************************
//        // MARK: - Environment
//        // **********************************
//        
//        @Environment(\.coordinator) private var coordinator
//        
//        // **********************************
//        // MARK: - Properties
//        // **********************************
//        
//        let step: Int
//        
//        // **********************************
//        // MARK: - Body
//        // **********************************
//        
//        var body: some View {
//            
//            TestScreen(
//                title: "Step \(self.step)",
//                color: self.coordinator.color.opacity(0.8) ?? .black,
//                depth: self.coordinator?.depth ?? 0
//            ) {
//                
//                Button("Next") {
//                    self.coordinator.push(.step(self.step + 1))
//                }
//                
//                Button("Push Final") {
//                    self.coordinator.push(.deeperChaos(100))
//                }
//                
//                Button("Replace") {
//                    self.coordinator.replace(with: .swappedRoute)
//                }
//                
//                Button("Pop to Chaos Root") {
//                    self.coordinator.popToRoot()
//                }
//                
//            }
//            .withProOverlay(
//                router: self.coordinator?.router ?? Router(),
//                id: self.coordinator?.id ?? UUID(),
//                name: "Chaos \(self.coordinator?.depth)" ?? "NONE"
//            )
//            
//        }
//        
//    }
//    
//    // **********************************
//    // MARK: - Chaos Final View
//    // **********************************
//    
//    private struct ChaosFinalView: View {
//        
//        // **********************************
//        // MARK: - Environment
//        // **********************************
//        
//        @Environment(\.coordinator) private var coordinator
//        
//        // **********************************
//        // MARK: - Body
//        // **********************************
//        
//        var body: some View {
//            
//            TestScreen(
//                title: "Final",
//                color: self.coordinator?.color.opacity(0.6) ?? .black,
//                depth: self.coordinator?.depth ?? -1
//            ) {
//                
//                Button("Pop to Root") {
//                    self.coordinator?.popToRoot()
//                }
//                
//                Button("Pop All") {
//                    self.coordinator?.popAll()
//                }
//                
//            }
//            .withProOverlay(
//                router: self.coordinator?.router ?? Router(),
//                id: self.coordinator?.id ?? UUID(),
//                name: "Chaos \(self.coordinator?.depth)" ?? "NONE"
//            )
//            
//        }
//        
//    }
//    
//    // **********************************
//    // MARK: - Chaos Swapped View
//    // **********************************
//    
//    private struct ChaosSwappedView: View {
//        
//        // **********************************
//        // MARK: - Environment
//        // **********************************
//        
//        @Environment(\.coordinator) private var coordinator
//        
//        // **********************************
//        // MARK: - Body
//        // **********************************
//        
//        var body: some View {
//            
//            TestScreen(
//                title: "Swapped",
//                color: .red,
//                depth: self.coordinator?.depth ?? 0
//            ) {
//                
//                Button("Pop") {
//                    self.coordinator?.pop()
//                }
//                
//            }
//            .withProOverlay(
//                router: self.coordinator?.router ?? Router(),
//                id: self.coordinator?.id ?? UUID.init(),
//                name: "Chaos \(self.coordinator?.depth)" ?? "NONE"
//            )
//            
//        }
//        
//    }
//    
//}
