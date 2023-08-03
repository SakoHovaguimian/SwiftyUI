//
//  Misc.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 8/3/23.
//

import SwiftUI

struct AppLabelStyle: LabelStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        Label(configuration)
            .appFont(with: .heading(.h5))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .foregroundStyle(Color.white)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .asButton {
                print("Tapped")
            }
    }
    
}

struct CircularIconView: View {
    
    var foregroundColor: Color
    var backgroundColor: Color
    
    var size: CGFloat

    var systemImage: String? = nil
    var image: String? = nil
    
    var imageSize: CGFloat {
        return self.size / 2
    }
    
    var body: some View {

        return ZStack {
            
            Circle()
                .fill(self.backgroundColor)
                .frame(width: 48, height: 48)
            
            if let systemImage {
                
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
                    .foregroundColor(.black)
                
            }
            else if let image {
                
                Image(image)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
                
            }
            
        }
        
    }
    
}

struct AvatarView: View {
    
    var foregroundColor: Color
    var backgroundColor: Color
    
    var size: CGFloat

    var systemImage: String? = nil
    var image: String? = nil
    
    var imageSize: CGFloat {
        return self.size / 2
    }
    
    var name: String? = nil
    
    init(name: String,
         size: CGFloat = 48) {
        
        self.name = name
        self.foregroundColor = .black
        self.backgroundColor = .white
        self.size = size
        
    }
    
    private func formattedName() -> String {
        
        guard let name = self.name,
              !name.isEmpty else { return "" }
        
//        var formattedName: String = ""
        
//        let nameFormatter = PersonNameComponentsFormatter()
//        let nameComponents = nameFormatter.personNameComponents(from: name)
//        let firstName = nameComponents?.givenName
//        let lastName = nameComponents?.familyName
//
//        if let firstName,
//           let lastName {
//            formattedName = "\(firstName.first!)\(lastName.first!)"
//        }
//        else if let firstName {
//            formattedName = String(firstName.first!)
//        }
//        else if let lastName {
//            formattedName = String(lastName.first!)
//        }
//
//        return formattedName
        
        return name.initials
        
    }
    
    var body: some View {

        return ZStack {
            
            Circle()
                .fill(self.backgroundColor)
                .frame(width: self.size, height: self.size)
        
            if let systemImage {
                
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: self.imageSize, height: self.imageSize)
                    .foregroundColor(.black)
                
            }
            else if let image {
                
                Image(image)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: self.imageSize, height: self.imageSize)
                
            }
            else if let _ = self.name {
                
                Text(formattedName())
                    .fontWeight(.heavy)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.black)
                
            }
            
        }
        
    }
    
}
