//
//  TransitionTestView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/22/23.
//

import SwiftUI

struct TransitionTestView: View {
    
    @State private var showDetails = false
    
    @State var delay1 = 0.3
    @State var delay2 = 0.5

    var body: some View {
        
        VStack(spacing: 0) {
            
            Button(action:{
                withAnimation {
                    self.showDetails.toggle()
                }
            }) {
                Text("Animate")
                    .font(.largeTitle)
                
            }
            .padding(.bottom, 32)
            
            if self.showDetails {
                
                
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(height: 100)
                    .transition(.move(edge: .leading))
                //                .transaction {
                //                    $0.animation = Animation.spring().delay(delay1)
                //                }
                    .onAppear { self.delay1 = 0.5 }
                    .onDisappear { self.delay1 = 0.3 }
                
                Rectangle()
                    .foregroundColor(.yellow)
                    .frame(height: 100)
                    .transition(.move(edge: .trailing))
                //                .transaction {
                //                    $0.animation = Animation.spring().delay(delay2)
                //                }
                    .onAppear { self.delay2 = 0.3 }
                    .onDisappear { self.delay2 = 0.5 }
                
            }
            
        }
        
    }
    
}

#Preview {
    TransitionTestView()
}
