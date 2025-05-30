//
//  Gestures.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 5/31/25.
//

import SwiftUI

// MARK: - Shape Model
enum ShapeType: String, CaseIterable {
    case rectangle, circle, star, arrow
}

struct ShapeModel: Identifiable {
    let id = UUID()
    var type: ShapeType
    var position: CGPoint
    var size: CGSize = .init(width: 100, height: 100)
    var color: Color = .blue
    var hasShadow: Bool = false
    var scale: CGFloat = 1.0
    var lastScale: CGFloat = 1.0
    var rotation: Angle = .zero
}

// MARK: - Corner Actions
enum CornerAction {
    case none, move, scale, rotate, tap
}

// MARK: - PhotoEditorView
struct PhotoEditorView: View {
    @State private var shapes: [ShapeModel] = []
    @State private var selectedShapeID: UUID?
    @State private var activeAction: CornerAction = .none


    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Canvas background
                Color.gray.opacity(0.2).ignoresSafeArea()

                // -- Drawing Area --
                ZStack {

                    ForEach($shapes) { $shape in
                        shapeView($shape)
                            .frame(width: shape.size.width, height: shape.size.height)
                            .scaleEffect(shape.scale)
                            .rotationEffect(shape.rotation)
                            .position(shape.position)
                            // Only apply gestures to selected shape
                            .gesture(selectedShapeID == shape.id && activeAction == .move ? dragGesture(shape: $shape) : nil)
                            .simultaneousGesture(selectedShapeID == shape.id && activeAction == .scale ? pinchGesture(shape: $shape) : nil)
                            .simultaneousGesture(selectedShapeID == shape.id && activeAction == .rotate ? rotateGesture(shape: $shape) : nil)
                            .onTapGesture {
                                selectedShapeID = shape.id
                                activeAction = .none
                            }
                    }
                }
                .frame(maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    
                    VStack {
                        Spacer()
                        
                        if let sid = selectedShapeID,
                           let idx = shapes.firstIndex(where: { $0.id == sid }) {
                            VStack(spacing: 16) {
                                // Color/Shadow Inspector
                                VStack(spacing: 12) {
                                    ColorPicker("Fill Color", selection: $shapes[idx].color)
                                    Toggle("Shadow", isOn: $shapes[idx].hasShadow)
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .padding(.horizontal, .large)
                                
                                // Gesture Handle Bar
                                HStack(spacing: 40) {
                                    handleButton(icon: "hand.draw.fill", action: .move)
                                    handleButton(icon: "arrow.up.left.and.arrow.down.right", action: .scale)
                                    handleButton(icon: "rotate.right.fill", action: .rotate)
                                    handleButton(icon: "circle", action: .tap)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(.ultraThinMaterial)
                                .cornerRadius(16)
                            }
                            .transition(.move(edge: .bottom))
                        }
                        
                        // -- Top Menu for Adding Shapes --
                        VStack {
                            HStack {
                                Menu {
                                    ForEach(ShapeType.allCases, id: \.self) { type in
                                        Button(type.rawValue.capitalized) {
                                            let center = CGPoint(x: geo.size.width/2, y: geo.size.height/2)
                                            shapes.append(.init(type: type, position: center))
                                        }
                                    }
                                } label: {
                                    Label("Shapes", systemImage: "rectangle.on.rectangle.angled")
                                }
                                .padding()
                            }
                        }
                        
                    }
                    }

            }
            // Deselect on canvas tap
            .contentShape(Rectangle())
            .onTapGesture {
                selectedShapeID = nil
                activeAction = .none
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    // MARK: - Gesture Factories
    private func dragGesture(shape: Binding<ShapeModel>) -> some Gesture {
        DragGesture()
            .onChanged { v in shape.wrappedValue.position = v.location }
            .onEnded { _ in }
    }

    private func pinchGesture(shape: Binding<ShapeModel>) -> some Gesture {
        MagnificationGesture()
            .onChanged { m in
                // scale relative to lastScale
                shape.wrappedValue.scale = (shape.wrappedValue.lastScale * m)
                    .clamped(to: 0.5...5.0)
            }
            .onEnded { _ in
                // commit scale
                shape.wrappedValue.lastScale = shape.wrappedValue.scale
            }
    }

    private func rotateGesture(shape: Binding<ShapeModel>) -> some Gesture {
        RotationGesture()
            .onChanged { r in shape.wrappedValue.rotation = r }
            .onEnded { _ in }
    }

    // MARK: - Helper Views
    @ViewBuilder
    private func shapeView(_ shape: Binding<ShapeModel>) -> some View {
        let m = shape.wrappedValue
        Group {
            switch m.type {
            case .rectangle: Rectangle()
            case .circle:    Circle()
            case .star:      Image(systemName: "star.fill").resizable().aspectRatio(1, contentMode: .fit)
            case .arrow:     Image(systemName: "arrow.up.right").resizable().aspectRatio(contentMode: .fit)
            }
        }
        .foregroundStyle(m.color)
        .shadow(color: .black.opacity(m.hasShadow ? 0.4 : 0), radius: m.hasShadow ? 5 : 0)
        .border(shape.id == selectedShapeID ? Color.red : .clear, width: 2)
    }

    @ViewBuilder
    private func handleButton(icon: String, action: CornerAction) -> some View {
        Image(systemName: icon)
            .font(.title2)
            .foregroundColor(activeAction == action ? .accentColor : .primary)
            .onTapGesture {
                activeAction = (activeAction == action ? .none : action)
            }
    }
}

// MARK: - Preview
struct PhotoEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoEditorView()
    }
}

import SwiftUI

// MARK: - Comparable Clamping Helper
extension Comparable {
    /// Clamps the value to the given closed range.
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// MARK: - Draggable Modifier
struct Draggable: ViewModifier {
    @State private var translation: CGSize = .zero
    @State private var lastTranslation: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .offset(x: translation.width, y: translation.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        translation = CGSize(
                            width: lastTranslation.width + value.translation.width,
                            height: lastTranslation.height + value.translation.height
                        )
                    }
                    .onEnded { _ in
                        lastTranslation = translation
                    }
            )
    }
}

extension View {
    /// Makes the view draggable.
    func draggable() -> some View {
        modifier(Draggable())
    }
}

// MARK: - Scalable Modifier
struct Scalable: ViewModifier {
    let minScale: CGFloat
    let maxScale: CGFloat

    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        // Combine the current gesture magnitude with last state
                        let newScale = (scale * value).clamped(to: minScale...maxScale)
                        scale = newScale
                    }
                    .onEnded { _ in
                        withAnimation {
                            scale = scale.clamped(to: minScale...maxScale)
                        }
                    }
            )
    }
}

extension View {
    /// Allows pinch-to-zoom scaling within provided bounds.
    /// - Parameters:
    ///   - minScale: Minimum allowed scale factor.
    ///   - maxScale: Maximum allowed scale factor.
    func scalable(minScale: CGFloat = 1.0, maxScale: CGFloat = 5.0) -> some View {
        modifier(Scalable(minScale: minScale, maxScale: maxScale))
    }
}

// MARK: - Rotatable Modifier
struct Rotatable: ViewModifier {
    @State private var rotation: Angle = .zero

    func body(content: Content) -> some View {
        content
            .rotationEffect(rotation)
            .gesture(
                RotationGesture()
                    .onChanged { value in
                        rotation = value
                    }
                    .onEnded { _ in
                        // Optionally snap to increments or clamp here
                    }
            )
    }
}

extension View {
    /// Enables rotation gesture on the view.
    func rotatable() -> some View {
        modifier(Rotatable())
    }
}
