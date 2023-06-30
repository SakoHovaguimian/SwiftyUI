//
//  OnboardingViewCarousel.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/26/23.
//

import SwiftUI

struct OnboardingItem: Hashable {
    
    let title: String
    let message: String
    let actionTitle: String
    let colors: [Color]
    
    static func DUMMY_DATA() -> [Self] {
        
        [
            
            .init(
                title: "Change The Way You Play!",
                message: "We've curated all the data points to increase your performance",
                actionTitle: "Next",
                colors: [Color(uiColor: .systemOrange), .pink]
            ),
        
            .init(
                title: "Increase Your Payout",
                message: "We've curated all the data points to increase your performance",
                actionTitle: "Next",
                colors: [Color(uiColor: .systemPink), .red]
            ),
        
            .init(
                title: "Just Have Fun!",
                message: "Understand that this is just a game, and win...",
                actionTitle: "Start the game",
                colors: [Color(uiColor: .red), .purple]
            )
    
        ]
        
    }
    
}

struct OnboardingViewCarousel: View {
    
    @State private var currentIndex = 0 {
        didSet {
            print(self.currentIndex)
        }
    }
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(
                colors: [Color(uiColor: .magenta).opacity(0.5), .pink],
                startPoint: .top,
                endPoint: .bottom
            )
            
            TabView(selection: self.$currentIndex) {
                
                ForEach(OnboardingItem.DUMMY_DATA().indices) { index in
                    onboardingView(OnboardingItem.DUMMY_DATA()[index], action: {
                        
                        if self.currentIndex == OnboardingItem.DUMMY_DATA().count - 1 {
                            print("LAUNCHING APP")
                        }
                        else {
                            self.currentIndex += 1
                        }
                        
                        print("Tapped")
                    })
                        .tag(index)
                        .ignoresSafeArea()
                }
                
            }
            .tabViewStyle(.page)
            .animation(.spring(), value: self.currentIndex)
            
        }
        .ignoresSafeArea()
        
    }
    
    func onboardingView(_ item: OnboardingItem, action: (() -> ())?) -> some View {

        ZStack(alignment: .top) {
            
            LinearGradient(
                colors: item.colors,
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(alignment: .center, spacing: 16) {
                
                Group {
                    
                    RoundedRectangle(cornerRadius: 23)
                        .fill(Color(uiColor: .systemGray6))
                        .frame(width: UIScreen.main.bounds.width - 64, height: UIScreen.main.bounds.height / 4)
                    
                    Text(item.title)
                        .fontDesign(.rounded)
                        .font(.title.bold())
                        .multilineTextAlignment(.center).multilineTextAlignment(.center)
                    
                    Text(item.message)
                        .fontDesign(.rounded)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    
                }
                
            }
            .frame(maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, content: {
                
                Button(action: { action?() }, label: {
                    Text(item.actionTitle)
                        .frame(minWidth: 240, minHeight: 50, alignment: .center)
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(13)
                })
                .padding(.bottom, 64)
                
            })
            .padding(.horizontal, 24)
            
        }
        
    }
}

#Preview {
    OnboardingViewCarousel()
}
