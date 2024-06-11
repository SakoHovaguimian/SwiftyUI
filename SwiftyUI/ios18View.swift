//
//  ios18View.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/10/24.
//

import SwiftUI

struct ios18View: View {
    
    @State private var currentOffset: CGRect = .zero
    
    var body: some View {
        
        ScrollView {
            
            LazyVStack {
                
                ForEach(0..<100) { index in
                    
                    AppCardView {
                        
                        VStack(alignment: .leading) {
                        
                            Text("Some Card Info")
                                .font(.title2)
                                .fontDesign(.monospaced)
                                .fontWeight(.semibold)
                            
                            Text("\(index)")
                                .font(.title3)
                                .fontWeight(.medium)
                            
                        }
                        
                    }
                    .padding(.horizontal, .medium)
                    
                }
                
            }
            
        }
        .overlay {
            
            if self.currentOffset.origin.y > 200 {
                
                Text("\(self.currentOffset.origin.y)")
                    .foregroundStyle(.white)
                    .padding(.medium)
                    .background(.black)
                    .transition(.opacity)
                    .contentTransition(.numericText())
                
            }
            
        }
        .onScrollGeometryChange(for: CGRect.self) { geo in
            return geo.bounds
        } action: { oldValue, newValue in
            self.currentOffset = newValue
        }
        .animation(.spring, value: self.currentOffset)
        
    }
    
}

#Preview {
    ios18View()
}

