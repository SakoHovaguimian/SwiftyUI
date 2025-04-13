//
//  ScrollFilters.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/8/24.
//

import SwiftUI

struct FilterView: View {
    
    let title: String
    let isSelected: Bool
    
    var body: some View {
        
        HStack {
            
            Text(self.title)
                .font(.title3)
                .foregroundStyle(.black)
            
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background {
            
            ZStack {
                
                Capsule(style: .circular)
                    .fill(.blue.opacity(0.5))
                    .opacity(self.isSelected ? 1 : 0)
                
                Capsule(style: .circular)
                    .strokeBorder(self.isSelected ? .black : .black, lineWidth: 1)

            }
            
        }
        
    }
    
}

struct FiltersView: View {
    
    var filters: [String]
    var selectedFilter: String? = nil
    var onFilterTapped: (String) -> ()
    var onCloseTapped: () -> ()
    
    @State private var isUserInteractionEnabled: Bool = true
    
    var body: some View {
        
        ScrollView(.horizontal) {
            
            HStack {
                
                if self.selectedFilter != nil {
                    
                    Image(systemName: "xmark")
                        .padding(10)
                        .background {
                            Circle()
                                .stroke(.black)
                        }
                        .transition(AnyTransition(.move(edge: .leading)).combined(with: .opacity))
                        .onTapGesture {
                            
                            withAnimation(.bouncy) {
                                onCloseTapped()
                            }
                            
                        }
                    
                }
                
                ForEach(self.filters, id: \.self) { filter in
                    
                    if selectedFilter == nil || selectedFilter == filter {
                        
                        FilterView(
                            title: filter,
                            isSelected: selectedFilter == filter
                        )
                        .onTapGesture {
                            
                            throttleTouch()
                            onFilterTapped(filter)
                            
                        }
                        
                    }
                    
                }
                
            }
            .allowsHitTesting(self.isUserInteractionEnabled)
            .animation(.bouncy(duration: 0.5), value: selectedFilter)
            .padding(.leading, 16)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func throttleTouch() {
        
        self.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            self.isUserInteractionEnabled = true
        })
        
    }

}

struct FiltersViewPreview: View {
    
    var filters = ["Sako", "Mitch", "KC", "Michael"]
    @Binding var selectedFilter: String?
    
    var body: some View {
        
        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            VStack {
                FiltersView(filters: filters,
                selectedFilter: selectedFilter) { filter in
                    self.selectedFilter = filter
                } onCloseTapped: {
                    self.selectedFilter = nil
                }

            }
            
        }
        
    }
    
}

struct MainScreen: View {
    
    @State var selectedFilter: String? = nil

    var body: some View {
        VStack {
            
//            Text("SelectedFilter: \(selectedFilter ?? "")")
//                .font(.largeTitle)
            
            FiltersViewPreview(selectedFilter: $selectedFilter)
            
        }
    }
}

#Preview {
    MainScreen()
}
