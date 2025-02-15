//
//  ContentView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/3/24.
//

// Data can be passed in and updated from Apple's Environment
// or by Passing a viewModel in the init method of a view
// i.e. @Env & @Observable stsy observed and the view updates the
// childrens data source

import SwiftUI

@Observable
final class EnvService {
    
    var env = "STG"
    
    func updateEnv(_ env: String) {
        self.env = env
    }
    
}

@Observable
final class HomeViewModel {
    
    var items: [String] = [
        "Gun",
        "Sword",
        "Shield",
        "Potion"
    ]
    
    func addItem(_ item: String) {
        self.items.append(item)
    }
    
}

struct HomeView: View {
    
    @Environment(EnvService.self) private var envService
    
    @State private var homeViewModel: HomeViewModel!
    
    init(homeViewModel: HomeViewModel!) {
        self._homeViewModel = State(wrappedValue: homeViewModel)
    }
    
    var body: some View {
        
        List {
            
            Section("Current Env") {
                ChildHomeView()
            }
            
            Section("Items") {
                
                ForEach(self.homeViewModel.items, id: \.self) { item in
                
                    Text(item)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                    
                }
                
            }
            
            Section {
                
                Button("Add Item") {
                    
                    withAnimation {
                        self.homeViewModel.addItem("Some New Item")
                        self.envService.updateEnv("Some New Env")
                    }
                    
                }
                
            }
            
        }
        .foregroundStyle(.darkBlue)
        
    }
    
}

#Preview {
    HomeView(homeViewModel: .init())
        .environment(EnvService())
}

struct ChildHomeView: View {
    
    @Environment(EnvService.self) private var envService
    
    var body: some View {
        
        Text(self.envService.env)
            .font(.title)
            .fontWeight(.black)
            .fontDesign(.monospaced)
        
    }
    
}
