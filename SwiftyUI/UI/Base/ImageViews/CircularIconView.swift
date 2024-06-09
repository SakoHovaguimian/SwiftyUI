//
//  CircularIconView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/4/23.
//

import SwiftUI

struct CircularIconView: View {
    
    var foregroundColor: Color
    var backgroundColor: Color = ThemeManager.shared.background(.tertiary)
    
    var size: CGFloat

    var systemImage: String? = nil
    var image: String? = nil
    
    var imageSize: CGFloat {
        return self.size / 2
    }
    
    var body: some View {

        return ZStack {
            
            Circle()
                .fill(self.backgroundColor)
                .frame(width: self.size, height: self.size)
            
            if let systemImage {
                
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: self.imageSize, height: self.imageSize)
                    .foregroundColor(self.foregroundColor)
                
            }
            else if let image {
                
                Image(image)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: self.imageSize, height: self.imageSize)
                    .foregroundColor(self.foregroundColor)
                
            }
            
        }
        
    }
    
}

struct BackButton: View {
    
    private var backAction: (() -> ())
    
    init(backAction: @escaping () -> Void) {
        self.backAction = backAction
    }
    
    var body: some View {
        
        CircularIconView(
            foregroundColor: .black,
            backgroundColor: ThemeManager.shared.background(.tertiary),
            size: 32,
            systemImage: "arrow.left"
        )
        .asButton {
            self.backAction()
        }
        
    }
    
}

#Preview {
    
    CircularIconView(
        foregroundColor: .white,
        backgroundColor: .pink,
        size: 128,
        systemImage: "person.fill"
    )
    .asButton {
        print("Something")
    }
    
}
