//
//  Extension+View.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/19/23.
//

import SwiftUI

extension View {
    
    func hideKeyboard() -> some View {
        
        self
            .onTapGesture {
                
                UIApplication
                    .shared
                    .sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                
            }
        
    }
    
}
