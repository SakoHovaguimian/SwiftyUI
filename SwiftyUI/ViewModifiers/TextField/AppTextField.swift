//
//  AppTextField.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/28/24.
//

import SwiftUI

struct StyledTextField: TextFieldStyle {
    
    var text: String
    var hint: String?
    var icon: Image?
    var isFocused: Bool
    var borderColor: Color = ThemeManager.shared.accentColor()
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        
        ZStack(alignment: .leading) {
            
            HStack {
                
                if let icon {
                    
                    icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                        .foregroundStyle(self.isFocused ? borderColor : .blackedGray)
                    
                }
                
                configuration
                
            }
            .frame(height: 50)
            .padding(.horizontal, self.icon == nil ? .medium : .small)
            .background(ThemeManager.shared.background(.secondary))
            .foregroundStyle(.black)
            .appFont(with: .title(.t5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(self.isFocused ? self.borderColor : .blackedGray, lineWidth: 2)
            }
            .shadow(radius: 11)
            .tint(self.borderColor)
            
            if let hint {
                
                let shouldShowContainer = ((!self.text.isEmpty && self.isFocused))
                animatingContainerView(hint: hint, shouldShow: shouldShowContainer)
                
            }
            
        }
                
    }
    
    
    private func animatingContainerView(hint: String,
                                        shouldShow: Bool) -> some View {
        
        Text(self.hint ?? "")
            .font(.caption2)
            .foregroundStyle(.black)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background {
                Capsule()
                    .fill(.white)
            }
            .offset(
                x: 16,
                y: shouldShow ? -24 : 0)
            .opacity(shouldShow ? 1 : 0)
            .appShadow()
            .animation(.bouncy, value: self.text)
            .animation(.bouncy, value: self.isFocused)
        
    }
    
}

extension View {
    
    func appTextFieldStyle(text: String,
                           hint: String? = nil,
                           icon: Image? = nil,
                           isFocused: Bool,
                           borderColor: Color = ThemeManager.shared.accentColor()) -> some View {
        
        self
            .textFieldStyle(StyledTextField(
                text: text,
                hint: hint,
                icon: icon,
                isFocused: isFocused,
                borderColor: borderColor
            ))
        
    }
    
}
