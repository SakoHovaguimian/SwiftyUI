//
//  CustomProgressBar.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/13/23.
//

import SwiftUI

struct CustomProgressBar: View {
    
    @Binding var value: Float
    
    var trackColor: Color
    var fillColor: Color
    
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
            .clipShape(Capsule())
        }
    }
    
}

struct CustomProgressBar_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CustomProgressBar(
            value: .constant(0.8),
            trackColor: .green.opacity(0.8),
            fillColor: .green
        )
        .frame(maxWidth: .infinity, maxHeight: 20)
        .padding(24)
        
    }
    
}
