//
//  TestCustomAlertOverlayView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 8/1/23.
//

import SwiftUI

// TODO: - Build Custom Alert System
// TODO: - One Button or Two Buttons
// TODO: - Title and optional Message

// TOOD: - BuildViewModifier for simple success Alert
// TODO: - BuildViewModifier for simple ErrorAlert
// TODO: - BuildViewModifier for custom Content Error Alert

struct TestCustomAlertOverlayView: View {
    
    @State private var isPresented: Bool = false
    
    var body: some View {
            
        ZStack {
            
            Color.indigo
                .ignoresSafeArea()
            
        }
        .onTapGesture {
            self.isPresented = true
        }
        .alertView(
            isPresented: self.$isPresented,
            customView: {
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .onTapGesture {
                        self.isPresented = false
                    }
                
            }
            
        )
        
    }
    
}

#Preview {
    TestCustomAlertOverlayView()
}

// Modifier

struct AlertViewModifier<CustomView: View>: ViewModifier {
    
    @Binding private var isPresented: Bool
    private let customView: CustomView
    
    init(isPresented: Binding<Bool>,
         @ViewBuilder customView: () -> CustomView) {
        
        self._isPresented = isPresented
        self.customView = customView()
        
    }
    
    func body(content: Content) -> some View {
        
        content
            .overlay {
                
                ZStack {
                    
                    Color.black
                        .opacity(self.isPresented ? 0.2 : 0)
                        .ignoresSafeArea()
                        
                
                    if self.isPresented{
                        self.customView
                    }
                    
                }
                .animation(.easeInOut, value: self.isPresented)
                
            }
        
    }
    
}

extension View {
    
    func alertView<Content: View>(isPresented: Binding<Bool>,
                                  @ViewBuilder customView: @escaping () -> Content) -> some View {
        
        self.modifier(AlertViewModifier(isPresented: isPresented, customView: customView))
        
    }
    
}
