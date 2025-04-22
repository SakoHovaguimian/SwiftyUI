//
//  DropDownTextField.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/23/24.
//

import SwiftUI

struct DropDownMenu: View {
    
    let options: [String]
    
    var menuWdith: CGFloat = 150
    var buttonHeight: CGFloat = 50
    var maxItemDisplayed: Int = 3
    
    @Binding var selectedOptionIndex: Int
    @Binding var showDropdown: Bool
    
    @State private var scrollPosition: Int?
    
    var body: some View {
        
        VStack {
            
            VStack(spacing: 0) {
                
                button(
                    title: options[selectedOptionIndex],
                    icon: "chevron.down",
                    isSelected: true,
                    shouldRotate: self.showDropdown
                ) {
                    
                    withAnimation(.bouncy) {
                        showDropdown.toggle()
                    }
                    
                }
                .padding(.horizontal, 20)
                .frame(width: menuWdith, height: buttonHeight, alignment: .center)
                
                if (showDropdown) {
                    
                    let scrollViewHeight: CGFloat = options.count > maxItemDisplayed
                    ? (buttonHeight * CGFloat(maxItemDisplayed))
                    : (buttonHeight * CGFloat(options.count))
                    
                    ScrollView {
                        
                        items()
                            .scrollTargetLayout()
                        
                    }
                    .scrollPosition(id: $scrollPosition)
                    .scrollDisabled(options.count <=  3)
                    .frame(height: scrollViewHeight)
                    .onAppear {
                        scrollPosition = selectedOptionIndex
                    }
                    
                }
                
            }
            .foregroundStyle(Color.black)
            .background(RoundedRectangle(cornerRadius: .appMedium).fill(Color.white))
            
        }
        .clipped()
        .appShadow()
        .frame(width: menuWdith, height: buttonHeight, alignment: .top)
        .zIndex(100)
        
    }
    
    private func items() -> some View {
        
        LazyVStack(spacing: 0) {
            
            ForEach(0..<options.count, id: \.self) { index in
                
                button(
                    title: options[index],
                    icon: "checkmark.circle.fill",
                    isSelected: (index == selectedOptionIndex)) {
                        
                        withAnimation(.bouncy) {
                            
                            selectedOptionIndex = index
                            showDropdown.toggle()
                            
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    .frame(
                        width: menuWdith,
                        height: buttonHeight,
                        alignment: .center
                    )
                
            }
            
        }
        
    }
    
    private func button(title: String,
                        icon: String,
                        isSelected: Bool,
                        shouldRotate: Bool = false,
                        action: @escaping () -> ()) -> some View {
        
        Button {
            
            action()
            
        } label: {
            
            HStack(spacing: 25) {
                
                Text(title)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .contentTransition(.numericText())
                    .appFont(with: .title(.t4))
                
                Image(systemName: icon)
                    .opacity(isSelected ? 1 : 0)
                    .rotationEffect(.degrees(shouldRotate ? -180 : 0))
                
            }
            
        }
        .foregroundStyle(.black)
        
    }
    
}

fileprivate struct DropDownMenuDemo: View {
    
    @State  private  var selectedOptionIndex =  0
    @State  private  var showDropdown =  false
    
    let fruits = ["Charmander", "Squirtle", "Pikachu", "Bulbasaur"]
    
    var body: some  View {
        
        VStack(spacing: 32) {
            
            DropDownMenu(
                options: fruits,
                menuWdith: 200,
                selectedOptionIndex: $selectedOptionIndex,
                showDropdown: $showDropdown
            )
            
            Text("You have selected \(fruits[selectedOptionIndex])")
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
        .background(Color(uiColor: UIColor.systemGray6))
        .onTapGesture {
            
            withAnimation(.bouncy) {
                showDropdown =  false
            }
            
        }
        
    }
    
}

#Preview {
    
    DropDownMenuDemo()
    
}
