//
//  BoomView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/23/23.
//

import SwiftUI

struct BoomView: View {
    
    @State var animateText: Bool = false
    
    var body: some View {
        
        VStack {
            
            Spacer()
            Boom(animate: self.animateText)
            Spacer()
            Button("Go") {
                animateText.toggle()
            }
            
        }
    }
}

struct Boom: View {
    
    var sentence = "The quick brown fox jumps over the lorem ipsum"
    var animate: Bool
    
    var body: some View {
        
        HStack {
            
            ForEach(self.sentence.split(separator: " "), id: \.self) { word in
                
                Text(word)
                    .rotationEffect(.degrees(self.animate ? Double(Int.random(in: -270...270)) : 0))
                    .offset(
                        x: self.animate ? CGFloat(Int.random(in: -600...600)) : 0,
                        y: self.animate ? CGFloat(Int.random(in: -600...600)) : 0
                    )
                
            }
            
        }
        .font(.body)
        .animation(.spring().speed(0.7), value: self.animate)
        
    }
    
}

struct BoomView_Previews: PreviewProvider {
    static var previews: some View {
        BoomView()
    }
}
