//
//  MatchedGeoView2.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/17/25.
//

import SwiftUI

struct MatchedGeoView2: View {
    
    struct Item: Identifiable, Equatable {
        
        var id: String = UUID().uuidString
        var name: String
        var color: Color
        
        static func DUMMY_DATA() -> [Self] {
            [
                .init(name: "Item 1", color: .green),
                .init(name: "Item 2", color: .blue),
                .init(name: "Item 3", color: .red),
                .init(name: "Item 4", color: .purple),
                .init(name: "Item 5", color: .yellow),
                .init(name: "Item 6", color: .mint),
            ]
        }
        
    }
    
    @Namespace var animation
    @State private var items: [Item] = Item.DUMMY_DATA()
    @State private var selectedItem: Item? = nil
    
    var body: some View {
        
        VStack {
            
            Text("My Values")
//                .overlay(alignment: .bottom) {
//                    
//                    if let selectedItem {
//                        
//                        Rectangle()
//                            .fill(selectedItem.color)
//                            .frame(width: 200, height: 5, alignment: .center)
//                            .matchedGeometryEffect(id: selectedItem.id, in: self.animation)
//                        
//                    }
//                    
//                }
            
            HStack {
                itemListView()
            }
            
        }
        
    }
    
    private func itemListView() -> some View {
        
        ForEach(self.items) { item in
            
//            if item != self.selectedItem {
                itemView(item)
//            }
            
        }
        
    }
    
    private func itemView(_ item: Item) -> some View {
        
        ZStack {
            
            if item == self.selectedItem {
                
                Circle()
                    .fill(item.color.opacity(0.5))
                    .matchedGeometryEffect(id: item.id, in: self.animation)
                    .frame(width: 10, height: 30)
                    .onTapGesture {
                        selectItem(item)
                    }
                
            } else {
                
                Circle()
                    .fill(item.color.opacity(0.5))
                    .matchedGeometryEffect(id: item.id, in: self.animation)
                    .frame(width: 80, height: 80)
                    .onTapGesture {
                        selectItem(item)
                    }
                
            }
            
        }
        
    }
    
    private func selectItem(_ item: Item) {
        
        withAnimation(.smooth(duration: 1)) {
            self.selectedItem = item
        }
        
    }
    
}

#Preview {
    
    MatchedGeoView2()
    
}

struct MatchedGeoView3: View {
    
    struct Item: Identifiable, Equatable {
        
        var id: String = UUID().uuidString
        var name: String
        var color: Color
        
        static func DUMMY_DATA() -> [Self] {
            [
                .init(name: "Item 1", color: .green),
                .init(name: "Item 2", color: .blue),
                .init(name: "Item 3", color: .red),
            ]
        }
        
    }
    
    @Namespace var animation
    @State private var items: [Item] = Item.DUMMY_DATA()
    @State private var selectedItem: Item? = nil
    
    var body: some View {
        
        VStack {
            
            HStack(spacing: 0) {
                itemListView()
            }
            
        }
        
    }
    
    private func itemListView() -> some View {
        
        ForEach(self.items) { item in
            
//            if item != self.selectedItem {
                itemView(item)
//            }
            
        }
        
    }
    
    private func itemView(_ item: Item) -> some View {
        
        VStack {
            
            Text(item.name)
                .frame(maxWidth: .infinity)
                .asButton {
                    print(item.name)
                    selectItem(item)
                }
            
            if item.id == self.selectedItem?.id {
                
                Rectangle()
                    .fill(.green)
                    .matchedGeometryEffect(id: "1", in: self.animation)
                    .frame(height: 20)

                
            } else {
                
                Rectangle()
                    .fill(.clear)
                    .frame(height: 20)
                
            }
            
        }
        
    }
    
    private func selectItem(_ item: Item) {
        
        withAnimation(.smooth(duration: 1)) {
            self.selectedItem = item
        }
        
    }
    
}

#Preview {
    
    MatchedGeoView3()
    
}
