//
//  HueView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/3/24.
//

import SwiftUI

struct HueView: View {
    
    var body: some View {
        
        ZStack {
            
            Image(.prize)
                .resizable()
                .scaledToFit()
                .phaseAnimator([false, true]) { image, chromaRotate in
                    
                    image
                        .hueRotation(.degrees(chromaRotate ? 420 : 0))
                    
                } animation: { chromaRotate in
                        .easeInOut(duration: 2)
                }
        }
        
    }
    
}

#Preview {
    
    HueView()
        .preferredColorScheme(.dark)
    
}
