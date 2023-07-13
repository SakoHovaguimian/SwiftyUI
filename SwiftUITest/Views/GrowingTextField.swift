//
//  GrowingTextField.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/10/23.
//

import SwiftUI

struct GrowingTextField: View {
    
    @State private var bio = "1111111111111111111111111111111112"
    private var isSecure = false

    var body: some View {
        
        VStack {
            
            if isSecure {
                
                SecureField("password", text: self.$bio)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(5)
                    .frame(width: 300)
                
            }
            else {
                
                TextField("Describe yourself", text: self.$bio, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(5)
                    .frame(width: 300)
                
            }
            
//            Text(self.bio)
            
        }
        .padding()
        
    }
    
}

#Preview {
    GrowingTextField()
}
