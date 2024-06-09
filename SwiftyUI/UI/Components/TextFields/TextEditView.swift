//
//  TextEditView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/15/23.
//

import SwiftUI

struct TextEditView: View {
    
    @Binding var text: String
    var placehoderText: String
    var isFocused: Bool
    var borderColor: Color = ThemeManager.shared.accentColor()
    
    var body: some View {
    
        TextField(self.placehoderText, text: self.$text, axis: .vertical)
            .lineLimit(5, reservesSpace: true)
            .padding(16)
            .background(ThemeManager.shared.background(.secondary))
            .foregroundStyle(ThemeManager.shared.accentColor())
            .appFont(with: .title(.t5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(self.isFocused ? self.borderColor : .black.opacity(0.3), lineWidth: 2)
            }
            .shadow(radius: 11)
            .tint(self.borderColor)
        
    }
    
}


#Preview {
    
    TextEditView(text: .constant(""), placehoderText: "Some Placeholder", isFocused: false)
        .padding(.horizontal, 32)
    
}
