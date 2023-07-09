//
//  ArcMenuButtonView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/8/23.
//

import SwiftUI

struct ArcMenuButtonView: View {
    
    @State private var selectedAction: Int? = nil
    
    var body: some View {
        
        ZStack {
            
            AppColor
                .charcoal
                .ignoresSafeArea()
            
            if let selectedAction {
                Text("\(selectedAction)")
            }
            
            VStack {
                
                ArcMenuButton(
                    style: .radial,
                    buttons: ["circle", "star", "bell", "bookmark"]) { index in
                        self.selectedAction = index
                    }
                    .padding(.bottom, 20)
                    .padding(.trailing, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                
            }
            
            VStack {
                
                ArcMenuButton(
                    style: .horizontal(direction: .left),
                    buttons: ["circle", "star", "bell", "bookmark"]) { index in
                        self.selectedAction = index
                    }
                    .padding(.bottom, 20)
                    .padding(.trailing, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                
            }
            
            VStack {
                
                ArcMenuButton(
                    style: .horizontal(direction: .right),
                    buttons: ["circle", "star", "bell", "bookmark"]) { index in
                        self.selectedAction = index
                    }
                    .padding(.top, 80)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
            }
            
            VStack {
                
                ArcMenuButton(
                    style: .vertical(direction: .up),
                    buttons: ["circle", "star", "bell", "bookmark"]) { index in
                        self.selectedAction = index
                    }
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                
            }
            
            VStack {
                
                ArcMenuButton(
                    style: .vertical(direction: .down),
                    buttons: ["circle", "star", "bell", "bookmark"]) { index in
                        self.selectedAction = index
                    }
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
            }
            
        }

    }
    
}

#Preview {
    ArcMenuButtonView()
}

// ArcMenuButton

// Add Action param that passed index to parent view
// Create style to make it vertical or radial

struct ArcMenuButton: View {
    
    enum VerticalDirection {
        
        case up
        case down
        
    }
    
    enum HorizontalDirection {
        
        case left
        case right
        
    }
    
    enum Style: Equatable {
        
        case vertical(direction: VerticalDirection)
        case horizontal(direction: HorizontalDirection)
        case radial
        
    }
    
    @State var isExpanded = false
    
    let style: Style
    let buttons: [String]
    let action: ((Int) -> ())
    
    var body: some View {
        
        ZStack {
            
            ForEach(self.buttons.indices, id: \.self) { index in
                
                Image(systemName: buttons [index])
                    .frame(width: 10, height: 10)
                    .padding()
                    .background (Color (.systemGray6))
                    .foregroundColor(.gray)
                    .cornerRadius(20)
                    .offset(x: offsetX(index: index),
                            y: offsetY(index: index))
                
                    .animation(
                        .spring(response: 0.5,
                                dampingFraction: self.style == .radial ? 0.5 : 0.825,
                                blendDuration: 0)
                        .delay(Double (index) * 0.15),
                        value: self.isExpanded
                    )
                    .onTapGesture {
                        self.action(index)
                    }
            }
            
            Button {
                withAnimation {
                    self.isExpanded.toggle()
                }
            } label: {
                Image (systemName: self.isExpanded ? "xmark" : "plus")
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)
                    .padding(15)
                    .background (Color(.systemGray6))
                    .cornerRadius (25)
                
            }
            
        }
        
    }
    
    private func offsetX(index: Int) -> CGFloat {
        
        switch self.style {
        case .vertical: return 0
        case .horizontal(let direction):
            
            if !self.isExpanded {
                return 0
            }
            
            let leadingFactor = (direction == .left ? -Double.pi : Double.pi)
            return self.isExpanded ? CGFloat(((Double(index) * 45 + 50) * leadingFactor / 180) * 60) : 0
            
        case .radial:
            return self.isExpanded ? CGFloat(cos((Double(index) * 45 + 135) * Double.pi / 180) * 60): 0
        }
        
    }
    
    private func offsetY(index: Int) -> CGFloat {
        
        switch self.style {
        case .vertical(let direction):
            
            let verticalFactor = (direction == .up ? -Double.pi : Double.pi)
            return self.isExpanded ? CGFloat(((Double(index) * 45 + 50) * (verticalFactor / 180) * 60)) : 0
            
        case .horizontal: return 0
        case .radial:
            return self.isExpanded ? CGFloat(sin((Double(index) * 45 + 135) * Double.pi / 180) * 60): 0
        }
        
    }
    
}
