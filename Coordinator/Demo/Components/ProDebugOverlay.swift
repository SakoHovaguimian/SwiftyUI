////
////  ProDebugOverlay.swift
////  AsyncStreamDemo
////
////  Created by Sako Hovaguimian on 1/18/26.
////
//
//import SwiftUI
//
//public struct ProDebugOverlay: View {
//    
//    let router: Router
//    let myID: UUID?
//    let name: String
//    
//    struct StackItem: Identifiable {
//        
//        let id = UUID()
//        let index: Int
//        let routeName: String
//        let ownerID: UUID?
//        let isScopeStart: Bool
//        
//    }
//    
//    public init(router: Router,
//                myID: UUID?,
//                name: String) {
//        
//        self.router = router
//        self.myID = myID
//        self.name = name
//        
//    }
//    
//    var analyzedStack: [StackItem] {
//        
//        let scopes = self.router.coordinatorScopes
//            .sorted { $0.value < $1.value }
//        
//        return self.router.path.enumerated().map { index, route in
//            
//            let owner = scopes.last { $0.value <= index }
//            
//            return StackItem(
//                index: index,
//                routeName: route.id,
//                ownerID: owner?.key,
//                isScopeStart: owner?.value == index
//            )
//            
//        }
//        
//    }
//    
//    public var body: some View {
//        
//        VStack(alignment: .leading, spacing: 0) {
//            
//            HStack {
//                
//                Circle()
//                    .fill(Color.green)
//                    .frame(width: 8, height: 8)
//                
//                Text(self.name)
//                    .bold()
//                    .font(.caption)
//                
//                Spacer()
//                
//                Text("\(self.router.path.count)")
//                    .font(.caption2)
//                    .foregroundStyle(.secondary)
//                
//            }
//            .padding(8)
//            .background(Color.black.opacity(0.05))
//            
//            Divider()
//            
//            ScrollView {
//                
//                VStack(spacing: 2) {
//                    
//                    if self.router.path.isEmpty {
//                        
//                        Text("(Root)")
//                            .font(.caption)
//                            .padding(8)
//                            .foregroundStyle(.secondary)
//                        
//                    }
//                    
//                    ForEach(self.analyzedStack.reversed()) { item in
//                        
//                        HStack(spacing: 6) {
//                            
//                            Text("\(item.index)")
//                                .font(.system(size: 9, design: .monospaced))
//                                .foregroundStyle(.secondary)
//                                .frame(width: 15)
//                            
//                            Rectangle()
//                                .fill(item.ownerID != nil ? Color.blue : Color.clear)
//                                .frame(width: 2)
//                            
//                            Text(item.routeName)
//                                .font(.caption2)
//                                .lineLimit(1)
//                            
//                            Spacer()
//                            
//                            if item.isScopeStart {
//                                
//                                Image(systemName: "arrow.turn.down.right")
//                                    .font(.system(size: 8))
//                                    .foregroundStyle(.blue)
//                                
//                                Text(item.ownerID?.uuidString.prefix(4) ?? "ROOT")
//                                    .font(.system(size: 8, design: .monospaced))
//                                    .padding(2)
//                                    .background(Color.blue.opacity(0.2))
//                                    .cornerRadius(2)
//                                
//                            }
//                            
//                        }
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 4)
//                        .background(
//                            item.ownerID == self.myID
//                            ? Color.green.opacity(0.1)
//                            : Color.clear
//                        )
//                        
//                    }
//                    
//                }
//                
//            }
//            .frame(maxHeight: 200)
//            
//        }
//        .background(.ultraThinMaterial)
//        .cornerRadius(12)
//        .shadow(radius: 5)
//        .padding()
//        
//    }
//    
//}
//
//extension View {
//    
//    func withProOverlay(router: Router,
//                        id: UUID,
//                        name: String) -> some View {
//        
//        self
//            .overlay(alignment: .bottom) {
//                
//                ProDebugOverlay(
//                    router: router,
//                    myID: id,
//                    name: name
//                )
//                
//            }
//        
//    }
//    
//}
