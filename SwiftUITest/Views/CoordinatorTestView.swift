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
            
            ZStack {
                Color.blue.ignoresSafeArea()
                    .onTapGesture {
                        self.navigationService.push(.redView)
                    }
            }
            .withNavigationDestination()
            .withSheetDestination(self.$navigationService.sheet)
            .withFullScreenCover(self.$navigationService.fullScreenCover)
            
        }
        .environmentObject(self.navigationService)
        
    }
    
}
