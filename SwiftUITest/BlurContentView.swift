//
//  BlurContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/28/23.
//

import SwiftUI

struct BlurContentView: View {
    var body: some View {
        
        ZStack {
            
            Image("sunset")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 4)
            
            // This leaves random lifted padding from bottom / edges
            // add negative padding to resolve this padding(.bottom, -4)
            
        }
        
    }
}

struct BlurRepresentableView: View {
    
    let dismissAction: (() -> ())?
    let successAction: (() -> ())?

    let dismissOnBackroundTouchAllowed: Bool = false
    
    @State private var shouldShowOverlay: Bool = true
    
    var body: some View {
        
        ZStack {
            
            Image("pond")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    
                    withAnimation(.spring) {
                        self.shouldShowOverlay.toggle()
                    }
                    
                }
            
            Color.black
                .opacity(self.shouldShowOverlay ? 0.3 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(!self.dismissOnBackroundTouchAllowed)
            
            VStack {
                
                Image(systemName: "checkmark.circle.fill")
                    .frame(width: 32, height: 32)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.green)
                
                Text("New Game Mode")
                    .font(.title)
                    .fontWeight(.heavy)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 4)
                
                Text("How would you like to proceed? You can go back and change this decision at any time!")
                    .font(.title2)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                
                HStack {
                    
                    Spacer()
                    
                    Button(action: {
                        
                        dismissAction?()
                        self.shouldShowOverlay = false
                        
                    }, label: {
                        Text("No")
                            .frame(maxWidth: .infinity, minHeight: 32)
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(Color.red)
                    .foregroundStyle(.white)
                    .font(.headline)
                    .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {
                        
                        successAction?()
                        self.shouldShowOverlay.toggle()
                        
                    }, label: {
                        Text("Yes")
                            .frame(maxWidth: .infinity, minHeight: 32)
                    })
                    .buttonStyle(.borderedProminent)
                    .font(.headline)
                    .fontWeight(.semibold)
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 24)
                
            }
            .padding(.vertical, 32)
            .frame(width: UIScreen.main.bounds.width - 64)
            .background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: 16.0)
            )
            .opacity(self.shouldShowOverlay ? 1 : 0)
//            .multicolorGlow()
            
        }
        
    }
    
}

#Preview {
    BlurRepresentableView(
        dismissAction: {
            print("DISMISS ACTION")
        },
        successAction: {
            print("SUCCESS ACTION")
        })
    
}

extension View {
    func multicolorGlow() -> some View {
        ZStack {
            ForEach(0..<2) { i in
                Rectangle()
                    .fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                    .frame(width: 400, height: 300)
                    .mask(self.blur(radius: 20))
                    .overlay(self.blur(radius: 5 - CGFloat(i * 5)))
            }
        }
    }
}
