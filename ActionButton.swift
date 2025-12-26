//
//  ActionButton.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/24/25.
//

import SwiftUI

public struct ActionButton<CollapsedContent: View, ExpandedContent: View>: View {
    
    public enum Anchor: Hashable, Sendable {
        
        case top
        case topLeading
        case topTrailing
        case bottom
        case bottomLeading
        case bottomTrailing
        case center
        
        var alignment: Alignment {
            
            switch self {
            case .top: return .top
            case .topLeading: return .topLeading
            case .topTrailing: return .topTrailing
            case .bottom: return .bottom
            case .bottomLeading: return .bottomLeading
            case .bottomTrailing: return .bottomTrailing
            case .center: return .center
            }
            
        }
        
        var hiddenOffsetSigns: (x: CGFloat, y: CGFloat) {
            
            switch self {
            case .top: return (0, -1)
            case .topLeading: return (-1, -1)
            case .topTrailing: return ( 1, -1)
            case .bottom: return (0,  1)
            case .bottomLeading: return (-1,  1)
            case .bottomTrailing: return ( 1,  1)
            case .center: return (0, 0)
            }
            
        }
        
    }
    
    @Binding private var isExpanded: Bool
    @State private var collapsedOffset: CGSize = .zero

    private let anchor: Anchor
    private let animation: Animation
    private let overshoot: CGFloat
    private let collapsedContent: () -> CollapsedContent
    private let expandedContent: () -> ExpandedContent
    
    public init(isExpanded: Binding<Bool>,
                anchor: Anchor,
                animation: Animation = .bouncy(duration: 0.3, extraBounce: 0.15),
                overshoot: CGFloat = 0,
                @ViewBuilder collapsedContent: @escaping () -> CollapsedContent,
                @ViewBuilder expandedContent: @escaping () -> ExpandedContent) {
        
        self._isExpanded = isExpanded
        self.anchor = anchor
        self.animation = animation
        self.overshoot = overshoot
        self.collapsedContent = collapsedContent
        self.expandedContent = expandedContent
        
    }
    
    public var body: some View {
        
        ZStack(alignment: self.anchor.alignment) {
            
            expandedView()
            collapsedView()
            
        }
        .animation(
            self.animation,
            value: self.isExpanded
        )
        .fixedSize(
            horizontal: false,
            vertical: true
        )
        
    }
    
    private func expandedView() -> some View {
        
        self.expandedContent()
            .onGeometryChange(for: CGSize.self, of: { proxy in
                return proxy.size
            }, action: { newValue in
                self.collapsedOffset = self.collapsedHiddenOffset(size: newValue)
            })
            .scaleEffect(self.isExpanded ? 1 : 0)
            .opacity(self.isExpanded ? 1 : 0)
            .offset(
                x: self.isExpanded ? 0 : self.collapsedOffset.width,
                y: self.isExpanded ? 0 : self.collapsedOffset.height
            )
        
    }
    
    private func collapsedView() -> some View {
        
        self.collapsedContent()
            .scaleEffect(self.isExpanded ? 0 : 1)
            .opacity(self.isExpanded ? 0 : 1)
        
    }
    
    private func collapsedHiddenOffset(size: CGSize) -> CGSize {
        
        let signs = self.anchor.hiddenOffsetSigns
        
        guard signs.x != 0 || signs.y != 0 else {
            return .zero
        }
        
        let x = signs.x * (size.width + self.overshoot)
        let y = signs.y * (size.height + self.overshoot)
        
        return .init(width: x, height: y)
        
    }
    
    private func anchorPoint() -> UnitPoint {
        
        switch self.anchor {
        case .top: return .top
        case .topLeading: return .topLeading
        case .topTrailing: return .topTrailing
        case .bottom: return .bottom
        case .bottomLeading: return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        case .center: return .center
        }
        
    }
    
}

fileprivate struct ExpandedViewPreview: View {
    
    @Binding var isExpanded: Bool
    @State var includesExtraButton: Bool = false
    
    var body: some View {
        
        VStack {
            
            Capsule()
                .fill(.black.opacity(0.2))
                .frame(height: 50)
                .onTapGesture {
                    
                    print("TESTING")
                    isExpanded.toggle()
                    
                }
            
            HStack {
                
                Circle()
                    .fill(.black.opacity(0.2))
                    .frame(height: 40)
                    .onTapGesture {
                        includesExtraButton.toggle()
                    }
                
                Circle()
                    .fill(.black.opacity(0.2))
                    .frame(height: 40)
                
                Circle()
                    .fill(.black.opacity(0.2))
                    .frame(height: 40)
                
            }
            
            Capsule()
                .fill(.black.opacity(0.2))
                .frame(height: 50)
            
            if includesExtraButton {
                                
                Capsule()
                    .fill(.black.opacity(0.2))
                    .frame(height: 50)
                    .onTapGesture {
                        
                        print("TESTING")
                        isExpanded.toggle()
                        
                    }
                    .transition(.scale.combined(with: .opacity))
                
            }
            
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding(.vertical, 24)
        .padding(.horizontal, 24)
        .background(.white)
        .geometryGroup()
        .compositingGroup()
        .clipShape(.rect(cornerRadius: 32))
        .shadow(radius: 0.8)
        .animation(.bouncy(extraBounce: 0.2), value: includesExtraButton)
        
    }
    
}

#Preview("Small Test") {
    
    @Previewable @State var isExpanded: Bool = false
    @Previewable @State var includesExtraButton: Bool = false
    @Previewable let alignment: Alignment = .bottomTrailing
    
    ZStack(alignment: alignment) {
        
        Color.black.opacity(0.25).ignoresSafeArea()
        
        ActionButton(
            isExpanded: $isExpanded,
            anchor: .bottomTrailing,
        ) {
            
            Image(systemName: "eye")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .foregroundStyle(.black)
                .padding(8)
                .background(.white)
                .clipShape(.circle)
            
        } expandedContent: {
            
            ExpandedViewPreview(isExpanded: $isExpanded)
            
        }
        .padding(.trailing, .medium)
        .onTapGesture {
            isExpanded.toggle()
        }
        .animation(.smooth(duration: 0.1), value: includesExtraButton)
        
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    
}

#Preview("Large Test") {
    
    @Previewable @State var isExpanded: Bool = false
    @Previewable @State var includesExtraButton: Bool = false
    @Previewable let alignment: Alignment = .bottom
    
    ZStack(alignment: alignment) {
        
        Color.black.opacity(0.25).ignoresSafeArea()
        
        ActionButton(
            isExpanded: $isExpanded,
            anchor: .bottom,
            animation: .bouncy,
            overshoot: -128
        ) {
            
            Capsule()
                .fill(Color.blue.gradient)
                .frame(height: 50)
                .padding(.horizontal, .large)
            
        } expandedContent: {
            
//            ExpandedViewPreview(isExpanded: $isExpanded)
            
            VStack {
                
                Capsule()
                    .fill(Color.blue.gradient)
                    .frame(height: 50)
                
                Capsule()
                    .fill(Color.blue.gradient)
                    .frame(height: 50)
            
                HStack {
                    
                    Capsule()
                        .fill(Color.blue.gradient)
                        .frame(height: 50)
                    
                    Capsule()
                        .fill(Color.blue.gradient)
                        .frame(height: 50)
                    
                    Capsule()
                        .fill(Color.blue.gradient)
                        .frame(height: 50)
                    
                }
                
            }
            .padding(.horizontal, .large)
            
        }
        .onTapGesture {
            isExpanded.toggle()
        }
        .animation(.smooth(duration: 0.1), value: includesExtraButton)
        
    }
    
}
