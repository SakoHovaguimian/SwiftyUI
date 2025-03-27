//
//  StaggeredView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/26/25.
//

import SwiftUI

struct StaggeredView<Content: View>: View {
    
    @ViewBuilder var content: Content
    var config: StaggeredConfig
    
    init(config: StaggeredConfig,
         @ViewBuilder content: () -> Content) {
        
        self.content = content()
        self.config = config
        
    }
    
    var body: some View {
        
        Group(subviews: content) { collection in
            
            ForEach(collection.indices, id: \.self) { index in
                
                collection[index]
                    .transition(CustomStaggeredTransition(index: index, config: config))
                
            }
            
        }
        
    }
    
}

#Preview {
    
    @Previewable @State var showView: Bool = false

    let config = StaggeredConfig(
        delay: 0,
        maxDelay: 0,
        blurRadius: 2,
        offset: .init(width: 300, height: 0),
        scale: 1,
        scaleAnchor: .center,
        noDisappearAnimation: true
    )
        
    VStack(spacing: 12) {
        
        AppButton(
            title: "Toggle View",
            titleColor: .white,
            backgroundColor: .darkBlue
        ) {
            showView
                .toggle()
        }
        .padding(.horizontal, .large)
        
        LazyVGrid(columns: Array(repeating: GridItem(),
                                 count: 2)) {
            
            StaggeredView(config: config) {
                
                if showView {
                    
                    ForEach(1...8, id: \.self) { _ in
                        
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.gradient)
                            .frame(height: 150)
                        
                    }
                    
                }
                
            }
            
        }
        .padding(Spacing.medium.value)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        
    }
    
}
