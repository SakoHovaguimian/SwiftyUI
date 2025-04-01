//
//  ErrorHandler.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/23/23.
//

import SwiftUI

struct ErrorHandlerModifier: ViewModifier {
    
    @Binding var error: Error?
    var alertStyle: AlertStyle!
    
    private var shouldShowErrorView: Binding<Bool> {
        
        return .init {
            return self.error != nil
        } set: { newValue in
            
            if !newValue {
                self.error = nil
            }
            
        }
        
    }
    
    func body(content: Content) -> some View {
        
        content
            .alertView(
                isPresented: self.shouldShowErrorView,
                alertStyle: self.alertStyle
            )
        
    }
    
}

extension View {
    
    func errorHandler(error: Binding<Error?>,
                      alertStyle: AlertStyle) -> some View {
        
        self.modifier(ErrorHandlerModifier(
            error: error,
            alertStyle: alertStyle
        ))
        
    }
    
}
