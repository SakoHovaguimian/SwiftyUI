//
//  CodeInputView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/11/23.
//

import SwiftUI

struct CodeInputView: View {
    
    @Binding var codeInput: String
    
    var maxCharacterCount: Int = 6
    
    var body: some View {
        
        ZStack {
            
            AppColor.eggShell
                .ignoresSafeArea()
            
            HStack(spacing: 8) {
                
                Spacer()
                
                ForEach(0..<self.maxCharacterCount, id: \.self) { i in
                    
                    let character = getCharacterForIndex(i)
                    
                    Text(character ?? "-")
                        .lineLimit(1, reservesSpace: true)
                        .fontWeight(.heavy)
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .frame(width: 48, height: 48)
                        .foregroundStyle(character == nil ? Color.gray : Color.black)
                        .background(Color(uiColor: .systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 11))
                        .shadow(radius: 10)
                    
                }
                
                Spacer()

            }
            
            TextField("", text: self.$codeInput)
                .foregroundStyle(.clear)
                .background(Color.clear)
                .tint(Color.clear)
            
            
        }
        .onChange(of: self.codeInput, { oldValue, newValue in
            
            if self.codeInput.count > self.maxCharacterCount {
                self.codeInput = String(self.codeInput.dropLast())
            }
            
        })
        .keyboardType(.numberPad)
        
    }
    
    private func getCharacterForIndex(_ index: Int) -> String? {
        
        if let text = self.codeInput[index] {
            return String(text)
        }
        
        return nil
        
    }
    
}

#Preview {
    CodeInputView(codeInput: .constant("1"))
}
