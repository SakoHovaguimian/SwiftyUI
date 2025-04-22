//
//  ButtonAnimationState.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/18/25.
//

import SwiftUI

struct ButtonAnimationState: View {
    
    enum AnimationState {
        
        case idle
        case loading
        case completed
        
        var title: String {
            switch self {
            case .idle: return "Click Button"
            case .loading: return "..."
            case .completed: return "Completed!"
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .idle: return Color.blue
            case .loading: return Color.darkBlue
            case .completed: return Color.darkGreen
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .idle: return 8
            case .loading: return 99
            case .completed: return 16
            }
        }
        
        var width: CGFloat {
            switch self {
            case .idle: return 150
            case .loading: return 50
            case .completed: return 200
            }
        }
        
    }
    
    @State private var state: AnimationState = .idle
    
    var body: some View {
        
        AppButton(
            title: self.state.title,
            titleColor: .white,
            style: .fill,
            font: .title(.t5),
            backgroundColor: self.state.backgroundColor,
            systemImage: self.state == .completed ? "checkmark.circle.fill" : nil,
            image: nil,
            height: 50,
            cornerRadius: self.state.cornerRadius,
            isEnabled: true,
            horizontalPadding: 8,
            action: {
                Task {
                    await executeAnimation()
                }
            }
        )
        .frame(maxWidth: self.state.width)
        .padding(.horizontal, .xLarge)
        .contentTransition(.interpolate)
        .animation(.bouncy(duration: 0.25), value: self.state)
        
    }
    
    private func executeAnimation() async {
        
        self.state = .idle
        try? await Task.sleep(for: .seconds(2))
        
        self.state = .loading
        try? await Task.sleep(for: .seconds(2))
        
        self.state = .completed
        try? await Task.sleep(for: .seconds(2))
        
        self.state = .idle
        
    }
    
}

#Preview {
    
    ButtonAnimationState()
    
}
