//
//  AppButton.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/3/23.
//

import SwiftUI

struct AppButtonStyle: ButtonStyle {
    
    let titleColor: Color
    let style: AppButton.Style
    let font: AppFont
    let backgroundColor: Color
    let height: CGFloat
    let cornerRadius: CGFloat
    let isEnabled: Bool
    let horizontalPadding: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
        
            .frame(maxWidth: .infinity)
            .frame(height: self.height)
        
            .background(self.style == .fill ? self.backgroundColor : .backgroundTappable)
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
            .disabled(!self.isEnabled)
        
            .if(!self.isEnabled) { view in
                
                view
                    .opacity(0.6)
                
            }
        
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
            .animation(.easeInOut, value: self.isEnabled)
        
    }
    
}

struct AppButton: View {
    
    enum Style {
        
        case fill
        case outline
        
    }
    
    var title: String
    var titleColor: Color
    var style: Style
    var font: AppFont
    var backgroundColor: Color
    var systemImage: String?
    var image: Image?
    var height: CGFloat = 48
    var cornerRadius: CGFloat = 12
    var isEnabled: Bool
    var horizontalPadding: CGFloat = 0
    
    var action: (() -> ())
    
    init(title: String,
         titleColor: Color = .black,
         style: Style = .fill,
         font: AppFont = .title(.t5),
         backgroundColor: Color = ThemeManager.shared.accentColor(),
         systemImage: String? = nil,
         image: Image? = nil,
         height: CGFloat = 48,
         cornerRadius: CGFloat = 12,
         isEnabled: Bool = true,
         horizontalPadding: CGFloat = 0,
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
        self.isEnabled = isEnabled
        self.horizontalPadding = horizontalPadding
        self.action = action
        
    }
    
    var body: some View {
        
        Button(
            action: {
                
                self.action()
                Haptics.shared.vibrate(option: .selection)
                
            },
            label: {
                
                HStack {
                    
                    if let systemImage {
                        Image(systemName: systemImage)
                            .contentTransition(.interpolate)
                    }
                    else if let image {
                        
                        image
                            .renderingMode(.template)
                            .resizable()
                            .frame(
                                width: 20,
                                height: 20
                            )
                            .contentTransition(.interpolate)
                        
                    }
                    
                    if !self.title.isEmpty {
                        Text(self.title)
                            .contentTransition(.interpolate)
                    }
                    
                }
                .padding(.horizontal, self.horizontalPadding)
                
        })
        .buttonStyle(AppButtonStyle(
            titleColor: self.titleColor,
            style: self.style,
            font: self.font,
            backgroundColor: self.backgroundColor,
            height: self.height,
            cornerRadius: self.cornerRadius,
            isEnabled: self.isEnabled,
            horizontalPadding: self.horizontalPadding
        ))
        .disabled(!self.isEnabled)
        
    }
    
}

#Preview {
    
    // Filled
    
    VStack(spacing: 32) {
        
        AppButton(
            title: "Add",
            titleColor: .white,
            style: .fill,
            font: .title(.t5),
            backgroundColor: .pink,
            image: Image(uiImage: .add),
            height: 50,
            cornerRadius: .appSmall,
            isEnabled: true,
            horizontalPadding: 0,
            action: {
                print("Tapped The Button")
            })
        
        AppButton(
            title: "Next",
            titleColor: .pink,
            style: .outline,
            font: .title(.t5),
            backgroundColor: .pink,
            systemImage: "checkmark",
            image: nil,
            height: 50,
            cornerRadius: .appSmall,
            isEnabled: true,
            horizontalPadding: 0,
            action: {
                print("Tapped The Button")
            })
        
        CircularIconView(
            foregroundColor: .white,
            backgroundColor: .pink,
            size: 32,
            systemImage: "person.fill"
        )
        .asButton {
            print("Something")
        }
        
    }
    .padding(.horizontal, 32)
    
}
