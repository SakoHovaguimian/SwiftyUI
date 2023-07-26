//
//  BadgeView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/25/23.
//

import SwiftUI

struct Badge: View {
    
    var name: String
    var color: Color = .blue
    var type: BadgeType = .normal
    
    enum BadgeType {
        case normal
        case removable(()->())
    }
    
    var body: some View {
        HStack{
            // Badge Label
            Text(name)
                .font(Font.caption.bold())
            
            // Add 'x' if removable, and setup tap gesture
            switch type {
                case .removable( let callback):
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 8, height: 8, alignment: .center)
                        .font(Font.caption.bold())
                        .onTapGesture {
                            callback()
                        }
                default:
                    EmptyView()
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color)
        .cornerRadius(20)
    }
}

struct BadgeViewContentView: View {
    
    @State var filters: [String] = [
    "SwiftUI", "Programming", "iOS", "Mobile Development", "😎"
    ]
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            HStack {
                ForEach(filters, id: \.self) { filter in
                    Badge(name: filter, color: Color(red: 228/255, green: 237/255, blue: 254/255), type: .removable({
                        withAnimation {
                            self.filters.removeAll { $0 == filter }
                        }
                    }))
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    BadgeViewContentView()
}
