//
//  AppButton.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 8/3/23.
//

import SwiftUI

struct AppButtonStyle: ButtonStyle {
    
    let titleColor: Color
    let style: AppButton.Style
    let font: AppFont
    let backgroundColor: Color
    let height: CGFloat = 48
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: self.height)
            .background(self.style == .fill ? self.backgroundColor : .white.opacity(0.001))
            .foregroundStyle(self.titleColor)
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
            .if(self.style == .outline) { view in
                
                view.overlay {
                    
                    RoundedRectangle(cornerRadius: self.cornerRadius)
                        .stroke(self.backgroundColor, lineWidth: 3)
                    
                }
                
            }
            .appShadow()
            .appFont(with: self.font)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
        
    }
    
}

struct AppButton: View {
    
    enum Style {
        
        case fill
        case outline
        
    }
    
    var title: String
    var titleColor: Color = Color(hex: "#1C2227")
    var style: Style
    var font: AppFont = .heading(.h5)
    var backgroundColor: Color = AppColor.brandGreen
    var systemImage: String? = nil
    var image: Image? = nil
    var height: CGFloat = 48
    var cornerRadius: CGFloat = 12
    
    var action: (() -> ())
    
    init(title: String,
         titleColor: Color = AppColor.charcoal,
         style: Style = .fill,
         font: AppFont = .heading(.h5),
         backgroundColor: Color = AppColor.brandGreen,
         systemImage: String? = nil,
         image: Image? = nil,
         height: CGFloat = 48,
         cornerRadius: CGFloat = 12,
         action: @escaping () -> Void) {
        
        self.title = title
        self.titleColor = titleColor
        self.style = style
        self.font = font
        self.backgroundColor = backgroundColor
        self.systemImage = systemImage
        self.image = image
        self.height = height
        self.cornerRadius = cornerRadius
        self.action = action
        
    }
    
    var body: some View {
        
        Button(
            action: self.action,
            label: {
                
                HStack {
                    
                    if let systemImage {
                        Image(systemName: systemImage)
                    } else
                    if let image {
                        image
                            .resizable()
                            .frame(
                                width: 16,
                                height: 16
                            )
                    }
                    
                    Text(self.title)
                    
                }
                
        })
        .buttonStyle(AppButtonStyle(
            titleColor: self.titleColor,
            style: self.style,
            font: self.font,
            backgroundColor: self.backgroundColor,
            cornerRadius: self.cornerRadius
        ))
        
    }
    
}
