//
//  ChecklistView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 11/23/23.
//

import SwiftUI

// TODO: -
/// Remove tap gesture
/// Fix Font

struct ChecklistDemoView: View {
    
    var body: some View {
        
        ZStack {
            
            AppColor.background(.primary)
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                
                Text("Complete Your Profile")
                    .padding(.horizontal, .large)
                    .font(.title2)
                    .fontWeight(.heavy)
                
                CheckListView(items: [
                    .init(title: "Complete Your Profile", isCompleted: false),
                    .init(title: "Create or Join A Challenge", isCompleted: false),
                    .init(title: "Create your first Log", isCompleted: false),
                ])
                
            }
            
        }
        
    }
    
}

struct CheckListView: View {
    
    let items: [Item]
    
    struct Item {
        
        let title: String
        var isCompleted: Bool
        
    }
    
    var body: some View {
    
        VStack(spacing: 0) {
            
            ForEach(0..<self.items.count, id: \.self) { index in
                
                let item = self.items[index]
                
                ChecklistItemView(
                    item: item,
                    isLastItem: (self.items.last?.title == item.title)
                )
                
            }
            
        }
        .padding(.vertical, .large)
        .padding(.horizontal, .medium)
        .background(AppColor.background(.secondary))
        .clipShape(.rect(cornerRadius: CornerRadius.medium.rawValue))
        .padding(.horizontal, .large)
        .appShadow()
        
    }
    
}

fileprivate struct ChecklistItemView: View {
    
    @State var item: CheckListView.Item!
    var isLastItem: Bool
    
    var body: some View {
        
        let isCompleted = self.item.isCompleted
        
        ZStack(alignment: .topLeading) {
            
            if !self.isLastItem {
                
                let width: CGFloat = 5
                
                Rectangle()
                    .fill(isCompleted ? AppColor.brandGreen : AppColor.background(.quad))
                    .frame(width: width, height: 60)
                    .padding(.horizontal, 18.5)
                    .animation(.easeInOut(duration: 1.5), value: isCompleted)
                
            }
            
            HStack(spacing: Spacing.medium.value) {
                
                itemStatusView()
                
                Text(self.item.title)
                    .appFont(with: .heading(.h5))
                    .fontWeight(isCompleted ? .heavy : .medium)
                    .fontDesign(.rounded)
                    .animation(.spring, value: isCompleted)
                
                Spacer()
                
            }
            
        }
        
    }
        
    @ViewBuilder 
    func itemStatusView() -> some View {
        
        let isCompleted = self.item.isCompleted
        
        ZStack {
            
            Circle()
                .frame(width: 42, height: 42)
                .foregroundStyle(isCompleted ? AppColor.brandGreen : AppColor.background(.quad))
            
            Image(systemName: "checkmark")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(isCompleted ? .black : .clear)
            .fontWeight(isCompleted ? .bold : .ultraLight)
            .opacity(isCompleted ? 1 : 0)
            .scaleEffect(isCompleted ? 1 : 0.3)
            .animation(.spring(.bouncy), value: isCompleted)
            
        }
        
    }
}

#Preview {
    
    ChecklistDemoView()
    
}

#Preview {
    
    CheckListView(items: [
        .init(title: "Complete Your Profile", isCompleted: false),
        .init(title: "Create or Join A Challenge", isCompleted: true),
        .init(title: "Create your first Log", isCompleted: true),
    ])
    
}

