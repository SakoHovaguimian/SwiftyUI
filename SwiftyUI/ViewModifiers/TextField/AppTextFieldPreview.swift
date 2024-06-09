//
//  AppTextFieldPreview.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/28/24.
//

import SwiftUI

internal struct AppTextFieldPreviews: View {
    
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            TextField(
                "Email",
                text: self.$text,
                prompt: Text("Email").foregroundStyle(.blackedGray)
            )
            .focused(self.$isFocused, equals: true)
            .appTextFieldStyle(
                text: self.text,
                hint: "Email",
                icon: nil,
                isFocused: self.isFocused
            )
            .appOnTapGesture {
                self.isFocused = true
            }
            
            TextField(
                "Password",
                text: self.$text,
                prompt: Text("Password").foregroundStyle(.blackedGray)
            )
            .focused(self.$isFocused, equals: true)
            .appTextFieldStyle(
                text: self.text,
                hint: nil,
                icon: Image(systemName: "lock.fill"),
                isFocused: self.isFocused
            )
            .appOnTapGesture {
                self.isFocused = true
            }
            
            TextField(
                "Full Name",
                text: self.$text,
                prompt: Text("Full Name").foregroundStyle(.blackedGray)
            )
            .focused(self.$isFocused, equals: true)
            .appTextFieldStyle(
                text: self.text,
                hint: "Full Name",
                icon: Image(systemName: "person.fill"),
                isFocused: self.isFocused
            )
            .appOnTapGesture {
                self.isFocused = true
            }
            
        }
        
        .padding(24)
        
    }
    
}

#Preview {
    AppTextFieldPreviews()
}
