//
//  TestCustomAlertOverlayView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 8/1/23.
//

import SwiftUI

struct AlertViewModifier: ViewModifier {
    
    @Binding private var isPresented: Bool
    private let alertStyle: AlertStyle
    private var shouldDismissOnTouch: Bool
    
    init(isPresented: Binding<Bool>,
         shouldDismissOnTouch: Bool = false,
         alertStyle: AlertStyle) {
        
        self._isPresented = isPresented
        self.shouldDismissOnTouch = shouldDismissOnTouch
        self.alertStyle = alertStyle
        
    }
    
    func body(content: Content) -> some View {
        
        content
            .overlay {
                
                ZStack {
                    
                    if self.isPresented {
                        
                        Color.black
                            .opacity(0.6)
                            .ignoresSafeArea()
                            .onTapGesture {
                                
                                if self.shouldDismissOnTouch {
                                    self.isPresented = false
                                }
                                
                            }
                        
                        switch alertStyle {
                        case .normal(let appAlert):
                            
                            AppAlertView(
                                alert: appAlert,
                                isPresented: self.$isPresented
                            )
                            .centerVertically()
                            
                        case .textField(let appAlert, let action):
                            
                            AppTextFieldAlertView(
                                isPresented: self.$isPresented,
                                alert: appAlert
                            ) { email in
                                action(email)
                            }
                            .centerVertically()
                            
                        case .simpleError(let message, let action):
                            
                            AppAlertView(
                                alert: .init(
                                    title: "Oh No!",
                                    message: message,
                                    primaryButtonTitle: "Okay",
                                    primaryButtonAction: action,
                                    primaryButtonBackgroundColor: .red
                                ),
                                isPresented: self.$isPresented
                            )
                            .centerVertically()
                            
                        case .simpleSuccess(let message, let action):
                            
                            AppAlertView(
                                alert: .init(
                                    title: "Success!",
                                    message: message,
                                    primaryButtonTitle: "Okay",
                                    primaryButtonAction: action,
                                    primaryButtonBackgroundColor: ThemeManager.shared.accentColor(),
                                    primaryButtonTextColor: .black
                                ),
                                isPresented: self.$isPresented
                            )
                            .centerVertically()
                            
                        case .success(let message, let actionColor, let actionTitleColor, let action):
                            
                            AppAlertView(
                                alert: .init(
                                    title: "Success!",
                                    message: message,
                                    primaryButtonTitle: "Okay",
                                    primaryButtonAction: action,
                                    primaryButtonBackgroundColor: actionColor,
                                    primaryButtonTextColor: actionTitleColor
                                ),
                                isPresented: self.$isPresented
                            )
                            .centerVertically()
                            
                        case .forgotPassword(let action):
                            
                            AppTextFieldAlertView(
                                isPresented: self.$isPresented,
                                alert: .init(
                                    title: "Forgot Your Password?",
                                    message: "Enter the email below that you would like us to send the recovery email to.",
                                    primaryButtonTitle: "Okay",
                                    primaryButtonAction: {}
                                ),
                                action: action
                            )
                            .centerVertically()
                            
                        }
                        
                    }
                    
                }
                .frame(height: UIScreen.main.bounds.height)
                .animation(.easeOut(duration: 0.3), value: self.isPresented)
                
            }
//            .ignoresSafeArea(.keyboard, edges: .bottom)
        
    }
    
}

extension View {
    
    func alertView(isPresented: Binding<Bool>,
                   shouldDismissOnTouch: Bool = false,
                   alertStyle: AlertStyle) -> some View {
        
        self.modifier(AlertViewModifier(
            isPresented: isPresented,
            shouldDismissOnTouch: shouldDismissOnTouch,
            alertStyle: alertStyle
        ))
        
    }
    
}

enum AlertStyle {
    
    case normal(AppAlert)
    case textField(AppAlert, action: (String) -> ())
    
    case success(message: String, buttonColor: Color, buttonTitleColor: Color, action: () -> ())
    
    case simpleError(message: String, action: () -> ())
    case simpleSuccess(message: String, action: () -> ())
    case forgotPassword(action: (String) -> ())
    
}

struct AppAlert {
    
    typealias ButtonAction = () -> ()
    
    let title: String
    let message: String?
    
    let primaryButtonTitle: String
    let primaryButtonAction: ButtonAction
    let primaryButtonBackgroundColor: Color
    let primaryButtonTextColor: Color
    
    let secondaryButtonTitle: String?
    let secondaryButtonAction: ButtonAction?
    let secondaryButtonBackgroundColor: Color?
    let secondaryButtonTextColor: Color?
    
    init(title: String,
         message: String? = nil,
         primaryButtonTitle: String,
         primaryButtonAction: @escaping ButtonAction,
         primaryButtonBackgroundColor: Color = .blue,
         primaryButtonTextColor: Color = .white,
         secondaryButtonTitle: String? = nil,
         secondaryButtonAction: ButtonAction? = nil,
         secondaryButtonBackgroundColor: Color? = nil,
         secondaryButtonTextColor: Color? = nil) {
        
        self.title = title
        self.message = message
        
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryButtonAction = primaryButtonAction
        self.primaryButtonBackgroundColor = primaryButtonBackgroundColor
        self.primaryButtonTextColor = primaryButtonTextColor
        
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonAction = secondaryButtonAction
        self.secondaryButtonBackgroundColor = secondaryButtonBackgroundColor
        self.secondaryButtonTextColor = secondaryButtonTextColor
        
    }
    
}
