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
                
                HStack(spacing: 32) {
                    
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
                    
                    Image(systemName: "safari.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(16)
                        .background(Color.white)
                        .clipShape(Circle())
                    
                }
                .padding(.bottom, 24)
                 
                Label("Books", systemImage: "book.fill")
                    .labelStyle(AppLabelStyle())
                
                Label("Favorites", systemImage: "heart.fill")
                    .labelStyle(AppLabelStyle())
                
                Label("Internet", systemImage: "safari")
                    .labelStyle(AppLabelStyle())
                
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
