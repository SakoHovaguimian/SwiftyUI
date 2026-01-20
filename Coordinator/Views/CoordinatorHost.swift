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
