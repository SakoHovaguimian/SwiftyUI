//
//  MaterialUITextField.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/24/23.
//

import SwiftUI

struct MaterialUITextField: View {
    
    @State var text: String
    @State var placeholder: String
    @State var isSecureEntry: Bool = false
    
    // Add Focus field to trigger offset and stuff instead of empty text
    // Add Callback for editing +
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            if self.isSecureEntry {
                
                SecureField(self.placeholder, text: self.$text)
                    .textfieldStyle()
                    .overlay(alignment: .trailing) {
                        
                        Image(systemName: "eye.fill")
                            .resizable()
                            .frame(width: 18, height: 14)
                            .onTapGesture {
                                self.isSecureEntry.toggle()
                            }
                            .padding(.trailing, 16)
                        
                    }
                
            }
            else {
                
//                let formatter: NumberFormatter = {
//                    let formatter = NumberFormatter()
//                    formatter.numberStyle = .currency
//                    return formatter
//                }()
//
                TextField(self.placeholder, text: self.$text)
//                TextField("Email", value: self.$text, formatter: formatter)
//                TextField("", value: $text, formatter: formatter) { _ in
//                    print("")
//                } onCommit: {
//                    print("")
//                }

                TextField(self.placeholder, text: self.$text)
                    .textfieldStyle()
                    .overlay(alignment: .trailing) {
                        Image(systemName: "eye.slash.fill")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .onTapGesture {
                                self.isSecureEntry.toggle()
                            }
                            .padding(.trailing, 16)
                    }
                
            }
            
            Text(self.placeholder)
                .font(.caption2)
                .foregroundStyle(.white)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background {
                    Capsule()
                        .fill(.black)
                }
                .offset(x: self.text.isEmpty ? 16 : 16, y: self.text.isEmpty ? 0 : -24)
                .opacity(self.text.isEmpty ? 0 : 1)
                .animation(.bouncy, value: self.text)
            
        }
        
    }
    
}

#Preview {
    MaterialUITextField(text: "", placeholder: "Email", isSecureEntry: false)
        .padding(24)
}

struct StyledTextField: ViewModifier {
    
    func body(content: Content) -> some View {
        
        content
            .frame(height: 50)
            .padding(.horizontal, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 11))
            .shadow(radius: 11)
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.gray)
            }
        
    }
    
}

extension View {
    
    func textfieldStyle() -> some View {
        modifier(StyledTextField())
    }
    
}
