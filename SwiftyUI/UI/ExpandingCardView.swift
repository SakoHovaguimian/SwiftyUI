//
//  ExpandingCardView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 10/10/24.
//

import SwiftUI

struct CardItem: Identifiable {
    
    var id = UUID()
    var title: String
    var color: Color
    var description: String
    
}

struct ExpandingCardView: View {
    
    var item: CardItem
    var isExpanded: Bool
    
    var alignment: Alignment {
        return isExpanded ? .leading : .center
    }
    
    var horizontalAlignment: HorizontalAlignment {
        return isExpanded ? .leading : .center
    }
    
    var body: some View {
        
        VStack(alignment: self.horizontalAlignment, spacing: 10) {
            
            Text(self.item.title)
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal)
                .foregroundColor(.white)
                .shadow(radius: 3)
            
            if self.isExpanded {
                
                Text(self.item.description)
                    .font(.system(size: 16))
                    .padding([.horizontal])
                    .foregroundColor(.white.opacity(0.9))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: self.alignment)
        .padding(.vertical, self.isExpanded ? 32 : 16)
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        self.item.color.opacity(
                            0.8
                        ),
                        self.item.color
                    ]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: self.item.color.opacity(0.4), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        
    }
    
}

struct ExpandingCardListView: View {
    
    @State private var selectedCardIndex: Int? = nil
    
    let cards = [
        
        CardItem(
            title: "Travel",
            color: .blue,
            description: "Discover the most beautiful destinations around the world and make unforgettable memories."
        ),
        CardItem(
            title: "Fitness",
            color: .green,
            description: "Start your fitness journey today with personalized plans and stay healthy."
        ),
        CardItem(
            title: "Cooking",
            color: .red,
            description: "Learn to cook amazing dishes with easy-to-follow recipes and tips."
        ),
        CardItem(
            title: "Technology",
            color: .purple,
            description: "Stay updated with the latest tech trends and innovations."
        ),
        CardItem(
            title: "Art",
            color: .orange,
            description: "Explore your creativity and learn new artistic techniques."
        )
        
    ]
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    ForEach(cards.indices, id: \.self) { index in
                        
                        ExpandingCardView(item: cards[index], isExpanded: selectedCardIndex == index)
                            .asButton {
                                
                                withAnimation(
                                    .spring(
                                        response: 0.5,
                                        dampingFraction: 0.7,
                                        blendDuration: 0.5
                                    )
                                ) {
                                    
                                    if selectedCardIndex == index {
                                        selectedCardIndex = nil
                                    } else {
                                        selectedCardIndex = index
                                    }
                                    
                                }
                                
                            }
                            .padding(.horizontal, selectedCardIndex == index ? 16 : 24)
                        
                    }
                    
                }
                
            }
            .navigationTitle("Expanded Card List")
            .navigationBarTitleDisplayMode(.inline)
            
        }
        
    }
    
}

#Preview {
    
    ExpandingCardListView()
    
}
