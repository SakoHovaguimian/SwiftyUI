//
//  ScrollOnlyOnOverflowView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 8/11/23.
//

import SwiftUI

struct ScrollOnlyOnOverflowView: View {
    
    var body: some View {
        
        List {
           
//            ForEach(0..<3) {_ in 
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green)
                    .frame(maxWidth: .infinity)
                    .frame(height: 1000)
                    .padding(.horizontal, .large)
                    .onTapGesture {
                        print("sss")
                    }
                    .plainListRowStyle()
                
//            }
            
        }
        .plainListStyle()
//        .frame(maxWidth: .infinity)
//        .background(Color.red)
        
    }
    
}

#Preview {
    ScrollOnlyOnOverflowView()
}


struct PlainList: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .listSectionSeparator(.hidden, edges: .all)
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .listStyle(.plain)
            .listRowInsets(EdgeInsets())

    }
    
}

extension View {
    func plainListStyle() -> some View {
        modifier(PlainList())
    }
}

struct PlainListRow: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .listRowSpacing(0)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

    }
    
}

extension View {
    func plainListRowStyle() -> some View {
        modifier(PlainListRow())
    }
}
