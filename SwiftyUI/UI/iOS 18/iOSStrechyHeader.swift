//
//  iOSStrechyHeader.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/12/24.
//

import SwiftUI

struct iOSStrechyHeader: View {
    
    @State private var offset: CGFloat = 0
    
    private var imageHeight: CGFloat {
        return 300 + self.offset
    }
    
    var body: some View {
        
        ScrollView {
        
            Image(.image1)
                .resizable()
//                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .frame(height: self.imageHeight)
                .offset(y: -offset)
                
            
            Rectangle()
                .background(.red)
                .frame(height: 500)
            
        }
        .scrollBounceBehavior(.always)
        .ignoresSafeArea([.container])
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            
            return abs(min(geometry.contentOffset.y, 0))
            
        } action: { oldValue, newValue in
            
            self.offset = newValue
            
        }
        
    }
    
}

#Preview {
    
    iOSStrechyHeader()
    
}
