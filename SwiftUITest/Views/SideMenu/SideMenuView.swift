//
//  SideMenuView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/20/23.
//

import SwiftUI

struct SideMenuView: View {
    
    @Binding var isShowing: Bool
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(
                colors: [.purple, .blue],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                
                SideMenuHeaderView(isShowing: self.$isShowing)
                    .foregroundColor(.white)
                    .frame(height: 240)
                
                VStack(spacing: 24) {
                    
                    ForEach(MenuOption.allCases, id: \.self) { option in
                    
                        NavigationLink {
                            
                            Text(option.title)
                            
                        } label: {
                            
                            SideMenuOptionView(menuOption: option)
                                .foregroundColor(.white)
                            
                        }
                        
                    }
                    
                }
                
                Spacer()
                
            }
            
        }
        .toolbar(.hidden, for: .automatic)
        
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(isShowing: .constant(false))
    }
}
