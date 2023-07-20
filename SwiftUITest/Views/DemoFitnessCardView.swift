//
//  DemoFitnessCardView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/18/23.
//

import SwiftUI

struct DemoFitnessCardView: View {
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
         
            Color.clear // MARK: - This pushes content down... Apple bug
            
            Spacer()
            cardView
            
        }
        
    }
    
    var cardView: some View {
        
        //        ZStack(alignment: .top) {
        //            
        //            Color.pink.opacity(0.4).ignoresSafeArea()
        
        CardView(backgroundColor: .purple.opacity(0.8),
                 verticalPadding: 32,
                 horizontalPadding: 32, content: {
            
            //                VStack {
            
            //                    ZStack {
            //                        Text("TEST")
            //                    }
            //                        .font(.largeTitle)
            //                        .background(Color.green)
            //                        .frame(maxWidth: .infinity)
            
            VStack(spacing: 8) {
                
                HStack(spacing: 16) {
                    
                    Image(systemName: "book.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(16)
                        .background(Color.white)
                        .clipShape(Circle())
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(16)
                        .background(Color.white)
                        .clipShape(Circle())
                    
                    CircularIconView(
                        foregroundColor: .black,
                        backgroundColor: .white,
                        size: 48,
                        systemImage: "safari.fill"
                    )
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 48, height: 48)
//                        .padding(16)
                        .overlay(content: {

                            Image(systemName: "safari.fill")
                                .resizable()
                                .foregroundStyle(.black)
                                .frame(width: 24, height: 24)
                            
                        })
                    
                    ZStack {
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 48, height: 48)
                        
                        // Use this implementation for an SF Symbol
                        Image(systemName: "safari.fill")
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                        
                        // Use this implementation for an image in your assets folder.
            //            Image(icon)
            //                .resizable()
            //                .aspectRatio(1.0, contentMode: .fit)
            //                .frame(width: squareSide, height: squareSide)
                    }
                    
                }
                .padding(.bottom, 24)
                 
                Label("Books", systemImage: "book.fill")
                    .labelStyle(AppLabelStyle())
                
                Label("Favorites", systemImage: "heart.fill")
                    .labelStyle(AppLabelStyle())
                
                Label("Internet", systemImage: "safari")
                    .labelStyle(AppLabelStyle())
                
                AvatarView(name: "Sako Hovaguimian")
                AvatarView(name: "Sako")
                AvatarView(name: "Hovaguimian")
                
                Image(.pond)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width - 128, height: 150)
                    .cornerRadius(12)
                    .padding(.top, 16)
                
                let data = ["123", "234", "345"]
                
                HStack {
                    
                    ForEach(data, id: \.self) { item in
                        Text(item)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .foregroundStyle(.white)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                }
                
            }
            
            //                    
            //                    Label("SwiftUI Tutorials", systemImage: "book.fill")
            //                        .labelStyle(AppLabelStyle())
            //                    
            //                    Label("SwiftUI Tutorials", systemImage: "book.fill")
            //                        .labelStyle(AppLabelStyle())
            //                    
            //                    Label("SwiftUI Tutorials", systemImage: "book.fill")
            //                        .labelStyle(AppLabelStyle())
            //                    
            //                    Label("SwiftUI Tutorials", systemImage: "book.fill")
            //                        .labelStyle(AppLabelStyle())
            
            //                }
            //                .background(Color.yellow)
            
        })
    }
            //        .frame(height: 200)
            
//            Spacer()
            
//        }
//    }
    
}

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
    
    init(name: String) {
        
        self.name = name
        self.foregroundColor = .black
        self.backgroundColor = .white
        self.size = 48
        
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
            else if let _ = self.name {
                
                Text(formattedName())
                    .fontWeight(.heavy)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.black)
                
            }
            
        }
        
    }
    
}
