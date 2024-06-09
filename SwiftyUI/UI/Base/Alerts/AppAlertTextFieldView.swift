//
//  AppAlertTextFieldView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/10/23.
//

import SwiftUI

struct AppTextFieldAlertView: View {
    
    enum FocusedField: Hashable {
        case email
    }
    
    @Binding var isPresented: Bool
    
    let alert: AppAlert
    
    @State var email: String = ""
    @FocusState private var focusedField: FocusedField?
    
    var tintColor: Color = ThemeManager.shared.accentColor()
    
    var isButtonEnabled: Bool {
        return self.email.count > 4
    }

    var action: ((String) -> ())
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            Group {
                
                Group {
                    
                    Text(self.alert.title)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .appFont(with: .title(.t10))
                    
                    if let message = self.alert.message {
                        
                        Text(message)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .appFont(with: .body(.b5))
                        
                    }
                    
                }
                
                TextField(
                    "Email",
                    text: self.$email,
                    prompt: Text("Email").foregroundStyle(.blackedGray)
                )
                .appTextFieldStyle(
                    text: self.email,
                    hint: "Email",
                    isFocused: self.focusedField == .email,
                    borderColor: self.tintColor
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .onSubmit({
                    self.action(self.email)
                })
                .focused(self.$focusedField, equals: .email)
                .padding(.top, Spacing.small.value)
                
                
            }
            .padding(.horizontal, 24)

            buttonStackView()
            
        }
        .padding(.top, 24)
        .background(ThemeManager.shared.background(.secondary))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 48)
        .shadow(color: ThemeManager.shared.background(.tertiary), radius: 23)
        
    }
    
    @ViewBuilder
    func button(title: String,
                color: Color) -> some View {
        
        Text(title)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(self.isButtonEnabled ? color : color.opacity(0.3))
            .foregroundStyle(self.alert.primaryButtonTextColor)
            .appFont(with: .title(.t5))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        
    }
    
    @ViewBuilder
    func buttonStackView() -> some View {
        
        HStack(spacing: 16) {
            
            Button(action: {
                
                self.isPresented = false
                self.action(self.email)
                
            },
                   label: {
                self.button(
                    title: self.alert.primaryButtonTitle,
                    color: self.tintColor
                )
                .shadow(color: self.tintColor, radius: 11)
            })
            .disabled(!self.isButtonEnabled)
            
        }
        .padding(.top, 8)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        
    }
    
}

#Preview {
    
    AppTextFieldAlertView(isPresented: .constant(true), alert: .init(
        title: "Some Title",
        message: "Some Message",
        primaryButtonTitle: "Some Action",
        primaryButtonAction: {}
    ), email: "123", action: { email in
        print(email)
    })
    
}

