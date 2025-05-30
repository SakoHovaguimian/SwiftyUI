//
//  CardSwipe.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 5/30/25.
//

import SwiftUI

// MARK: - Model: Unwind Intention

// TODO: - Add protocol to conform objects to or have customView.self injected
// TODO: - Remove UnwinPickerSection abstraction
// TODO: - Have dynamic sizing, borderColor, rotation offset style
// TODO: - Style for remove or infinite carousel
// TODO: -

public struct UnwindIntention: Identifiable, Equatable {
    public let id: UUID
    public let title: String
    
    public init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}

// MARK: - Card Picker Section

public struct UnwindIntentCardPickerSection: View {
    @Binding private var selectedIntention: UnwindIntention
    private let intentions: [UnwindIntention]
    private let verticalPadding: CGFloat = 24
    private let bottomPadding: CGFloat = 32

    public init(
        intentions: [UnwindIntention],
        selectedIntention: Binding<UnwindIntention>
    ) {
        self.intentions = intentions
        self._selectedIntention = selectedIntention
    }

    public var body: some View {
        sectionView()
            .padding(.vertical, verticalPadding)
            .padding(.bottom, bottomPadding)
            .frame(maxWidth: .infinity)
            .animation(.easeInOut, value: selectedIntention)
    }

    // MARK: - Views

    private func sectionView() -> some View {
        UnwindIntentCardPicker(
            intentions: intentions,
            selectedIntention: $selectedIntention
        )
    }
}

// MARK: - Card Picker

public struct UnwindIntentCardPicker: View {
    @Binding private var selectedIntention: UnwindIntention
    private let intentions: [UnwindIntention]
    @State private var deck: [UnwindIntention]
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false

    private let maxVisible: Int = 5
    private let yOffsetPerCard: CGFloat = 5
    private let rotationPerCard: Double = 5.5
    private let swipeThreshold: CGFloat = 120
    private let velocityThreshold: CGFloat = 180

    public init(
        intentions: [UnwindIntention],
        selectedIntention: Binding<UnwindIntention>
    ) {
        self.intentions = intentions
        self._selectedIntention = selectedIntention
        self._deck = State(initialValue: intentions)
    }

    public var body: some View {
        cardStack()
            .contentShape(Rectangle())
            .gesture(dragGesture())
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Unwind intention picker")
    }

    // MARK: - Views

    private func cardStack() -> some View {
        ZStack {
            ForEach(Array(deck.prefix(maxVisible).enumerated()), id: \.element.id) { index, intention in
                cardView(intention: intention, at: index)
            }
        }
    }

    private func cardView(intention: UnwindIntention, at index: Int) -> some View {
        baseCard(intention)
            .offset(y: CGFloat(index) * yOffsetPerCard)
            .rotationEffect(.degrees(Double(index) * rotationPerCard))
            .scaleEffect(index == 0 ? 1 : 0.95)
            .shadow(radius: index == 0 ? 10 : 2)
            .offset(
                x: index == 0 ? dragOffset.width : 0,
                y: index == 0 ? dragOffset.height : 0
            )
            .rotationEffect(
                index == 0 ? .degrees(Double(dragOffset.width / 10)) : .zero
            )
            .zIndex(Double(maxVisible - index) + (index == 0 && isDragging ? 1 : 0))
    }

    private func baseCard(_ intention: UnwindIntention) -> some View {
        ZStack {
            cardBackground()
            cardTitle(intention.title)
        }
        .frame(width: 260, height: 380)
        .cornerRadius(24)
        .overlay(cardBorder())
    }

    private func cardBackground() -> some View {
        Image(.image2)
            .resizable()
            .scaledToFill()
            .frame(width: 260, height: 380)
            .clipped()
    }

    private func cardTitle(_ text: String) -> some View {
        Text(text)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .shadow(radius: 4)
    }

    private func cardBorder() -> some View {
        RoundedRectangle(cornerRadius: 24)
            .stroke(Color.white.opacity(0.25), lineWidth: 1)
    }

    // MARK: - Gestures

    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                dragOffset = value.translation
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    if shouldSwipe(value) {
                        performSwipe(direction: value.translation.width < 0 ? .left : .right)
                    } else {
                        dragOffset = .zero
                    }
                    isDragging = false
                }
            }
    }

    // MARK: - Helpers

    private func shouldSwipe(_ value: DragGesture.Value) -> Bool {
        abs(value.translation.width) > swipeThreshold
        || abs(value.predictedEndTranslation.width) > velocityThreshold
    }

    private func performSwipe(direction: SwipeDirection) {
        let offsetX: CGFloat = direction == .left ? -600 : 600
        dragOffset = CGSize(width: offsetX, height: 0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            deck.append(deck.removeFirst())
            dragOffset = .zero
            selectedIntention = deck.first!
        }
    }

    private enum SwipeDirection {
        case left, right
    }
}

#Preview {
    
    @Previewable @State var selectedIntention: UnwindIntention = .init(title: "1")
    
    UnwindIntentCardPickerSection(intentions: [
        .init(title: "1"),
        .init(title: "2"),
        .init(title: "3"),
        .init(title: "4"),
    ], selectedIntention: $selectedIntention)
    
}
