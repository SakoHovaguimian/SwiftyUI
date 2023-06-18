//
//  SocialMediaView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/13/23.
//

import SwiftUI

struct SocialMediaView: View {
    
    var initialHeaderHeight: CGFloat = UIScreen.main.bounds.height * 0.4
    @State private var offsetY: CGFloat = 0
    
    // This is nice to make blurs that look like they end in fuzz
    //    let gradient = LinearGradient(
    //        gradient: Gradient(stops: [
    //            .init(color: .purple, location: 0),
    //            .init(color: .clear, location: 0.4)
    //        ]),
    //        startPoint: .bottom,
    //        endPoint: .top
    //    )
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let minY = geometry.frame(in: .global).minY
            
            ZStack(alignment: .top) {
                
                LinearGradient(
                    colors: [.green.opacity(0.7), .mint.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                ScrollView(.vertical) {
                    
                    //                VStack(spacing: 0) {
                    
                    StretchableHeader(image: Image("sunset"), geometryProxy: geometry, initialHeight: 300)
                        .overlay {

                            VStack(spacing: 8) {

                                Text("Sunset")
                                    .bold()
                                    .font(.largeTitle)

                                Text("Shot on an iphone")
                                    .font(.caption)

                                TextField("Add text", text: .constant("Something"))
                                    .padding(6)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                                    .padding(.horizontal)

                            }
                            .foregroundColor(.white)
                            .offset(y: minY > 0 ? -minY : 0)

                        }
//
//
//
//                    ForEach((0...10), id: \.self) { _ in
//
//                        Color.pink
//                            .frame(height: 200)
//                            .cornerRadius(12)
//                            .shadow(radius: 23)
//                            .padding()
//
//                    }
                    
                    
                    //
                    //                }
                    //                    .frame(maxHeight: .infinity)
                    //                    .foregroundStyle(.ultraThickMaterial)
                }
                //                .frame(maxHeight: .infinity)
                
            }
            .ignoresSafeArea(edges: .bottom)
            
        }
        
    }
    
}

struct StretchableHeader: View {
    
    var image: Image
    var geometryProxy: GeometryProxy
    var initialHeight: CGFloat = UIScreen.main.bounds.height * 0.4
    
    var body: some View {
        
        GeometryReader(content: { geometry in
            
            let minY = calculateScrollViewOffSet(minY: geometry.frame(in: .global).minY)
            
            self.image
                .resizable()
                .offset(y: minY > 0 ? -minY : 0)
                .frame(height: minY > 0 ? self.initialHeight + minY : self.initialHeight)
                .aspectRatio(1, contentMode: .fill)
            
        })
        .frame(height: self.initialHeight)
        
    }
    
    private func calculateScrollViewOffSet(minY: CGFloat) -> CGFloat {
        
        if minY < 0 {
            print(50)
            return 50
        } else {
            print(minY)
        }
        
        return minY
        
    }
    
}
