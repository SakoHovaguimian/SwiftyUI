//
//  BottomTransitionTest.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/6/25.
//

import SwiftUI

enum ViewState {
    
    case first
    case second
    
}

struct BottomTransitionTest: View {
    
    @State private var state: ViewState? = nil
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            Color(uiColor: .systemGray6)
                .ignoresSafeArea()
                .onTapGesture {
                    self.state = .first
                }
            
            if let state {
                
                bottomView(state: state)
                    .transition(.move(edge: .bottom).combined(with: .blurReplace))
                
            }
            
        }
        .animation(.smooth, value: self.state)
        
    }
    
    private func bottomView(state: ViewState) -> some View {
        
        GroupBox {
         
            switch state {
            case .first: firstView()
            case .second: secondView()
            }
            
        }
        .clipped()
        .geometryGroup()
        .compositingGroup()
        .shadow(radius: 8)
        .padding(.horizontal, .large)
        
    }
    
    private func firstView() -> some View {
            
        VStack {
            
            Color.darkBlue
                .frame(height: 300)
            
        }
        .onTapGesture {
            self.state = .second
        }
        .geometryGroup()
        .compositingGroup()
        .clipShape(.rect(cornerRadius: .appSmall))
        .transition(.blurReplace)
        
    }
    
    private func secondView() -> some View {
            
        VStack {
            
            Color.darkPurple
                .frame(height: 500)
            
        }
        .onTapGesture {
            self.state = nil
        }
        .geometryGroup()
        .compositingGroup()
        .clipShape(.rect(cornerRadius: .appSmall))
        .transition(.blurReplace)
        
    }
    
}

#Preview {
    
    BottomTransitionTest()
    
}
