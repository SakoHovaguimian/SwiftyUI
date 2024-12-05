//
//  AnimatedIntroView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/2/24.
//

import SwiftUI

public struct AnimationItem: Identifiable {
    
    public var id: String = UUID().uuidString
    var image: String
    var title: String
    
    var scale: CGFloat = 1
    var anchor: UnitPoint = .center
    var offset: CGFloat = 0
    var rotation: CGFloat = 0
    var zIndex: CGFloat = 0
    var extraOffset: CGFloat = -350
    
}

public var items: [AnimationItem] = [
    
    .init(
        image: "figure.walk.circle.fill",
        title: "Walking",
        scale: 1
    ),
    .init(
        image: "figure.run.circle.fill",
        title: "Walking",
        scale: 0.6,
        anchor: .topLeading,
        offset: -70,
        rotation: 30
    ),
    .init(
        image: "figure.badminton.circle.fill",
        title: "Walking",
        scale: 0.5,
        anchor: .bottomLeading,
        offset: -60,
        rotation: -35
    ),
    .init(
        image: "figure.climbing.circle.fill",
        title: "Walking",
        scale: 0.4,
        anchor: .bottomLeading,
        offset: -50,
        rotation: 160,
        extraOffset: -120
    ),
    .init(
        image: "figure.cooldown.circle.fill",
        title: "Walking",
        scale: 0.35,
        anchor: .bottomLeading,
        offset: -50,
        rotation: 250,
        extraOffset: -100
    )
    
]

struct AnimatedIntroView: View {
    
    @State private var selectedItem: AnimationItem = items.first!
    @State private var animationItems: [AnimationItem] = items
    @State private var activeIndex: Int = 0
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        ZStack {
            
            ForEach(self.animationItems) { item in
                animationItemView(item: item)
            }
            
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .onReceive(self.timer) { _ in
            updateItem(isForward: true)
        }
        
    }
    
    @ViewBuilder
    func animationItemView(item: AnimationItem) -> some View {
        
        let isSelected = self.selectedItem.id == item.id
        
        Image(systemName: item.image)
            .font(.system(size: 80))
            .foregroundStyle(.white.shadow(.drop(radius: 10)))
            .blendMode(.overlay)
            .frame(width: 120, height: 120)
            .background(.blue, in: .rect(cornerRadius: 32))
            .background {
                
                RoundedRectangle(cornerRadius: 35)
                    .fill(.background)
                    .shadow(color: .primary.opacity(0.2), radius: 1, x: 1, y: 1)
                    .shadow(color: .primary.opacity(0.2), radius: 1, x: -1, y: -1)
                    .padding(-3)
                    .opacity(isSelected ? 1 : 0)
                
            }
            .rotationEffect(.init(degrees: -item.rotation))
            .scaleEffect(isSelected ? 1.1 : item.scale, anchor: item.anchor)
            .offset(x: item.offset)
            .rotationEffect(.degrees(item.rotation))
            .zIndex(isSelected ? 2 : item.zIndex)
        
    }
    
    func updateItem(isForward: Bool) {
        
        var isAtEnd: Bool
        
        if isForward {
            isAtEnd = self.activeIndex == self.animationItems.count - 1
        } else {
            isAtEnd = activeIndex == 0
        }
        
        var fromIndex: Int = 0
        var extraOffset: CGFloat = 0
        
        if isForward {
            
            self.activeIndex = isAtEnd ? 0 : self.activeIndex + 1
            fromIndex = isAtEnd ? self.animationItems.count - 1 : self.activeIndex - 1
            extraOffset = animationItems[activeIndex].extraOffset
            
        } else {
            
            self.activeIndex = isAtEnd ? self.animationItems.count - 1 : self.activeIndex - 1
            extraOffset = animationItems[activeIndex].extraOffset
            fromIndex = isAtEnd ? 0 : self.activeIndex + 1
            
        }
        
        for index in animationItems.indices {
            animationItems[index].zIndex = 0
        }
        
        Task { [fromIndex, extraOffset] in
            
            withAnimation(.bouncy(duration: 1)) {
                
                self.animationItems[fromIndex].scale = animationItems[self.activeIndex].scale
                self.animationItems[fromIndex].rotation = animationItems[self.activeIndex].rotation
                self.animationItems[fromIndex].anchor = animationItems[self.activeIndex].anchor
                self.animationItems[fromIndex].offset = animationItems[self.activeIndex].offset
                self.animationItems[fromIndex].zIndex = 1
                
                self.animationItems[activeIndex].offset = extraOffset
                
            }
            
            try? await Task.sleep(for: .seconds(0.1))
            
            withAnimation(.bouncy(duration: 0.9)) {
                
                self.animationItems[self.activeIndex].scale = 1
                self.animationItems[self.activeIndex].rotation = .zero
                self.animationItems[self.activeIndex].anchor = .center
                self.animationItems[self.activeIndex].offset = .zero
                self.selectedItem = self.animationItems[self.activeIndex]
                
            }
            
        }
    
    }
    
}

#Preview {
    
    AppBaseView {
        AnimatedIntroView()
    }
    
}
