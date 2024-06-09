//
//  PlainList.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI

// MARK: - ViewModifiers

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
