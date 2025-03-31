//
//  AnimatedSearchBarView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/7/23.
//

import SwiftUI

// Clean up
// image param
// height
// padding
// width
// binding text
// Trailing or leading for animation

struct AnimatedSearchBarView: View {
    
    @State private var text: String = "" // Make this binding
    @State private var isExpanded: Bool = false
    @State private var opacity: CGFloat = 0
    
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
                        .padding(.vertical, 12)
                    
                    Spacer()
                    
                }
                else {
                    
                    TextField(text: self.$text) {
                        Text(verbatim: "Search").foregroundColor(.gray.opacity(1))
                    }
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                    .font(.body)
                    .padding(.vertical, 12)
                    .padding(.leading, 16)
                    .fontDesign(.rounded)
                    .background {
                        Color.gray.opacity(0.1)
                    }
                    .opacity(self.opacity)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    
                }
                
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .frame(width: self.isExpanded ? UIScreen.main.bounds.width : 48)
            
        }
        .onTapGesture {
            
            withAnimation {
                self.isExpanded.toggle()
            }
            
        }
        .onChange(of: self.isExpanded) { oldValue, newValue in
            withAnimation(.spring().delay(0.2)) {
                self.opacity = newValue ? 1 : 0
            }
        }
        
    }
    
}

#Preview {
    AnimatedSearchBarView()
}
