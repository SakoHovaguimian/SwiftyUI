//
//  ProgressBar.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/16/25.
//

import SwiftUI

struct ProgressBar: View {
    
    @Binding var value: Float
    
    var trackColor: Color
    var fillColor: Color
    var shouldRound: Bool = true
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let fillValue = min(CGFloat(self.value) * geometry.size.width, geometry.size.width)
            
            ZStack(alignment: .leading) {
                
                // Track
                
                Rectangle()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .opacity(0.3)
                    .foregroundColor(self.trackColor)
                
                // Fill
                
                Rectangle()
                    .frame(
                        width: fillValue,
                        height: geometry.size.height
                    )
                    .foregroundColor(self.fillColor)
                    .animation(.spring(), value: fillValue)
            }
            .if(self.shouldRound) { view in
                view.clipShape(.capsule)
            }
        }
    }
    
}

#Preview {
    
    ProgressBar(
        value: .constant(0.8),
        trackColor: .green.opacity(0.8),
        fillColor: .green
    )
    .frame(maxWidth: .infinity, maxHeight: 20)
    .padding(24)
    
}
