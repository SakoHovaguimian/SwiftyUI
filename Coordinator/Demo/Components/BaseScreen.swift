////
////  BaseScreen.swift
////  AsyncStreamDemo
////
////  Created by Sako Hovaguimian on 1/18/26.
////
//
//import SwiftUI
//
//struct TestScreen<Content: View>: View {
//    
//    let title: String
//    let color: Color
//    let depth: Int
//    
//    @ViewBuilder let content: Content
//    
//    var body: some View {
//        
//        ZStack {
//            
//            self.color
//                .opacity(0.15)
//                .ignoresSafeArea()
//            
//            ScrollView {
//                
//                VStack(spacing: 15) {
//                    
//                    HStack {
//                        
//                        ForEach(0..<self.depth, id: \.self) { _ in
//                            Capsule()
//                                .fill(.secondary)
//                                .frame(width: 4, height: 20)
//                        }
//                        
//                        Text(self.title)
//                            .font(.title2)
//                            .bold()
//                        
//                    }
//                    .padding(.top, 20)
//                    
//                    self.content
//                        .buttonStyle(TestButtonStyle())
//                        .padding(.horizontal)
//                    
//                }
//                
//            }
//            
//        }
//        .navigationTitle("")
//        .navigationBarTitleDisplayMode(.inline)
//        
//    }
//    
//}
//
//struct TestButtonStyle: ButtonStyle {
//    
//    func makeBody(configuration: Configuration) -> some View {
//        
//        configuration.label
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color.primary.opacity(0.05))
//            .cornerRadius(10)
//            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
//        
//    }
//    
//}
