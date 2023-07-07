//
//  AnimatedSearchBarView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/7/23.
//

import SwiftUI

// NOTES
/// ZStack trialing
/// Animate width of whole container and corner radius of whole container
/// Add overlay to whole container
///
struct AnimatedSearchBarView: View {
    
    @State private var text: String = ""
    @State private var isExpanded: Bool = false
    
    var body: some View {
        
        ZStack(alignment: .trailing) {
            
            Color.black
                .ignoresSafeArea()
            
            HStack {
                
                if !isExpanded {
                    
                    Spacer()
                    
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFill()
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                    
                    Spacer()
                    
                }
                else {
                    
                    TextField(text: self.$text) {
                        Text(verbatim: "Search").foregroundColor(.gray.opacity(1))
                    }
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                    .font(.body)
                    .fontDesign(.rounded)
                    .background {
                        Color.gray.opacity(0.1)
                    }
                    
                }
                
            }
            .padding(.vertical, 12)
            .frame(width: self.isExpanded ? UIScreen.main.bounds.width : 48)
            .overlay(
                RoundedRectangle(cornerRadius: self.isExpanded ? 12 : 12)
                    .stroke(Color.blue, lineWidth: 2)
            )
            
        }
        .onTapGesture {
            withAnimation {
                self.isExpanded.toggle()
            }
        }
        
    }
    
}

#Preview {
    AnimatedSearchBarView()
}
