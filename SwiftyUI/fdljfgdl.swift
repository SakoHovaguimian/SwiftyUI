//
//  fdljfgdl.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 4/22/25.
//

import SwiftUI

struct pleaseWorkView: View {
    
    @State var items: [String] = []
    
    var body: some View {
        
        ZStack {
            
            Color.cyan
                .ignoresSafeArea()
            
            VStack {

                button()
                list()

            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        
    }
    
    private func button() -> some View {
        
        Text("Fake Button")
            .asButton {
                
                if items.count > 3 {
                    print(dump(items))
                }
                
                print(items.count)
                items.append("\(Int.random(in: 0...1000))")
                
            }
        
    }
    
    private func list() -> some View {
        
        
        ForEach(Array(items.enumerated()), id: \.element) { index, item in

            TextField("TEXT", text: $items[index])
                .background(.blue)
            
        }
        
    }
    
}

#Preview {
    pleaseWorkView()
}
