////
////  SkeletonView.swift
////  SwiftyUI
////
////  Created by Sako Hovaguimian on 11/8/24.
////
//
//import SwiftUI
//
//struct ShimmerViewTestView: View {
//    
//    @State private var isLoading = true
//    
//    var body: some View {
//        
//        VStack {
//            
//            Text("Top Level")
//            
//            HStack {
//                
//                Text("Nested Level 1")
//                
//                VStack {
//                    Text("Nested Level 2A")
//                    Text("Nested Level 2B")
//                }
//                
//            }
//            
//            AppButton(title: "Some Button", action: {})
//            
//        }
//        .nestedShimmer(self.$isLoading)
//        
//    }
//    
//}
//
//#Preview {
//    ShimmerViewTestView()
//}
//
//// My Attempt
//
//struct NestedShimmerViewModifier: ViewModifier {
//    
//    @Binding var isLoading: Bool
//    
//    func body(content: Content) -> some View {
//        
//        Group {
//            
//            if isLoading {
//                applyShimmerRecursively(content: content)
//                
//            } else {
//                content
//            }
//            
//        }
//        
//    }
//    
//    @ViewBuilder
//    private func applyShimmerRecursively<V: View>(content: V) -> some View {
//        
//        content
//            .shimmer(isLoading)
//        
////        Group(subviews: content) { subviews in
//            
////            ForEach(subviews, id: \.id) { view in
//                
////                content
////                    .shimmer(isLoading)
//                
////                Group(subviews: view) { nestedSubview in
////                    if nestedSubview.isEmpty {
////                        return view
////                    } else {
////                        return EmptyView()
////                    }
////                }
//                
//            }
//            
////        }
//        
////    }
//    
//}
//
//extension View {
//    
//    func nestedShimmer(_ isLoading: Binding<Bool>) -> some View {
//        
//        self.modifier(NestedShimmerViewModifier(
//            isLoading: isLoading
//        ))
//        
//    }
//    
//}
