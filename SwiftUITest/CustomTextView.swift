//
//  CustomTextView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/24/23.
//

import SwiftUI

/// Dismisses on done
/// Line limits
/// Proper padding
struct CustomTextView: View {
    
    @State var text: String = "TEST"
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            TextField(
                "Description",
                text: self.$text,
                axis: .vertical // horizontal?
            )
            .submitLabel(.go)
            .onSubmit {
                print("Dismissing....")
            }
            .onChange(of: self.text, initial: false, { oldValue, newValue in
                
                if newValue.last == "\n" {
                    
                    self.text.removeAll { character in
                        character == "\n"
                    }
                    self.dismissKeyboard()
                    
                }
                
            })
            .lineLimit (5...10)
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(RoundedRectangle(cornerRadius: 11).fill(Color.gray.opacity(0.3)))
            .padding(.horizontal, 32)
            
            Spacer()
        }
        
    }
}

#Preview {
    CustomTextView(text: "")
}
