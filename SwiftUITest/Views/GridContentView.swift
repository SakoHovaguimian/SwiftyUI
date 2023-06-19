//
//  GridContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/16/23.
//

import SwiftUI

import SwiftUI

struct GridContentView: View {
    @State private var inspiration = NatureInspiration.examples()
    @State private var selectedInspiration: NatureInspiration?
    
    let rows = Array(repeating: GridItem(.fixed(120), spacing: 0),
                     count: 2)
    
    var body: some View {
        
        ZStack {
            
            AppColor.background(.primary)
                .ignoresSafeArea()
            
            ScrollView {
                
                ScrollView(.horizontal) {
                    
                    LazyHStack(alignment: .center, spacing: 16) {
                        ForEach(inspiration) { inspiration in
                            InspirationCardView(inspiration: inspiration)
                                .frame(height: 200)
                        }
                    }
                    .padding(24)
                    
                }
                
                LazyVStack (alignment: .leading, spacing: 16) {
                    
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 8) {
                            ForEach(inspiration) { inspiration in
                                cardView(isSelected: inspiration.name == self.selectedInspiration?.name)
                                    .onTapGesture {
                                        
                                        if self.selectedInspiration?.name == inspiration.name {
                                            self.selectedInspiration = nil
                                        }
                                        else {
                                            self.selectedInspiration = inspiration
                                        }
                                        
                                    }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    ScrollView(.horizontal) {
                        
                        LazyHGrid(rows: rows, spacing: 0) {
                            ForEach(inspiration) { inspiration in
                                InspirationTillView(inspiration: inspiration, size: 120, cornerRadius: 0)
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct cardView: View {
        
        var isSelected: Bool
        
        var body: some View {
            
            Text("Nature walk")
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(isSelected ? Color("charcoal") : Color("eggshell"))
                .cornerRadius(24)
                .shadow(radius: 10, y: 0)
                .frame(height: 100)
                .foregroundColor(.black)
            
        }
        
        
    }
    
}

struct GridContentView_Previews: PreviewProvider {
    static var previews: some View {
        GridContentView()
    }
}

//
//  Destination.swift
//  LayoutProject
//
//  Created by Karin Prater on 20.06.22.
//

import Foundation

struct NatureInspiration: Identifiable {
    
    let name: String
    let imageName: String = "sunset"
    let description: String
    let id = UUID()
    
    static func examples() -> [NatureInspiration] {
        
        [
            NatureInspiration(
                name: "Desert",
                description: "A desert is a barren area of landscape where little precipitation occurs and, consequently, living conditions are hostile for plant and animal life."
            ),
            NatureInspiration(
                name: "Tree",
                description: "In botany, a tree is a perennial plant with an elongated stem, or trunk, usually supporting branches and leaves."
            ),
            NatureInspiration(name: "Mountain Air",
                              description: "A mountain is an elevated portion of the Earth's crust, generally with steep sides that show significant exposed bedrock"),
            NatureInspiration(name: "Moos Trees",
                              description: "In our unique moss farm we cultivate natural, pure and high performance moss. This forms the green basis for our regenerative moss filters."),
            NatureInspiration(name: "Sky",
                              description: "The sky is an unobstructed view upward from the surface of the Earth. It includes the atmosphere and outer space. "),
            NatureInspiration(name: "Death Valley",
                              description: "In this below-sea-level basin, steady drought and record summer heat make Death Valley a land of extremes. "),
            NatureInspiration(name: "Sky",
                              description: "The sky is an unobstructed view upward from the surface of the Earth. It includes the atmosphere and outer space. "),
            NatureInspiration(name: "Death Valley",
                              description: "In this below-sea-level basin, steady drought and record summer heat make Death Valley a land of extremes. ")
        ]
    }
    
}

struct InspirationTillView: View {
    let inspiration: NatureInspiration
    let size: CGFloat
    let cornerRadius: CGFloat
    
    var body: some View {
        Image(inspiration.imageName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(radius: 5)
    }
}

struct InspirationCardView: View {
    
    let inspiration: NatureInspiration
    let padding: CGFloat = 10
    
    var body: some View {
        Image(inspiration.imageName)
            .resizable()
            .aspectRatio(16 / 9, contentMode: .fill)
//            .scaledToFit()
            .cornerRadius(24)
            .shadow(radius: 5)
        
            .overlay(alignment: .bottomTrailing, content: {
                Text(inspiration.name)
                    .bold()
                    .foregroundColor(Color.white)
                    .padding()
            })
    }
}
