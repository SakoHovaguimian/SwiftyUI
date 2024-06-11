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

struct ios18Transition: View {
    
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
        .matchedTransitionSource(id: self.id, in: self.namespace)
        
    }
    
}

struct ParentDetailView: View {
    
    var id: String
    
    var body: some View {
        
        AppCardView {
            
            Text(self.id)
            
        }
        
    }
    
}

#Preview {
    ios18Transition()
}
