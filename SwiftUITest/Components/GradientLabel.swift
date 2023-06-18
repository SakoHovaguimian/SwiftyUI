//
//  GradientLabel.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/15/23.
//

import SwiftUI

/*
 
MARK: - Note
If using iOS 15 and above
`foregroundStyle` accepts gradients now.
 
 Text(“Gradient”)
     .foregroundStyle(
         .linearGradient(
             colors: [.red, .blue],
             startPoint: .top,
             endPoint: .bottom
         )
     )
 
*/

struct GradientLabel: View {
    
    var text: String
    var gradient: Gradient
    var startPoint: UnitPoint
    var endPoint: UnitPoint
    
    init(text: String,
         gradient: Gradient = Gradient(colors: [.purple, .indigo.opacity(0.1)]),
         startPoint: UnitPoint = .topLeading,
         endPoint: UnitPoint = .bottomTrailing) {
        
        self.text = text
        self.gradient = gradient
        self.startPoint = startPoint
        self.endPoint = endPoint
        
    }
    
    var body: some View {
        
        LinearGradient(
            gradient: self.gradient,
            startPoint: self.startPoint,
            endPoint: self.endPoint
        )
        .mask(Text(self.text))
        
    }
    
}

struct GradientLabel_Previews: PreviewProvider {
    static var previews: some View {
        
        GradientLabel(text: "Gradient Label Test")
            .font(.system(size: 64))
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
        
    }
}
