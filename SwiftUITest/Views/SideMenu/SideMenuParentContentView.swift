//
//  SideMenuParentContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/20/23.
//

import SwiftUI

struct SideMenuParentContentView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var isShowing = false
    
    var body: some View {
    
        NavigationStack {
            
            ZStack {
                
                if self.isShowing {
                    
                    SideMenuView(isShowing: self.$isShowing)
                        .toolbar(.hidden, for: .navigationBar)
                    
                }
                
                HomeView()
                    .cornerRadius(self.isShowing ? 20 : 10)
                    .offset(
                        x: self.isShowing ? 300 : 0,
                        y: self.isShowing ? 44 : 0
                    )
                    .scaleEffect(self.isShowing ? 0.8 : 1)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                
                                withAnimation(.spring()) {
                                    self.isShowing.toggle()
                                }
                                
                            } label: {
                                Image(systemName: "list.bullet")
                                    .foregroundStyle(.black)
                                
                            }
                            .buttonStyle(.plain)

                        }
                }
                
            }
            .onAppear {
                self.isShowing = false
            }
            .onTapGesture {
                dismiss()
            }
            
        }
        
    }
    
}

struct HomeView: View {
    
    var body: some View {
        
        ZStack {
            
            Color.white
                .ignoresSafeArea()
                .preferredColorScheme(.light)
            
            Text("Side Menu Demo")
            
        }

    }
    
}

struct SideMenuParentContentView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuParentContentView()
    }
}
