//
//  StringViewTest.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 4/9/25.
//

import SwiftUI

struct StringViewTest: View {
    
    let text: String = "Sako how are you doing today?"
    let camelCasedText: String = "sakoHowAreYouDoingToday"
    
    var body: some View {
        
        textView(self.text)
        textView(self.camelCasedText)
        
        Divider()
            .background(.pink)
        
        textView(StringSource.pluralize("Try"))
        textView(StringSource.transform(
            camelCasedText,
            from: .camelCase,
            to: .kebabCase
        ))
        
        let localizableGame = StringSource.localized(fromFile: "Localizable", key: "test.something")
        textView(localizableGame)
        
        AttributedText {
            
            Text("This is ")
            
            Text("Awesome & Creative")
                .foregroundStyle(.brandPink)
                .bold()
                .monospaced()
            
        }
        
    }
    
    func textView(_ text: String) -> some View {
        
        Text(text)
            .appFont(with: .title(.t5))
        
    }
    
}

#Preview {
    
    StringViewTest()
    
}
