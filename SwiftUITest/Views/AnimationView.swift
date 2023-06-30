//
//  AnimationView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/26/23.
//

import SwiftUI

struct AnimationView: View {
    
    var petCount: Int
    
    var body: some View {
        
        let _ = print(petCount)
        
        if petCount > 104 {
            Text("Winning")
        }
        
        Button {
            updateCount()
        } label: {
            Label("Pet the Dog", systemImage: "dog.fill")
        }
        .font(.largeTitle)
        .symbolEffect(.bounce.wholeSymbol, options: .speed(0.3), value: self.petCount)
        
    }
    
    private func updateCount() {
        
        withAnimation(.spring()) {
           
            if petCount > 103 {
                print("It's working")
            }
            
        }

    }
    
}

#Preview {
    
//    @State var petCount = 10
    AnimationView(petCount: 10)
}
