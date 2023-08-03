//
//  CustomWebView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/25/23.
//

import SwiftUI

struct CustomWebView: View {
    
    @State private var isPresentWebView = false
    
    var body: some View {
        
        Button("Open WebView") {
            self.isPresentWebView = true
        }
        .fullScreenCover(isPresented: self.$isPresentWebView) { // You can use fullScreenCover or sheet aswell
            NavigationStack {
                // 3
                
                HStack {
                    
                    Image(.pond)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(.circle)
                    
                    Text("@SakoHovaguimian")
                        .appFont(with: .heading(.h5))
                    
                    Spacer()
                    
                    Button(action: { self.isPresentWebView.toggle() }, label: {
                        
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.black)
                        
                    })
                    
                }
                .padding([.vertical], 8)
                .padding(.horizontal, 16)
                
                Divider()
                    .padding([.bottom], 4)
                
                WebView(url: URL(string: "https://google.com")!)

                    .ignoresSafeArea()
//                    .navigationTitle("SwiftyUI")
//                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
}

#Preview {
    CustomWebView()
}
