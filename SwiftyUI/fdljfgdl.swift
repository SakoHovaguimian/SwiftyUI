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
            
            Color.red.ignoresSafeArea()
            
            VStack {
                
                Text("1231231231")
                    .asButton {
                        
                        if items.count > 3 {
                            print(dump(items))
                        }
                        
                        print(items.count)
                        items.append("\(Int.random(in: 0...1000))")
                        
                    }
                
                ForEach(Array(items.enumerated()), id: \.element) { index, item in
                    
                    Text("WTF")
                    TextField("TEXT", text: $items[index])
                        .background(.blue)
                    
                }
                
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        
    }
    
}

#Preview {
    pleaseWorkView()
}
