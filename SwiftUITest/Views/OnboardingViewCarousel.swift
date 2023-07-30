//
//  OnboardingViewCarousel.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/26/23.
//

import SwiftUI

enum OnboardingItem: Int, CaseIterable, Identifiable {
    
    var id: Int {
        return self.rawValue
    }
    
    case play
    case payout
    case fun
    
    var onboardingItem: Onboarding {
        
        switch self {
        case .play:
            
                .init(
                    title: "Change The Way You Play!",
                    message: "We've curated all the data points to increase your performance",
                    actionTitle: "Next",
                    colors: [Color(uiColor: .systemOrange), .pink]
                )

        case .payout:
            
                .init(
                    title: "Increase Your Payout",
                    message: "We've curated all the data points to increase your performance",
                    actionTitle: "Next",
                    colors: [Color(uiColor: .systemPink), .red]
                )
            
        case .fun:
            
                .init(
                    title: "Just Have Fun!",
                    message: "Understand that this is just a game, and win...",
                    actionTitle: "Start the game",
                    colors: [Color(uiColor: .red), .purple]
                )
            
        }
        
    }
    
    var isLastItem: Bool {
        return self == .fun
    }
    
}

struct Onboarding: Hashable {
    
    let title: String
    let message: String
    let actionTitle: String
    let colors: [Color]
    
}

struct OnboardingViewCarousel: View {
    
    @State private var currentItem: OnboardingItem = .play {
        didSet {
            print(self.currentItem)
        }
    }
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(
                colors: [Color(uiColor: .magenta).opacity(0.5), .pink],
                startPoint: .top,
                endPoint: .bottom
            )
            
            TabView(selection: self.$currentItem) {
                
                // We can remove this to and do a basic for loop
                
                ForEach(OnboardingItem.allCases) { item in
                    
                    onboardingView(item.onboardingItem, action: {
                        //Remove Action
                        
                    })
                    .tag(item)
                    .ignoresSafeArea()
                }
                
            }
            .overlay(alignment: .bottom) {
             
                VStack {
                    Button(
                        action: { handleButtonTap() },
                        label: {
                            Text(self.currentItem.onboardingItem.actionTitle)
                                .frame(minWidth: 240, minHeight: 50, alignment: .center)
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(13)
                        })
                    
                }
                .padding(.bottom, 64)
                .frame(maxWidth: .infinity)
                
            }
            .tabViewStyle(.page)
            .animation(.spring(), value: self.currentItem)
            
        }
        .ignoresSafeArea()
        
    }
    
    func handleButtonTap() {
        
        if self.currentItem.isLastItem {
            print("LAUNCHING APP")
        }
        else {
            
            let index = self.currentItem.rawValue
            self.currentItem = OnboardingItem(rawValue: index + 1)!
            print("INcrementing")
            
        }
        
        print("Tapped")
        
    }
    
    func onboardingView(_ item: Onboarding, action: (() -> ())?) -> some View {

        ZStack(alignment: .top) {
            
            LinearGradient(
                colors: item.colors,
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(alignment: .center, spacing: 32) {
                
                RoundedRectangle(cornerRadius: 23)
                    .fill(Color(uiColor: .systemGray6))
                    .frame(width: UIScreen.main.bounds.width - 64, height: UIScreen.main.bounds.height / 2.5)
                
                Group {
                    
                    Text(item.title)
                        .fontDesign(.rounded)
                        .font(.title.bold())
                        .multilineTextAlignment(.center).multilineTextAlignment(.center)
                    
                    Text(item.message)
                        .fontDesign(.rounded)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.top, -16)
                    
                }
                
            }
            .padding(.top, 120)
//            .frame(maxHeight: .infinity)
            .padding(.horizontal, 24)
            
            
        }
        
    }
}

#Preview {
    OnboardingViewCarousel()
}
