//
//  SideMenuOptionView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/20/23.
//

import SwiftUI

struct SideMenuOptionView: View {
    
    let menuOption: MenuOption
    
    var body: some View {
        
        HStack(spacing: 16) {
            
            Image(systemName: self.menuOption.iconName)
                .frame(
                    width: 24,
                    height: 24
                )
            
            Text(self.menuOption.title)
            
            Spacer()
            
        }
        .padding(.horizontal)
        
    }
}

struct SideMenuOptionView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuOptionView(menuOption: .profile)
    }
}
