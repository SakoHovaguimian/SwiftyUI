//
//  BaseAppAlertView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/10/23.
//

import SwiftUI

struct AppAlertView: View {
    
    let alert: AppAlert
    @Binding var isPresented: Bool
    
    var body: some View {
        
        VStack(spacing: 8) {
            
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
            .padding(.horizontal, 24)

            buttonStackView()
                .padding(.top, 24)
                .padding(.horizontal, 24)
            
        }
        .padding(.vertical, 24)
        .background(ThemeManager.shared.background(.secondary))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 48)
        .shadow(color: ThemeManager.shared.background(.tertiary), radius: 23)
        
    }
    
    @ViewBuilder
    func button(title: String,
                backgroundColor: Color,
                foregroundColor: Color) -> some View {
        
        Text(title)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .font(.headline)
            .fontWeight(.semibold)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        
    }
    
    @ViewBuilder
    func buttonStackView() -> some View {
        
        HStack(spacing: 16) {
            
            Button(action: {
                
                self.isPresented = false
                self.alert.primaryButtonAction()
                
            },
            label: {
                
                self.button(
                    title: self.alert.primaryButtonTitle,
                    backgroundColor: self.alert.primaryButtonBackgroundColor,
                    foregroundColor: self.alert.primaryButtonTextColor
                )
                
            })
            
            if let secondaryButtonTitle = alert.secondaryButtonTitle,
               let secondaryButtonAction = alert.secondaryButtonAction {
                
                Button(action: {
                    
                    self.isPresented = false
                    secondaryButtonAction()
                    
                },
                label: {
                    
                    self.button(
                        title: secondaryButtonTitle,
                        backgroundColor: self.alert.secondaryButtonBackgroundColor ?? self.alert.primaryButtonBackgroundColor,
                        foregroundColor: self.alert.secondaryButtonTextColor ?? self.alert.primaryButtonTextColor
                    )
                    
                })
                
            }
  
        }
        
    }
    
}
