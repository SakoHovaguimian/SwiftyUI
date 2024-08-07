//
//  NeonGlowView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/7/24.
//

import SwiftUI

import SwiftUI

struct NeonGlow: ViewModifier {
    
    var color: Color
    
    func body(content: Content) -> some View {
        
        content
            .shadow(color: color, radius: 5)
            .shadow(color: color, radius: 10)
            .shadow(color: color, radius: 50)
            .shadow(color: color, radius: 100)
            .shadow(color: color, radius: 200)
    }
    
}

extension View {
    
    func addNeonEffect(color: Color) -> some View {
        self.modifier(NeonGlow(color: color))
    }
    
}

import SwiftUI

struct NeonGlowView: View {
    
    @State private var index = 0
    
    private let colors: [Color] = [.green, .pink, .blue, .orange, .purple]
    private let titles: [String] = ["NEON", "GLOW", "LIGHT", "SHINE", "BRIGHT"]
    
    var body: some View {
        
        VStack {
            
            Text(titles[index])
                .font(.system(size: 70, weight: .ultraLight))
                .frame(width: 250)
                .addNeonEffect(color: colors[index])
                .contentTransition(.numericText())
                .onAppear {
                    
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                        withAnimation(.smooth(duration: 2)) {
                            index = (index + 1) % colors.count
                        }
                        
                    }
                    
                }
            
        }
        
    }
    
}

struct NeonGlowView_Previews: PreviewProvider {
    static var previews: some View {
        NeonGlowView()
    }
}
