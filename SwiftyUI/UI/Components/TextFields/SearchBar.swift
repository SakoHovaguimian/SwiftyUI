//
//  SearchBar.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/29/24.
//

import SwiftUI

struct SearchBar: View {
    
    @State private var searchText: String = ""
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            Image (systemName: "magnifyingglass")
                .font (.title3)
            
            TextField(
                "Search Conversations",
                text: self.$searchText
            )
            
        }
        .padding (.horizontal, 15)
        .frame (height: 45)
        .background {
            RoundedRectangle (cornerRadius: 25)
                .fill(.background)
        }
        .padding(.horizontal, 15)
        .shadow(radius: 4)
        
    }
    
}

#Preview {
    SearchBar()
}

#Preview {
    
    ZStack {
        
        Color(.systemGray4)
            .ignoresSafeArea()
        
        SearchBar()
        
    }
    
}
