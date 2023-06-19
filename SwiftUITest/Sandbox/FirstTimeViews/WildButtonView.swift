//
//  TestView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/12/23.
//

import SwiftUI

struct WildButtonView: View {
    
    @State private var toolbarRotation: Bool = false
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            Color
                .gray
                .opacity(0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                
                HStack(spacing: 16) {
                    
                    Spacer()
                    
                    favoriteView
//                        .wildMode(toolbarRotation: self.toolbarRotation)
                    
                    moneyView
//                        .wildMode(toolbarRotation: self.toolbarRotation)
                    
                    Spacer()
                    
                }
                .frame(maxHeight: .infinity)
//                .background(Color.gray)
                
                HStack(spacing: 16) {
                    
                    Spacer()
                    
                    weatherView
//                        .wildMode(toolbarRotation: self.toolbarRotation)
                    
                    searchView
//                        .wildMode(toolbarRotation: self.toolbarRotation)
                    
                    Spacer()
                    
                }
                .frame(maxHeight: .infinity)
//                .background(Color.gray)
                
                Spacer()
                
                Button("Rotate") {
                    withAnimation {
                        self.toolbarRotation.toggle()
                    }
                }
//                .background(Color.purple.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 11))
//                .foregroundColor(Color.white)
                .tint(Color.blue)
                .buttonStyle(.bordered)
                
                NavigationLink(value: DevToolsNavigationRoute.product(productId: "Custom Tshirt design")) {
                    Text("Route to Custom Button")
                }

//                .background(Color.purple.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 11))
//                .foregroundColor(Color.white)
                .tint(Color(.init(red: 122/255, green: 100/255, blue: 251/255, alpha: 1.0)))
                .buttonStyle(.borderedProminent)
                
            }
            
        }
        
    }
    
    var favoriteView: some View {
        
        StyledLabel(
            title: "Favorites",
            systemImageName: "heart.fill",
            color: .pink) {
                print("you tapped the favorite button")
            }
        
    }
    
    var moneyView: some View {
        
        StyledLabel(
            title: "Money",
            systemImageName: "dollarsign.circle.fill",
            color: .green) {
                print("you tapped the money button")
            }
        
    }
    
    var searchView: some View {
        
        StyledLabel(
            title: "Search",
            systemImageName: "magnifyingglass.circle.fill",
            color: .orange) {
                print("you tapped the search button")
            }
        
    }
    
    var weatherView: some View {
        
        StyledLabel(
            title: "Weather",
            systemImageName: "sun.min.fill",
            color: .indigo) {
                print("you tapped the weather button")
            }
        
    }
    
    func generateRandomNumber() -> Double {
        
        return Bool.random()
        ? (Double(-(0...300).randomElement()!))
        : (Double((0...300).randomElement()!))
        
    }
    
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        WildButtonView()
    }
}

struct WildMode: ViewModifier {
    
    var toolbarRotation: Bool = false

    func body(content: Content) -> some View {

        content
            .offset(y: self.toolbarRotation ? generateRandomNumber() : generateRandomNumber())
            .transformEffect(.init(
                scaleX: self.toolbarRotation ? Double.random(in: 0.4...1) : 1,
                y: self.toolbarRotation ? Double.random(in: 0.4...1) : 1
            ))
            .rotationEffect(.degrees(Double.random(in: 0...360)))
            .zIndex(Double.random(in: 0...3))

    }
    
    func generateRandomNumber() -> Double {
        
        return Bool.random()
        ? (Double(-(0...300).randomElement()!))
        : (Double((0...300).randomElement()!))
        
    }

}

extension View {
    
    func wildMode(toolbarRotation: Bool = false) -> some View {
        return modifier(WildMode(toolbarRotation: toolbarRotation))
    }
                        
}
