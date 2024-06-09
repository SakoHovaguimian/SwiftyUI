//
//  PintrestLayout.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/7/23.
//

import Foundation
import SwiftUI

struct PintrestColumnModel {
    
    var id = UUID()
    var item: GridItem
    
    static let DUMMY_DATA = [
        PintrestColumnModel(item: GridItem()),
        PintrestColumnModel (item: GridItem())
    ]
    
}

struct PintrestLayout: View {
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            HStack(alignment: .top, spacing: 5) {
                
                ForEach(PintrestColumnModel.DUMMY_DATA, id: \.id)  { _ in
                    PintrestViewItemView()
                }
                
            }
            
        }
        
    }
    
}

#Preview {
    PintrestLayout()
}

struct PintrestViewItemView: View {
    
    var body: some View {
        
        VStack {
            
            ForEach(0...100, id: \.self) { _ in
                
//                let shouldShowImage = Bool.random()
//                let randomImage = [
//                    Image("pond"), Image("sunset")
//                ].randomElement()!
//                
//                if shouldShowImage {
//                    
//                    randomImage
//                        .resizable()
//                        .frame (width: 185, height: CGFloat.random(in: 130...400))
//                        .scaledToFill()
//                        .cornerRadius(11)
//                    
//                }
//                else {
                    
                    let randomGradient = LinearGradient(
                        colors: [
                            Color(uiColor: .random()),
                            Color(uiColor: .random())
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    Rectangle()
                        .frame (width: 185, height: CGFloat.random(in: 130...400))
                        .foregroundStyle(randomGradient)
                        .cornerRadius(10)
                    
//                }
                
            }
            
        }
        
    }
    
}
