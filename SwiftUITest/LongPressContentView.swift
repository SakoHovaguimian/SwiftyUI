//
//  LongPressContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/29/23.
//

import SwiftUI

struct LongPressContentView: View {
    
    @State private var tapCount = 0

    var body: some View {
        
        Button("Tap Count: \(self.tapCount)") {
            self.tapCount += 1
        }
        .buttonRepeatBehavior(.enabled)
        .keyboardShortcut(.return, modifiers: .shift)
        
    }
    
}

#Preview {
    LongPressContentView()
}

struct OnKeyPressContentView: View {
    
    @FocusState private var focused: Bool
    @State private var key = "KEY PRESS"
    @State private var name = "Sako Hovaguimian"

    var body: some View {
        
        ZStack {
            
            Color.white
                .ignoresSafeArea()
//            
//            TextField(text: self.$name) {
//                Text(self.name)
//                    .padding(32)
//            }
//            .background(Color.red)
//            .foregroundStyle(.black)
//            .padding(24)
            
//            VStack {
                
//                Spacer()
                
                Text(self.key)
                    .focusable()
                    .focused(self.$focused)
                    .onKeyPress { press in
                        print(press)
                        self.key += press.characters
                        return .handled
                    }
                    .onAppear {
                        self.focused = true
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundStyle(.black)
                    .padding(24)
                
//            }
            
        }
        
    }
    
}

#Preview {
    OnKeyPressContentView()
}
