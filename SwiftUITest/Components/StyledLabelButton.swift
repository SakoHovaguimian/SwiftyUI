//
//  StyledLabelButton.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/15/23.
//

import SwiftUI

// StyledLabel

struct StyledLabel: View {
    
    var title: String
    var systemImageName: String
    var color: Color
    var action: (() -> Void)
    
    var body: some View {
        
        Label(self.title, systemImage: self.systemImageName)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .foregroundColor(.white)
            .background(self.color)
            .clipShape(RoundedRectangle(cornerRadius: 11))
            .shadow(radius: 12)
            .onTapGesture {
                self.action()
            }
        
    }
    
}

struct StyledLabel_Previews: PreviewProvider {
    static var previews: some View {
        
        StyledLabel(
            title: "Favorites",
            systemImageName: "heart.fill",
            color: .red.opacity(1)) {
                print("Clicked the favorited button")
            }
            .padding(24)
        
    }
}

