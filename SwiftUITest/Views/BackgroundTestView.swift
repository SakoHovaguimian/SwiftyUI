//
//  BackgroundTestView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/22/23.
//

import SwiftUI

struct SignUpContentView: View {
    
    enum FocusedField {
        
        case name
        case email
        case password
        
    }
    
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    
    @FocusState private var focusedField: FocusedField?
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            Color.white.opacity(1)
                .ignoresSafeArea()
                .onTapGesture {
                    self.presentation.wrappedValue.dismiss()
                }
            
            // Adding this makes it so only background where there is no content is tappable
//
//            Image(systemName: "heart.fill")
//                .background (in: Circle().inset (by: -14))
//                .backgroundStyle(Color.yellow.gradient)
//                .foregroundStyle(.white)
//                .padding(20)
            
            VStack(alignment: .leading,
                   spacing: 16) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("Welcome")
                        .font(.largeTitle)
                        .bold()
                        .fontDesign(.rounded)
                        .foregroundStyle(.blue.gradient.opacity(1))
                    
                    Text("Create an account")
                        .font(.largeTitle)
                        .bold()
                        .fontDesign(.rounded)
                        .foregroundStyle(.linearGradient(
                            colors: [.teal, .blue.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .padding(.bottom, 32)
                    
                }
                
                VStack(spacing: 12) {
                    
                    CustomTextField(
                        placeholder: "name",
                        text: self.$name,
                        isFocused: (self.focusedField == .name)
                    )
                    .keyboardType(.alphabet)
                    .focused(self.$focusedField, equals: .name)
                    
                    CustomTextField(
                        placeholder: "me@email.com",
                        text: self.$email,
                        isFocused: (self.focusedField == .email)
                    )
                    .keyboardType(.emailAddress)
                    .focused(self.$focusedField, equals: .email)
                    
                    CustomTextField(
                        placeholder: "•••••••",
                        text: self.$password,
                        isFocused: (self.focusedField == .password)
                    )
                    .keyboardType(.default)
                    .focused(self.$focusedField, equals: .password)
                    
                }
                //                .frame(width: .infinity)
                .padding(.vertical, 48)
                .padding(.horizontal, 16)
                .background {
                    Color.white.opacity(1)
                }
                .clipShape(.rect(cornerRadius: 23))
                .shadow(radius: 11)
                .defaultFocus(self.$focusedField, .name)
                .onSubmit {
                    setNextFocusFieldIfNeededAndSubmit()
                }
                
                
            }
                   .padding(.horizontal, 24)
            
            VStack {
                
                Spacer()
                
                Button(action: {
                    submit()
                }, label: {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                })
                //                .frame(width: .infinity)
                .foregroundStyle(.white)
                .background(!isFormValid() ? Color.blue.opacity(0.3).gradient : Color.blue.gradient)
                .clipShape(.rect(cornerRadius: 11))
                .shadow(radius: 11)
                .padding(.horizontal, 32) // Do this in parent view instead
                .disabled(!isFormValid())
                
            }
            
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden()
        .navigationTitle("")
        .preferredColorScheme(.light)
        
    }
    
    private func isFormValid() -> Bool {
        
        return (
            !self.name.isEmpty &&
            !self.email.isEmpty &&
            !self.password.isEmpty
        )
        
    }
    
    private func setNextFocusFieldIfNeededAndSubmit() {
        
        guard let currentField = self.focusedField else { return }
        
        switch currentField {
        case .name:
            self.focusedField = .email
        case .email:
            self.focusedField = .password
        case .password:
            submit()
        }
        
    }
    
    private func submit() {
        print("TRYING TO SUBMIT")
    }
    
}

#Preview {
    SignUpContentView()
}

struct CustomTextField: View {
    
    @State var placeholder: String
    @Binding var text: String
    
    var isFocused: Bool
    
    var body: some View {
        
        let _ = print(self.isFocused)
        
        TextField(text: self.$text) {
            Text(verbatim: self.placeholder).foregroundColor(.gray.opacity(1))
        }
        .foregroundColor(.black)
        .fontWeight(.semibold)
        .font(.body)
        .fontDesign(.rounded)
        //        .frame(width: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background {
            Color.gray.opacity(0.1) // Color.black looks cool too
        }
        .clipShape(.rect(cornerRadius: 12))
        .tint(Color.gray.opacity(1)) // This changes cursor color
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(self.isFocused ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
    
}
