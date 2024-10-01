//
//  RatingView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/28/24.
//

import SwiftUI

struct RatingView: View {
    
    @Binding var rating: Int
    private var numberOfItems: Int = 5
    
    init(rating: Binding<Int>,
         numberOfItems: Int = 5) {
        
        self._rating = rating
        self.numberOfItems = numberOfItems
        
    }
    
    var body: some View {
        
        HStack{
            
            ForEach(1...self.numberOfItems , id: \.self) { index in
                
                Image(systemName: imageStringForIndex(index))
                    .foregroundStyle(highlightColor(index: index))
                    .symbolEffect(
                        .bounce,
                        options: .repeat(animationForIndex(index)),
                        value: self.rating
                    )
                    .appOnTapGesture {
                        
                        withAnimation {
                            self.rating = index == rating ? 0 : index
                        }
                        
                    }
            }
            
        }
        
    }
    
    func animationForIndex(_ index: Int) -> Int {
        return index <= self.rating ? 1 : 0
    }
    
    func imageStringForIndex(_ index: Int) -> String {
        return index <= self.rating ? "star.fill" : "star"
    }
    
    func highlightColor(index: Int) -> Color {
        return index <= self.rating ? .yellow : .gray.opacity(0.3)
    }
    
}

#Preview {
    
    @Previewable @State var rating: Int = 0
    
    AppBaseView(horizontalPadding: .large) {
        
        AppCardView {
            
            VStack(spacing: .appMedium) {
                
                VStack(alignment: .leading) {
                    
                    Text("Rate This App!")
                        .appFont(with: .header(.h5))
                    
                    Text("Tell us what you think about the app.")
                        .appFont(with: .body(.b5))
                        .foregroundStyle(.gray)
                    
                }
                
                RatingView(rating: $rating, numberOfItems: 5)
                    .font(.system(size: 30))
                    .centerHorizontally()
//                
//                if rating > 0 {
//                    
//                    AppButton(title: "Complete", titleColor: .white, backgroundColor: .darkBlue) {
//                        
//                        withAnimation(.bouncy) {
//                            rating = 0
//                        }
//                        
//                    }
//                    .transition(.opacity.combined(with: .move(edge: .bottom)))
//                    
//                }
                
            }
            
        }
        .padding(.horizontal, .xLarge)
        
    }
    
}
