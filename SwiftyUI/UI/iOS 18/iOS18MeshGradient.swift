//
//  iOS18MeshGradient.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/11/24.
//

import SwiftUI

struct iOSMeshView: View {
    
    var body: some View {
        
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.9, 0.3], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .blackedGray, .blackedGray, .blackedGray,
                .blue, .blue, .blue,
                .green, .green, .green
            ],
            smoothsColors: true
            
        )
        .ignoresSafeArea()
        
    }
    
}

#Preview {
    iOSMeshView()
}
