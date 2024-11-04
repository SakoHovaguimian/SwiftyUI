//
//  ios18Subviews.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/11/24.
//

import SwiftUI

//struct SubviewTestView<Content: View>: View {
//    
//    @ViewBuilder var content: Content
//    
//    var body: some View {
//        
//        VStack(alignment: .leading) {
//            
//            Group(sections: content) { subviews in
//                
//                VStack(alignment: .leading) {
//                    
//                    if !subviews.isEmpty {
//                        let _ = print("Less than 1 subview")
//                        subviews[0]
//                    }
//                    
//                    if subviews.count > 1 {
//                        let _ = print("More than 1 subview")
//                        subviews[1]
//                    }
//                    
//                }
//                
//                if subviews.count > 2 {
//                    
//                    VStack {
//                        subviews[2...]
//                    }
//                    
//                }
//                
//            }
//            
//        }
//        
//    }
//    
//}
//
//#Preview {
//    
//    SubviewTestView {
//        
//        HStack {
//            
//            // Note each stack is it's own count
//            Label("Person", systemImage: "person.fill")
//                .foregroundStyle(.brandPink.gradient)
//            
//        }
//        
//        HStack {
//            
//            // Note each stack is it's own count
//            Label("Money", systemImage: "dollarsign.square.fill")
//                .foregroundStyle(.brandPink.gradient)
//            
//        }
//        
//        HStack {
//            
//            // Note each stack is it's own count
//            Label("Home", systemImage: "house.fill")
//                .foregroundStyle(.brandPink.gradient)
//            
//        }
//        
//    }
//    
//}
