//
//  TimelineView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/5/24.
//

import SwiftUI

// Add completion

struct VerticalTimelineView2: View {
    
    struct Animatable {
        
        var circle: Double
        var line: Double
        var pulse: Bool
        
    }
    
    struct Item: Equatable, Identifiable {
        
        let id: String = UUID().uuidString
        let title: String?
        let duration: TimeInterval
        
    }
    
    @State var items: [Item]
    @State var currentIndex: Int = -1
    
    @State var itemProgresses: [String: Animatable] = [:]
    
    var iconSize: CGFloat = 32
    var lineWidth: CGFloat = 2
    var inactiveColor: Color = Color.gray
    var activeColor: Color = Color.blue
        
    var body: some View {
        
        GeometryReader { geometry in
            
            itemListView()
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .onAppear {
                    
                    initializeProgresses()
                    startNextItem()
                    
                }
            
        }
        
    }
    
    func itemListView() -> some View {
        
        VStack(spacing: 0) {
            
            ForEach(Array(self.items.enumerated()), id: \.element.id) { index, item in
                                                
                itemView(
                    item: item,
                    index: index
                )
                
            }
            
        }
        
    }
    
    func itemView(item: Item, index: Int) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .top) {
                
                VStack(spacing: 0) {
                    
                    HStack {
                        
                        ProgressCircleView(
                            progress: itemProgresses[item.id]?.circle ?? 0,
                            inactiveColor: self.inactiveColor,
                            activeColor: self.activeColor,
                            iconSize: self.iconSize / 2,
                            shouldPulse: itemProgresses[item.id]?.pulse ?? false
                        )
                        .frame(width: self.iconSize, height: self.iconSize)
                        
                        if let title = item.title {
                            
                            VStack {
                                
                                Text(title)
                                    .fontWeight(itemProgresses[item.id]?.circle == 1 ? .bold : nil)
                                    .fontDesign(.monospaced)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            
                        }
                        
                    }
                    
                    if index < items.count - 1 {
                        
                        VStack(spacing: 0) {
                            
                            HStack {
                                
                                Circle()
                                    .fill(.clear)
                                    .frame(width: self.iconSize, height: self.iconSize)
                                    .overlay(alignment: .top) {
                                        
                                        LineView(
                                            activeColor: self.activeColor,
                                            progress: itemProgresses[item.id]?.line ?? 0
                                        )
                                        
                                    }
                                
                                Spacer(minLength: 0)
                                
                            }
                            
                            Spacer(minLength: 0)
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: self.iconSize)
                    
                    }
                    
                }
                
            }
            
        }
        .frame(alignment: .topLeading)
        
    }
    
    func initializeProgresses() {
        
        for item in items {
            
            itemProgresses[item.id] = Animatable(
                circle: 0,
                line: 0,
                pulse: false
            )
            
        }
        
    }
    
    func startNextItem() {
        
        guard currentIndex < items.count - 1 else { return }
        
        currentIndex += 1
        let currentItem = items[currentIndex]
        let duration = currentItem.duration
        let halfDuration = duration / 2
        
        withAnimation(.easeInOut(duration: currentItem.duration)) {
            
            itemProgresses[currentItem.id]?.circle = 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + currentItem.duration, execute: {
                
                withAnimation(.bouncy(duration: halfDuration, extraBounce: 0.20)) {
                    
                    itemProgresses[currentItem.id]?.pulse = true
                    
                } completion: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        withAnimation(.easeInOut(duration: halfDuration)) {
                            itemProgresses[currentItem.id]?.line = 1
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + halfDuration) {
                        startNextItem()
                    }
                    
                }
                
            })

        }
        
    }
    
}

struct ProgressCircleView: View {
    
    var progress: Double
    var inactiveColor: Color = .gray
    var activeColor: Color = .blue
    var iconSize: CGFloat = 24
    var lineWidth: CGFloat = 4
    var shouldPulse: Bool = false
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .stroke(inactiveColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(activeColor, lineWidth: lineWidth)
                .rotationEffect(Angle(degrees: -90))
            
            if shouldPulse {
                
                Circle()
                    .fill(self.activeColor)
                    .transition(.opacity.combined(with: .blurReplace()))
                
            }
            
            if shouldPulse {
                
                let scaleFactor = self.iconSize / 1.3
                
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: scaleFactor, height: scaleFactor)
                    .foregroundStyle(.white)
                    .bold()
                    .transition(.scale.combined(with: .push(from: .bottom)))
                
            }
            
        }
        
    }
    
}

struct LineView: View {
    
    var lineLength: CGFloat = 32
    var lineWidth: CGFloat = 4
    var inactiveColor: Color = .gray
    var activeColor: Color = .brandPink
    var progress: Double = 0
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            if progress > 0 {
                
                Rectangle()
                    .fill(progress > 0 ? activeColor : inactiveColor)
                    .frame(width: lineWidth)
                    .frame(alignment: .top)
                    .transition(.move(edge: .top))
                
            } else {
                
                Rectangle()
                    .fill(inactiveColor)
                    .frame(width: lineWidth)
                    .frame(alignment: .top)
                    .transition(.move(edge: .bottom))
                
            }
            
        }
        .frame(alignment: .top)
        .clipped()
        
    }
    
}

#Preview {
    
    @Previewable @State var items: [VerticalTimelineView2.Item] = [
        .init(title: "Verifying Information", duration: 1),
        .init(title: "Creating Account", duration: 2),
        .init(title: "Generating Assets", duration: 0.5),
        .init(title: "Stealing Your Social", duration: 1),
        .init(title: "💵 Profit", duration: 0.5),
    ]
    
    VerticalTimelineView2(items: items, activeColor: .darkPurple)
        .frame(width: 350, height: 500)
    
}
