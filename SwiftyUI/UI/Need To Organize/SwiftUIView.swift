//
//  SwiftUIView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/29/24.
//

import SwiftUI

struct MilestonesView: View {
    
    @State private var completedMilestones: [Int] = []
    
    let columns = [
        
        GridItem(
            .flexible(minimum: 80),
            spacing: .appSmall
        ),
        GridItem(
            .flexible(minimum: 80),
            spacing: .appSmall
        ),
        
    ]
    
    var body: some View {
        
        BaseHeaderScrollView {
            
            NavBarView(
                navBarStyle: .standard(
                    .init(
                        title: "Milestones",
                        subtitle: "See What Next"
                    )),
                backgroundStyle: .material(.ultraThinMaterial)
            )
            
        } scrollViewContent: {
            
            LazyVGrid(
                columns: self.columns,
                alignment: .center,
                spacing: .appSmall) {
                    
                    blueViewList()
                    
                }
            
        }
        
    }
    
    private func blueViewList() -> some View {
        
        ForEach(0..<25) { index in
            blueView(index: index)
        }
        
    }
    
    private func blueView(index: Int) -> some View {
        
        return RoundedRectangle(cornerRadius: .appLarge)
            .fill(.darkBlue)
            .aspectRatio(contentMode: .fit)
            .overlay {
                
                Text("\(index)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                
            }
            .overlay(alignment: .topTrailing) {
                
                if hasCompletedMilestone(index: index) {
                    
                    CircularIconView(
                        foregroundColor: .blue,
                        size: 32,
                        systemImage: "checkmark"
                    )
                    .padding([.top, .trailing], .medium)
                    .transition(.scale.combined(with: .opacity))
                    
                }
                
            }
            .onTapGesture {
                
                withAnimation(.bouncy) {
                    self.handleSelectOrDeselectMilestone(index: index)
                }
                
            }
        
    }
    
    private func handleSelectOrDeselectMilestone(index: Int) {
        
        if hasCompletedMilestone(index: index) {
            self.completedMilestones.removeAll(where: { $0 == index })
        }
        else {
            self.completedMilestones.append(index)
        }
        
    }
    
    private func hasCompletedMilestone(index: Int) -> Bool {
        return self.completedMilestones.contains(index)
    }
    
}

#Preview {
    MilestonesView()
}
