//
//  TextProgressBar.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/16/25.
//

import SwiftUI

struct TextProgressBar: View {
    
    @Binding var value: CGFloat
    @State private var animatedValue: CGFloat = 0
    
    var text: String
    var textFont: AppFont = .body(.b5)
    var textColor: AppForegroundStyle = .color(.white)
    
    var trackColor: AppForegroundStyle
    var fillColor: AppBackgroundStyle
    
    var cornerRadius: CornerRadius = .small
    
    var body: some View {
        
        textView()
            .padding(.small)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                progressBar()
            }
            .clipShape(.rect(cornerRadius: self.cornerRadius.value))
        
        // Lifecycle
        
            .onAppear {
                animateValue(to: self.value)
            }
        
            .onChange(of: self.value) { newValue in
                animateValue(to: newValue)
            }
        
    }
    
    private func textView() -> some View {
        
        Text(self.text)
            .appFont(with: self.textFont)
            .foregroundStyle(self.textColor.foregroundStyle())
        
    }
    
    private func progressBar() -> some View {
        
        return GeometryReader { geometry in
            
            let fillWidth = min(animatedValue, 1) * geometry.size.width
            
            ZStack(alignment: .leading) {
                
                // Track
                
                Rectangle()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .opacity(0.3)
                    .foregroundStyle(self.trackColor.foregroundStyle())
                
                // Fill
                
                Rectangle()
                    .frame(
                        width: fillWidth,
                        height: geometry.size.height
                    )
                    .foregroundStyle(self.fillColor.backgroundStyle())
                    .animation(.spring(), value: self.value)
                
            }
            
        }
        
    }
    
    private func animateValue(to newValue: CGFloat) {
        
        withAnimation {
            self.animatedValue = newValue
        }
        
    }
    
}

#Preview {
    
    @Previewable @State var value: CGFloat = 0.6
    
    TextProgressBar(
        value: $value,
        text: "Total Progress: \(Int(value * 100))%",
        textFont: .title(.t4),
        textColor: .color(.white),
        trackColor: .color(.gray),
        fillColor: .color(.indigo),
        cornerRadius: .small
    )
    .padding(.horizontal, 24)
    .appOnTapGesture {
        
        withAnimation {
            value = CGFloat.random(in: 0...1)
        }
        
    }
    
}
