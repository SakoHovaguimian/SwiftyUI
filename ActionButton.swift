//
//  ActionButton.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/24/25.
//

import SwiftUI

// Close on selection flag
// Alignment + x / y offset helper for knowing which direction to animate from
// Break down views to helper methods
// Pass in animation

struct ActionButton<CollapsedContent: View, ExpandedContent: View>: View {
    
    @Binding var isExpanded: Bool
    let collapsedContent: () -> CollapsedContent
    let expandedContent: () -> ExpandedContent
    
    @State private var expandedContentSize: CGSize = .zero
    
    var body: some View {
        
        ZStack(alignment: .bottomTrailing) {
            
            self.expandedContent()
                .onGeometryChange(for: CGSize.self, of: { proxy in
                    return proxy.size
                }, action: { newValue in
                    self.expandedContentSize = newValue
                })
                .scaleEffect(self.isExpanded ? 1 : 0)
                .opacity(self.isExpanded ? 1 : 0)
                .offset(
                    x: self.isExpanded ? 0 : expandedContentSize.width / 2,
                    y: self.isExpanded ? 0 : expandedContentSize.height / 2
                )
            
            self.collapsedContent()
                .scaleEffect(self.isExpanded ? 0 : 1)
                .opacity(self.isExpanded ? 0 : 1)
            
        }
        .animation(.bouncy(duration: 0.3, extraBounce: 0.15), value: self.isExpanded)
        .fixedSize(horizontal: false, vertical: true)
        
    }
    
}

#Preview {
    
    @Previewable @State var isExpanded: Bool = false
    @Previewable @State var includesExtraButton: Bool = false
    
    ZStack(alignment: .bottomTrailing) {
        
        Color.black.opacity(0.25).ignoresSafeArea()
        
        ActionButton(isExpanded: $isExpanded) {
            
            Image(systemName: "eye")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .foregroundStyle(.black)
                .padding(8)
                .background(.white)
                .clipShape(.circle)
            
        } expandedContent: {
            
            VStack {
                
                if includesExtraButton {
                    
                    Capsule()
                        .fill(.black.opacity(0.2))
                        .frame(height: 50)
                        .onTapGesture {
                            
                            print("TESTING")
                            isExpanded.toggle()
                            
                        }
                        .transition(.scale.combined(with: .opacity))
                    
                }
                
                Capsule()
                    .fill(.black.opacity(0.2))
                    .frame(height: 50)
                    .onTapGesture {
                        
                        print("TESTING")
                        isExpanded.toggle()
                        
                    }
                
                HStack {
                    
                    Circle()
                        .fill(.black.opacity(0.2))
                        .frame(height: 40)
                        .onTapGesture {
                            includesExtraButton.toggle()
                        }
                    
                    Circle()
                        .fill(.black.opacity(0.2))
                        .frame(height: 40)
                    
                    Circle()
                        .fill(.black.opacity(0.2))
                        .frame(height: 40)
                    
                }
                
                Capsule()
                    .fill(.black.opacity(0.2))
                    .frame(height: 50)
                
            }
            .fixedSize(horizontal: true, vertical: false)
            .padding(.vertical, 24)
            .padding(.horizontal, 24)
            .background(.white)
            .compositingGroup()
            .geometryGroup()
            .clipShape(.rect(cornerRadius: 32))
            .shadow(radius: 0.8)
            
        }
        .padding(.trailing, .medium)
        .onTapGesture {
            isExpanded.toggle()
        }
        .animation(.bouncy(extraBounce: 0.2), value: includesExtraButton)
        
    }
    
}
