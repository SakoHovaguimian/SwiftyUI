//
//  ios18Animation.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/11/24.
//

import SwiftUI

enum ImageStyle {
    
    case checkmark
    case xmark
    
    var systemName: String {
        switch self {
        case .checkmark: return "checkmark.circle"
        case .xmark: return "xmark.circle"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .checkmark: return .brandGreen
        case .xmark: return .brandPink
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .checkmark: return .darkGreen
        case .xmark: return .darkPurple
        }
    }
    
}

struct iOS18Animation: View {
    
    @State private var selectedImageStyle = ImageStyle.checkmark
    @State private var shouldAnimate: Bool = false
    
    var body: some View {
        
        ZStack {
            
            self.selectedImageStyle
                .backgroundColor
                .ignoresSafeArea()
            
            Image(systemName: self.selectedImageStyle.systemName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundStyle(self.selectedImageStyle.accentColor)
                .frame(width: 64, height: 64)
//                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.wiggle, options: .speed(0.1) ,value: self.shouldAnimate)
            
        }
        .onAppear {
            self.shouldAnimate = true
        }
        .onTapGesture {
            withAnimation {
                
                let newSelectedImageStyle: ImageStyle = (self.selectedImageStyle == .checkmark ? .xmark : .checkmark)
                self.selectedImageStyle = newSelectedImageStyle
                
            }
            
        }
        
    }
    
}

#Preview {
    iOS18Animation()
}
