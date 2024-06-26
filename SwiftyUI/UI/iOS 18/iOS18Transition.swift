//
//  ios18Transition.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/10/24.
//

import SwiftUI

struct Item: Hashable {
    
    var namespace: Namespace.ID
    var item: String
    
}

struct iOS18Transition: View {
    
    @State private var routes: [Item] = []
    @State private var items: [String] = [
        "Chainmail",
        "Sword",
        "Goblin Skin",
        "Wand",
        "Fairy Fire"
    ]
    
    var body: some View {
        
        NavigationStack(path: self.$routes) {
            
            VStack {
                
                ForEach(self.items, id: \.self) { item in
                    
                    ParentView(id: item) { passedItem in
                        self.routes.append(passedItem)
                    }
                    
                }
                
            }
            .navigationDestination(for: Item.self) { item in
                
                ParentDetailView(id: item.item)
                    .navigationTransition(.zoom(
                        sourceID: item.item,
                        in: item.namespace
                    ))
                
            }
            
        }
        
    }
    
}

struct ParentView: View {
    
    @Namespace() private var namespace
    var id: String
    
    var onTapHandler: (Item) -> ()
    
    var body: some View {
        
        AppCardView {
            
            Text(self.id)
            
        }
        .onTapGesture {
            self.onTapHandler(
                .init(
                    namespace: self.namespace,
                    item: self.id
                )
            )
        }
        .matchedTransitionSource(id: self.id, in: self.namespace, configuration: { config in
            
            config
                .clipShape(.rect(cornerRadius: CornerRadius.small2.rawValue))
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 5,
                    x: 0,
                    y: 0
                )
                .background(.clear)
            
        })
        .padding(.horizontal, .medium)
        
    }
    
}

struct ParentDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var id: String
    
    var body: some View {
        
        ZStack {
            
            Color.darkBlue
                .ignoresSafeArea()
            
            VStack {
                
                AppCardView {
                    
                    Text(self.id)
                    
                }
                .padding(.horizontal, .medium)
                .onTapGesture {
                    dismiss()
                }
                .frame(height: 400)
                .background(.white)
                .clipShape(.rect(cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: 32,
                    bottomTrailing: 32,
                    topTrailing: 0
                )))
                .ignoresSafeArea()
                
                Spacer()
                
            }
            
        }
        
    }
    
}

#Preview {
    iOS18Transition()
}
