//
//  CustomAlertView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/19/23.
//

import SwiftUI

struct CustomAlertView: View {
    
    // Params:
    // Emoji
    // Title
    // Message
    // Image
    // isSuccess ? green : red : neutral // make this an enum
    
    var isSuccess: Bool = false
    
    var body: some View {
        
        let color = (isSuccess ? Color.green : Color.red).opacity(1)
        let emoji = isSuccess ? "✅" : "🚨"
        
        GeometryReader { proxy in
            
            ZStack {
                
                AppColor.charcoal.opacity(1)
                    .ignoresSafeArea()
                
                VStack {
                    
                    Spacer()
                    
                    HStack {
                        
                        Spacer()
                        
                        alertViewContentView()
                            .frame(width: proxy.size.width - 128, height: proxy.size.height / 4.2)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 24)
                            .foregroundColor(.black)
                            .background(.ultraThickMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 11))
                            .shadow(radius: 23)
                            .overlay(alignment: .top) {
                                
                                circleOverlayView(
                                    color: color,
                                    emoji: emoji
                                )
                                
                            }
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                }
                .offset(y: -80)
            }
            
        }
        
    }
    
    func alertViewContentView() -> some View {
        
        VStack(spacing: 8) {
            
            Text("Success")
                .font(.title)
                .fontDesign(.rounded)
                .padding(.top, 32)
            
            Text("Oh no!\nSomething went wrong 😔")
                .font(.body)
                .fontDesign(.rounded)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            GeometryReader { alertButtonProxy in
                
                alertOptions(geometryProxy: alertButtonProxy)
                    .padding(.top, 18)
                
            }
            .padding(.bottom, 8)
        }
        
    }
    
    func alertOptions(geometryProxy: GeometryProxy) -> some View {
        
        HStack {
            
            Spacer()
            
            Button("Complain") {
                
            }
            .frame(width: (geometryProxy.size.width / 2) - 16, height: 50)
            .background(Color.gray.opacity(0.9).gradient)
            .foregroundColor(Color.black)
            .fontWeight(.semibold)
            .cornerRadius(12)
            
            Button("Okay") {
                
            }
            .frame(width: (geometryProxy.size.width / 2) - 16, height: 50)
            .background(Color.gray.opacity(0.9).gradient)
            .foregroundColor(Color.black)
            .fontWeight(.semibold)
            .cornerRadius(12)
            
            Spacer()
            
        }
        
    }
    
    func circleOverlayView(color: Color, emoji: String) -> some View {
        
        ZStack {
            
            Circle().fill(color)
                .frame(width: 64, height: 64)
                .offset(y: -32)
                .shadow(radius: 11, y: 2)
            
            Circle()
                .stroke(color, lineWidth: 4)
                .frame(width: 64, height: 64)
                .offset(y: -32)
                .shadow(radius: 11, y: 2)
            
//            Image("sunset")
//                .resizable()
//                .cornerRadius(99)
//                .frame(width: 64, height: 64)
//                .offset(y: -32)
//                .shadow(radius: 11, y: 2)
            
            Text(emoji)
                .font(.title)
                .cornerRadius(99)
                .frame(width: 64, height: 64)
                .offset(y: -32)
                .shadow(color: Color.black.opacity(1), radius: 3)
            
        }
        
    }
}

struct CustomAlertView_Previews: PreviewProvider {
    static var previews: some View {
        CustomAlertView()
    }
}
