//
//  TimelineView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/5/24.
//

import SwiftUI

struct TimelineView: View {
    
    struct Item: Equatable, Identifiable {
        
        let id: String = UUID().uuidString
        let title: String?
        let duration: TimeInterval
        
    }
    
    enum Axis {
        
        case horizontal
        case vertical
        
    }
    
    @State var items: [Item]
    @State var currentIndex: Int = -1
    @State var axis: Axis = .horizontal
    @State var iconSize: CGFloat = 36
    @State var lineWidth: CGFloat = 2
    @State var inactiveColor: Color = Color.gray
    @State var activeColor: Color = Color.blue
    @State var itemProgresses: [String: (circle: Double, line: Double, pulse: Bool)] = [:]
        
    var body: some View {
        
        GeometryReader { geometry in
            
            itemListView()
                .padding(.horizontal)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .onAppear {
                    
                    initializeProgresses()
                    startNextItem()
                    
                }
            
        }
        
    }
    
    func itemListView() -> some View {
        
        VStack(spacing: 0) {
            
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                                
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
                            shouldPulse: itemProgresses[item.id]?.pulse ?? false
                        )
                        .frame(width: self.iconSize, height: self.iconSize)
                        
                        if let title = item.title {
                            
                            VStack {
                                
                                Text(title)
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
                                        LineView(progress: itemProgresses[item.id]?.line ?? 0)
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
            itemProgresses[item.id] = (circle: 0, line: 0, pulse: false)
        }
        
    }
    
    func startNextItem() {
        
        guard currentIndex < items.count - 1 else { return }
        
        currentIndex += 1
        let currentItem = items[currentIndex]
        
        withAnimation(.easeInOut(duration: 1.5)) {
            
            itemProgresses[currentItem.id]?.circle = 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                withAnimation(.bouncy(duration: 0.8, extraBounce: 0.20)) {
                    
                    itemProgresses[currentItem.id]?.pulse = true
                    
                } completion: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            itemProgresses[currentItem.id]?.line = 1
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
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
                    .fill(.blue)
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
    var activeColor: Color = .blue
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
    
    TimelineView(items: [
        .init(title: "First Item", duration: 2),
        .init(title: "Second Item", duration: 2),
        .init(title: "Third Item", duration: 2)
    ])
    .frame(width: 350, height: 500)
    .border(.red)
    
}
