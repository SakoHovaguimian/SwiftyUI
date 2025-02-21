//
//  CustomButton.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/20/25.
//

import SwiftUI

struct CommonButton: View {
    
    var body: some View {
        
        Button {
            
            print("Did Get Tapped")
            
        } label: {
            
            HStack {
                
                Image(systemName: "plus")
                
                Text("My Button")
                    .appFont(with: .title(.t5))
                    .lineLimit(1)
                
            }
            
        }
        .buttonStyle(.commonButtonStyle(horizontalPadding: .large))
        .fixedSize(horizontal: true, vertical: false)

        
    }
    
}

#Preview {
    
    VStack {
        
        CommonButton()
        
    }
    
}

struct CommonButtonStyle: ButtonStyle {
    
    var background: AppBackgroundStyle
    var cornerRadius: CornerRadius
    var verticalPadding: Spacing = .small
    var horizontalPadding: Spacing = .xLarge

    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .padding(.horizontal, self.horizontalPadding.value)
            .padding(.vertical, self.verticalPadding.value)
            .frame(maxWidth: .infinity)
            .background(self.background.backgroundStyle())
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius.value))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .lineLimit(1)
        
        
    }
    
}

extension ButtonStyle where Self == CommonButtonStyle {
    
    static func commonButtonStyle(background: AppBackgroundStyle = .color(.indigo),
                                  cornerRadius: CornerRadius = .small,
                                  verticalPadding: Spacing = .small,
                                  horizontalPadding: Spacing = .medium) -> CommonButtonStyle {
        
        return CommonButtonStyle(
            background: background,
            cornerRadius: cornerRadius,
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding
        )
        
    }
    
}
