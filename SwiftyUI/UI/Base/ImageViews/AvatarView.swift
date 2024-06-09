//
//  AvatarView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/4/23.
//

import SwiftUI

struct AvatarView: View {
    
    var foregroundColor: Color
    var backgroundColor: Color
    
    var size: CGFloat

    var systemImage: String? = nil
    var image: URL? = nil
    
    var imageSize: CGFloat {
        return self.size / 2
    }
    
    var name: String? = nil
    
    init(name: String,
         systemImage: String? = nil,
         imageURL: URL? = nil,
         foregroundColor: Color = ThemeManager.shared.accentColor(),
         backgroundColor: Color = .black,
         size: CGFloat = 48) {
        
        self.name = name
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        
        self.systemImage = systemImage
        self.image = imageURL
        self.size = size
        
    }
    
    private func formattedName() -> String {
        
        guard let name = self.name,
              !name.isEmpty else { return "" }
        
        return name.initials
        
    }
    
    var body: some View {
        
        GeometryReader { proxy in
            
            ZStack {
                
                Circle()
                    .fill(self.backgroundColor)
                    .frame(width: self.size, height: self.size)
                    .frame(maxWidth: self.size, maxHeight: self.size)
                
                if let systemImage {
                    
                    Image(systemName: systemImage)
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(width: self.imageSize, height: self.imageSize)
                        .foregroundColor(self.foregroundColor)
                    
                }
                else if let image {
                    
                    AppImageView(
                        remoteURL: image,
                        image: nil
                    )
                    .aspectRatio(1.0, contentMode: .fill)
                    .frame(width: self.size, height: self.size)
                    .clipShape(Circle())
                    
                }
                else if let _ = self.name {
                    
                    Text(formattedName())
                        .font(Font(UIFont.systemFont(ofSize:(0.40 * proxy.size.width), weight: .semibold)))
                        .fontDesign(.monospaced)
                        .foregroundStyle(self.foregroundColor)
                    
                }
                
            }
            .frame(
                width: self.size,
                height: self.size
            )
            .frame(maxWidth: self.size, maxHeight: self.size)
            
        }
        .frame(
            width: self.size,
            height: self.size
        )
        .frame(
            maxWidth: self.size,
            maxHeight: self.size
        )
        
    }
    
}

