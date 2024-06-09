//
//  WStackViewPreview.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/20/23.
//

import SwiftUI

struct WStackExamplesView: View {
    
    @State private var selectedFruit: String? = nil
    
    let fruits = [
        "🍎 Red Apple",
        "🍐 Pear",
        "🍊 Tangerine",
        "🍋 Lemon",
        "🍌 Banana",
        "🍉 Watermelon",
        "🍇 Grapes",
        "🍓 Strawberry",
        "🫐 Blueberries",
        "🍈 Melon",
        "🍒 Cherries",
        "🍑 Peach",
        "🥭 Mango",
        "🍍 Pineapple",
        "🥥 Coconut",
        "🥝 Kiwi",
        "🍅 Tomato",
        "🍆 Eggplant",
        "🥑 Avocado",
        "🫛 Pea Pod",
        "🥦 Broccoli",
        "🥬 Leafy Greens",
        "🥒 Cucumber",
        "🌶️ Hot Pepper",
        "🫑 Bell Pepper",
        "🌽 Ear of Corn",
        "🥕 Carrot",
        "🫒 Olive",
        "🧄 Garlic",
        "🧅 Onion",
        "🥔 Potato",
        "🍠 Roasted Sweet Potato",
    ]
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 32) {
                
                WStack(fruits, spacing: 4, lineSpacing: 4) { fruit in
                    Text(fruit)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(backgroundColor(fruit: fruit))
                        .cornerRadius(20)
                        .onTapGesture {
                            selectFruit(fruit)
                        }
                }
                
                WStack(Array(fruits[0...3]), spacing: 4, lineSpacing: 4, lineLimit: 2, isHiddenLastItem: true) { fruit in
                    Text(fruit)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(backgroundColor(fruit: fruit))
                        .cornerRadius(8)
                        .onTapGesture {
                            selectFruit(fruit)
                        }
                }
                
                WStack(Array(fruits[0...3]), spacing: 4, lineSpacing: 4, lineLimit: 2, isHiddenLastItem: false) { fruit in
                    Text(fruit)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(backgroundColor(fruit: fruit))
                        .cornerRadius(8)
                        .onTapGesture {
                            selectFruit(fruit)
                        }
                }
                
                WStack(Array(fruits[0...10]), spacing: 4, lineSpacing: 4, lineLimit: 2, isHiddenLastItem: false) { fruit in
                    Text(fruit)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(backgroundColor(fruit: fruit))
                        .cornerRadius(8)
                        .onTapGesture {
                            selectFruit(fruit)
                        }
                }
                
                WStack(Array(fruits[0...10]), spacing: 4, lineSpacing: 8, lineLimit: 8, isHiddenLastItem: true) { fruit in
                    Text(fruit)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(backgroundColor(fruit: fruit))
                        .cornerRadius(8)
                        .onTapGesture {
                            selectFruit(fruit)
                        }
                }
            }
            .padding()
        }
    }
    
    private func backgroundColor(fruit: String) -> Color {
        return self.selectedFruit == fruit ? .indigo.opacity(0.6) : Color.secondary.opacity(0.2)
    }
    
    private func selectFruit(_ fruit: String) {
        return self.selectedFruit = self.selectedFruit == fruit ? nil : fruit
    }
    
}

#Preview {
    WStackExamplesView()
}
