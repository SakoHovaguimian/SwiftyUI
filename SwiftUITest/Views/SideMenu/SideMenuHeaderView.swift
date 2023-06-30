//
//  SideMenuHeaderView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/20/23.
//

import SwiftUI

struct SideMenuHeaderView: View {
    
    @Binding var isShowing: Bool
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            Button {
                
                withAnimation(.spring()) {
                    self.isShowing.toggle()
                }
                
            } label: {
                
                Image(systemName: "xmark")
                    .frame(width: 32, height: 32)
                    .foregroundColor(.white)
                    .padding()
                    .padding(.top, 16)
                
            }

            
            VStack(alignment: .leading, spacing: 8) {
                
                Image("sunset")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    .padding(.bottom, 16)
                
                Text("Sako Hovaguimian")
                    .font(.system(size: 24, weight: .semibold))
                
                Text("@sakohovaguimian")
                    .font(.system(size: 14))
                
                HStack(spacing: 12) {
                    
                    HStack(spacing: 4) {
                        Text("1254").bold()
                        Text("Following")
                    }
                    
                    HStack(spacing: 4) {
                        Text("1254").bold()
                        Text("Followers")
                    }
                             
                    Spacer()
                    
                }
                .padding(.top, 24)
                
                Spacer()
                
            }
            .padding()
        }
        
    }
    
}

struct SideMenuHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuHeaderView(isShowing: .constant(false))
    }
}
