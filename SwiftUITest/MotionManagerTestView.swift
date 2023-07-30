//
//  MotionManagerTestView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/30/23.
//

//
//  ContentView.swift
//  MotionManagerTest
//
//  Created by Sako Hovaguimian on 7/30/23.
//

import SwiftUI
import CoreMotion

struct ParallaxMotionTestView: View {

    @ObservedObject var manager = MotionManager()
    
    var body: some View {
        
        ZStack {
            
            Color.red
                .cornerRadius(7)
                .frame(width: 300, height: 200, alignment: .center)
                .modifier(ParallaxMotionModifier(manager: manager, magnitude: 20))
                .shadow(color: .gray.opacity(1), radius: 3, x: 0, y: 0)
            
            Color.blue
                .cornerRadius(7)
                .frame(width: 260, height: 160, alignment: .center)
                .modifier(ParallaxMotionModifier(manager: manager, magnitude: 35))
                .shadow(color: .gray.opacity(1), radius: 3, x: 0, y: 0)
            
            Color.green
                .cornerRadius(7)
                .frame(width: 220, height: 120, alignment: .center)
                .modifier(ParallaxMotionModifier(manager: manager, magnitude: 40))
                .shadow(color: .gray.opacity(1), radius: 3, x: 0, y: 0)
            
            Color.indigo
                .cornerRadius(7)
                .frame(width: 180, height: 80, alignment: .center)
                .modifier(ParallaxMotionModifier(manager: manager, magnitude: 55))
                .shadow(color: .gray.opacity(1), radius: 3, x: 0, y: 0)
            
            Color.yellow
                .cornerRadius(7)
                .frame(width: 140, height: 40, alignment: .center)
                .modifier(ParallaxMotionModifier(manager: manager, magnitude: 60))
                .shadow(color: .gray.opacity(1), radius: 3, x: 0, y: 0)
            
            Color.orange
                .cornerRadius(7)
                .frame(width: 100, height: 10, alignment: .center)
                .modifier(ParallaxMotionModifier(manager: manager, magnitude: 75))
                .shadow(color: .gray.opacity(1), radius: 3, x: 0, y: 0)
            
        }
        .rotation3DEffect(.degrees(self.manager.roll * 20), axis: (x: 10, y: 1, z: 10))
        
    }
}

#Preview {
    ParallaxMotionTestView()
}

