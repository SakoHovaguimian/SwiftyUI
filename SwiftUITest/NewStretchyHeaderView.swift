//
//  NewStretchyHeaderView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/6/23.
//

import SwiftUI

struct NewStretchyHeaderContentView: View {
    
    var body: some View {
        
        ScrollView {
            
            NewStretchyHeaderView(imageName: "pond") {
                
                VStack {
                    
                    Spacer()
                    
                    Text("@SakoHovagumian")
                        .font(.largeTitle)
                        .bold()
                        .fontDesign(.rounded)
                    
                    Spacer()
                    
                }
                
            }
            .ignoresSafeArea()
            
            ForEach(0..<40) { _ in
                
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: UIScreen.main.bounds.width - 48, height: 200)
                
                
            }
            .padding(.top, 32)
            
        }
        // This is hear to make the starting offset 0
        .ignoresSafeArea()
        
    }
    
}

#Preview {
    NewStretchyHeaderContentView()
}

struct NewStretchyHeaderView<Content: View>: View {
    
    var imageName: String
    var height: CGFloat = 300
    var shouldBlur: Bool = true
    
    private let content: Content?
    
    init(imageName: String,
         height: CGFloat = 300,
         shouldBlur: Bool = true,
         @ViewBuilder content: () -> Content) {
        
        self.imageName = imageName
        self.height = height
        self.shouldBlur = shouldBlur
        self.content = content()
        
    }
    
    var body: some View {
        
        let image: UIImage = UIImage(named: self.imageName)!
        
        GeometryReader { geometry in
            
            let offsetY = geometry.frame(in: .global).minY
            let isScrolled = offsetY > 0
            
            Spacer()
                .frame(
                    height: isScrolled ? self.height + offsetY : self.height
                )
                .background {
                    
                    ZStack {
                        
                        Image(uiImage: image)
                            .resizable(resizingMode: .stretch)
                            .if((image.size.width) > (image.size.height), transform: { view in
                                view.scaledToFill()
                            })
                                .offset(y: isScrolled ? -offsetY : 0)
                                .scaleEffect(isScrolled ? offsetY / 2000 + 1 : 1)
                                .blur(radius: calculateBlurAmount(offset: offsetY))
                                .overlay {
                                
                                self.content
                                    .offset(y: offsetY > 0 ? -offsetY : 0)
                                
                            }
                        
                    }
                    
                }
            
        }
        .frame (height: self.height)
        
    }
    
    private func calculateBlurAmount(offset: CGFloat) -> CGFloat {
        
        if !self.shouldBlur {
            return 0
        }
        
        let isScrolled = offset > 0
        return isScrolled ? offset / 100 : 0
        
    }
    
}

extension UIImage {
    
    func scalePreservingAspectRatio(width: Int, height: Int) -> UIImage {
        let widthRatio = CGFloat(width) / size.width
        let heightRatio = CGFloat(height) / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize,
            format: format
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
    
}
