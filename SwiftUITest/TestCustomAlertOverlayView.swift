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
    @State private var isLoading: Bool = true
    
    var body: some View {
            
        ZStack {
            
            AppColor.charcoal
                .ignoresSafeArea()
            
            VStack {
                
                Rectangle()
                    .fill(Color.red)
                    .frame(height: 100)
                
                Text("Woah this is cool")
                
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 150, height: 30)
                
                Text("Woah this is cool")
                
                HStack {
                    
                    Rectangle()
                        .fill(Color.red)
                        .frame(height: 30)
                    Rectangle()
                        .fill(Color.red)
                        .frame(height: 30)
                    Rectangle()
                        .fill(Color.red)
                        .frame(height: 30)
                    
                }
                
            }
            .redactShimmer(condition: self.isLoading)
            .padding(.horizontal, 32)
            
        }
        .onTapGesture {
            self.isPresented = true
        }
        .alertView(
            isPresented: self.$isPresented,
            customView: {
                
                AppAlertView(isPresented: self.$isPresented)
                
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
                    
                    if self.isPresented {
                        
                        Color.black
                            .opacity(0.2)
                            .ignoresSafeArea()
                        
                        
                        self.customView
                        
                    }
                    
                }
                .animation(.easeOut(duration: 0.3), value: self.isPresented)
                
            }
        
    }
    
}

extension View {
    
    func alertView<Content: View>(isPresented: Binding<Bool>,
                                  @ViewBuilder customView: @escaping () -> Content) -> some View {
        
        self.modifier(AlertViewModifier(isPresented: isPresented, customView: customView))
        
    }
    
}

struct AppAlert {
    
    typealias ButtonAction = () -> ()
    
    let title: String
    let message: String?

    let primaryButtonTitle: String
    let primaryButtonAction: ButtonAction?
    
    let secondaryButtonTitle: String?
    let secondaryButtonAction: ButtonAction?
    
    init(title: String,
         message: String? = nil,
         primaryButtonTitle: String,
         primaryButtonAction: @escaping ButtonAction,
         secondaryButtonTitle: String? = nil,
         secondaryButtonAction: ButtonAction? = nil) {
        
        self.title = title
        self.message = message
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryButtonAction = primaryButtonAction
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonAction = secondaryButtonAction
        
    }
    
}

struct AppAlertView: View {
    
    @Binding var isPresented: Bool
    
    var tintColor: Color = .indigo.opacity(0.4) // AppColor.brandPink
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            Group {
                
                Text("Oh No! 🙃")
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text("Please check that your are logged in and try again")
                    .font(.headline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
            }
            .padding(.horizontal, 24)

            buttonStackView()
            
        }
        .padding(.top, 24)
        .background(AppColor.charcoal)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 48)
        .shadow(color: self.tintColor, radius: 23)
        
    }
    
    @ViewBuilder
    func button(title: String) -> some View {
        
        Text(title)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(self.tintColor)
            .foregroundStyle(.white)
            .font(.headline)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: self.tintColor, radius: 11)
//            .overlay {
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(self.tintColor, lineWidth: 2)
//                    .shadow(color: self.tintColor, radius: 11)
//            }
        
    }
    
    @ViewBuilder
    func buttonStackView() -> some View {
        
        HStack(spacing: 16) {
            
            Button(action: {
                self.isPresented = false
            },
                   label: {
                self.button(title: "No")
            })
            
            Button(action: {
                self.isPresented = false
            },
                   label: {
                self.button(title: "Yes")
            })
            
        }
        .padding(.top, 8)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        
    }
    
}
