//
//  PresentationHeightContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/23/23.
//

import SwiftUI

struct PresentationHeightContentView: View {
    
    @State private var heightForCard: CGFloat = 300
    @State private var isCardShowing: Bool = false
    
    @State var selectedDetent: PresentationDetent = .height(300)
    @State var detents: Set<PresentationDetent> = [.height(300)]
    
    var body: some View {
     
        ZStack {
            
            LinearGradient(
                colors: [Color(.teal), Color(.indigo)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                
                Text("SOME TEXT")
                
            }
            .onTapGesture {
                self.isCardShowing.toggle()
            }
            
        }
        .sheet(isPresented: self.$isCardShowing, content: {

            VStack {
                
                Spacer()
                
                if self.selectedDetent == .height(180) {
                    
                    VStack {
                        
                        Button("TEST") {
                            print("12312")
                        }
                        
                        Button("TEST") {
                            print("12312")
                        }
                        
                        Button("TEST") {
                            print("12312")
                        }
                        
                    }
                    
                }
                else {
                    
                    Text("SOME TEXT")
                        .appFont(with: .heading(.h10))
                    
                }
                
                Spacer()
                
            }
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
//                withAnimation {
                    self.detents = [.height(300), .height(180)]
                withAnimation {
                    self.selectedDetent = .height(180)
                }
//                }
            }
            .presentationDetents(self.detents, selection: self.$selectedDetent)
            
        })
        
    }
}

private func cardView() -> some View {
    ZStack { }
}

#Preview {
    PresentationHeightContentView()
}
