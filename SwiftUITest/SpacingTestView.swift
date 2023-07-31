//
//  SpacingTestView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/27/23.
//

import SwiftUI

// Usage example:
struct SpacingTestView: View {
    
    var body: some View {
        
        VStack(spacing: 0) {
         
            Text("Hello, World!")
                .frame(maxWidth: .infinity)
                .background(.red)
                .padding(.horizontal, .large)

            Text("Hello, World!")
                .frame(maxWidth: .infinity)
                .background(.red)
                .padding(.horizontal, .medium)

            Text("Hello, World!")
                .frame(maxWidth: .infinity)
                .background(.red)
                .padding(.vertical, .large)
            
        }
        
    }
    
}

#Preview {
    SpacingTestView()
}
