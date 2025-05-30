//
//  CardSwipe.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 5/30/25.
//

import SwiftUI

public struct CardSwipeView<Data: RandomAccessCollection, Card: View>: View where Data.Element: Identifiable & Equatable {
    
    public enum SwipeDirection {
        
        case left
        case right
        
    }
    
    public enum RemovalStyle {
        
        case infinite
        case remove
        
    }
    
    @Binding private var selected: Data.Element
    
    @State private var items: [Data.Element]
    @State private var drag: CGSize = .zero
    @State private var isDragging = false
    
    @ViewBuilder private let cardContent: (Data.Element) -> Card
    
    private let maxVisible: Int
    private let yOffset: CGFloat
    private let rotation: Double
    private let swipeThreshold: CGFloat
    private let velocityThreshold: CGFloat
    private let removalStyle: RemovalStyle
    private let onCompletionSwipeAction: ((SwipeDirection) -> Void)?
    
    public init(selected: Binding<Data.Element>,
                items: Data,
                maxVisible: Int = 5,
                yOffset: CGFloat = 5,
                rotation: Double = 2,
                swipeThreshold: CGFloat = 120,
                velocityThreshold: CGFloat = 180,
                removalStyle: RemovalStyle = .remove,
                onCompletionSwipeAction: ((SwipeDirection) -> Void)? = nil,
                @ViewBuilder cardContent: @escaping (Data.Element) -> Card) {
        
        self._selected = selected
        self.items = Array(items)
        self.maxVisible = maxVisible
        self.yOffset = yOffset
        self.rotation = rotation
        self.swipeThreshold = swipeThreshold
        self.velocityThreshold = velocityThreshold
        self.removalStyle = removalStyle
        self.onCompletionSwipeAction = onCompletionSwipeAction
        self.cardContent = cardContent
        
    }
    
    public var body: some View {
        
        ZStack {
            
            ForEach(Array(self.items.prefix(maxVisible).enumerated()), id: \.element.id) { index, element in
                
                buildCardContent(
                    element,
                    index: index
                )
                
            }
            
        }
        .gesture(dragGesture)
        
    }
    
    private func buildCardContent(_ element: Data.Element, index: Int) -> some View {
        
        cardContent(element)
            .offset(y: CGFloat(index) * yOffset)
            .rotationEffect(.degrees(Double(index) * rotation))
            .scaleEffect(index == 0 ? 1 : 0.95)
            .shadow(radius: index == 0 ? 10 : 2)
            .offset(
                x: index == 0 ? drag.width : 0,
                y: index == 0 ? drag.height : 0
            )
            .rotationEffect(index == 0 ? .degrees(Double(drag.width / 10)) : .zero)
            .zIndex(Double(maxVisible - index) + (index == 0 && isDragging ? 1 : 0))
            .animation(.linear, value: self.items)
            .animation(.linear, value: self.selected)
            .animation(.linear, value: self.swipeThreshold)
        
    }
    
    private var dragGesture: some Gesture {
        
        DragGesture()
          .onChanged { v in
              
              self.isDragging = true
              self.drag = v.translation
              
          }
          .onEnded { v in
              
              withAnimation(.spring) {
                  
                  if shouldSwipe(v) {
                      swipe(v.translation.width < 0 ? .left : .right)
                  } else {
                      self.drag = .zero
                  }
                  
                  self.isDragging = false
                  
              }
              
          }
        
    }
    
    private func shouldSwipe(_ v: DragGesture.Value) -> Bool {
        abs(v.translation.width) > self.swipeThreshold || abs(v.predictedEndTranslation.width) > self.velocityThreshold
    }
    
    private func swipe(_ direction: SwipeDirection) {
        
        let offsetX: CGFloat = (direction == .left) ? -600 : 600
        drag = CGSize(width: offsetX, height: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            
            switch self.removalStyle {
            case .infinite:
                
                self.items.append(self.items.removeFirst())
                self.drag = .zero
                self.selected = self.items.first!
                
            case .remove:
                
                self.items.removeFirst()
                self.drag = .zero
                self.selected = self.items.first!
            }
            
            self.onCompletionSwipeAction?(direction)
            
        }
        
    }
    
}

fileprivate struct InternalCardSwipeView: View {
    
    @Binding private var selectedItem: InternalCardItem
    private let items: [InternalCardItem]
    
    init(selectedItem: Binding<InternalCardItem>,
         items: [InternalCardItem]) {
        
        self.items = items
        self._selectedItem = selectedItem
        
    }
    
    var body: some View {
        
        VStack(spacing: Spacing.xLarge.value) {
            
            cardView(shouldRemove: true)
            cardView(shouldRemove: false)
            
        }
        
    }
    
    private func cardView(shouldRemove: Bool) -> some View {
        
        CardSwipeView(
            selected: $selectedItem,
            items: items,
            maxVisible: shouldRemove ? 5 : 3,
            rotation: shouldRemove ? 5 : 1,
            removalStyle: shouldRemove ? .remove : .infinite
        ) { item in
            
            ZStack {
                
                Image(item.image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .overlay(alignment: .bottom) {
                        
                        Text(item.title)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .shadow(radius: 4)
                            .background(.ultraThinMaterial.opacity(0.8))
                        
                    }
                
            }
            .frame(width: 280, height: 300)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            
        }
        .frame(maxWidth: .infinity)
        .animation(.bouncy, value: self.selectedItem)
        
    }
    
}

fileprivate struct InternalCardItem: Identifiable, Equatable {
    
    public let id: UUID
    public let title: String
    public let image: ImageResource
    
    public init(id: UUID = UUID(),
                title: String,
                image: ImageResource) {
        
        self.id = id
        self.title = title
        self.image = image
        
    }
    
}

#Preview {
    
    @Previewable @State var selectedCardItem: InternalCardItem = .init(title: "", image: .image1)
    
    InternalCardSwipeView(
        selectedItem: $selectedCardItem,
        items: [
            .init(title: "First", image: .image3),
            .init(title: "Second", image: .image4),
            .init(title: "Third", image: .prize),
            .init(title: "Fourth", image: .image1)
        ]
    )
    
}
