//
//  CustomToggle.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/23/24.
//

import SwiftUI

struct SymbolToggleStyle: ToggleStyle {
 
    var systemImage: String = "checkmark"
    var activeColor: Color = .green
    
    var width: CGFloat = 50
    var offsetWidth: Double {
        return Double(self.width) * 0.15
    }
 
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
 
            Spacer()
 
            RoundedRectangle(cornerRadius: 30)
                .fill(configuration.isOn ? activeColor : Color(.systemGray5))
                .overlay {
                    Circle()
                        .fill(.white)
                        .padding(3)
                        .overlay {
                            Image(systemName: systemImage)
                                .foregroundColor(configuration.isOn ? activeColor : Color(.systemGray5))
                                .contentTransition(.symbolEffect(.automatic))
                        }
                        .offset(x: configuration.isOn ? offsetWidth : -offsetWidth)
 
                }
                .frame(width: width, height: 32)
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}

internal struct CustomToggleTestView: View {
    
    @State private var isEnabled: Bool = false
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            Toggle(isOn: $isEnabled) {
                Text("Is Locked")
            }
            .toggleStyle(SymbolToggleStyle(systemImage: isEnabled ? "person.fill" : "person", activeColor: .red))
            .padding(24)
            .background(Color.black.opacity(0.05))
            .clipShape(.capsule)
            .padding(.horizontal, 24)
            
            Toggle(isOn: $isEnabled) {
                Text("Airplane mode")
            }
            .toggleStyle(SymbolToggleStyle(systemImage: isEnabled ? "lock.fill" : "lock", activeColor: .green))
            .padding(24)
            .background(Color.black.opacity(0.05))
            .clipShape(.capsule)
            .padding(.horizontal, 24)
            
        }
        
    }
    
}

#Preview {
    CustomToggleTestView()
}
