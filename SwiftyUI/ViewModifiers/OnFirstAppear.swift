//
//  OnFirstAppear.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 8/2/23.
//

import SwiftUI

public extension View {
    
    func onFirstAppear(_ action: @escaping () -> ()) -> some View {
        modifier(FirstAppear(action: action))
    }
    
}

private struct FirstAppear: ViewModifier {
    
    let action: () -> ()
    
    // Use this to only fire your block one time
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        // And then, track it here
        content.onAppear {
            
            guard !hasAppeared else { return }
            
            self.hasAppeared = true
            self.action()
            
        }
        
    }
    
}
