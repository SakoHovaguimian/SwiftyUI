//
//  CoordinatorTestView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/16/23.
//

import SwiftUI

struct CoordinatorTestView: View {
    
    @ObservedObject var firebaseService: FirebaseService
    @StateObject var navigationService: NavigationService
    
    var body: some View {
        
        NavigationStack(path: self.$navigationService.pathItems) {
            
            self.navigationService
                .build(route: .blueView)
            
                .navigationDestination(for: NavigationService.Route.self) { route in
                    self.navigationService.build(route: route)
                }
                .sheet(item: self.$navigationService.sheet) { sheet in
                    self.navigationService.build(sheet: sheet)
                }
                .fullScreenCover(item: self.$navigationService.fullScreenCover) { fullScreenCover in
                    self.navigationService.build(fullScreenCover: fullScreenCover)
                }
            
        }
        
    }
    
}
