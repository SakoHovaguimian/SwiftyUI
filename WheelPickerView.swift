//
//  WheelPickerView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 11/18/25.
//

import SwiftUI

// TODO:
/// - Sounds
/// - Support horizontal WheelPickerView as well

public struct WheelPickerView<Value: Hashable, Content: View>: View {
    
    public enum WheelPickerSizeStyle {
        
        case automatic
        case fixed(CGFloat)
        
    }
    
    public struct OverlayConfig {
        
        public let strokeColor: Color
        public let strokeWidth: CGFloat
        public let clipShape: AnyShape
        public let horizontalPadding: CGFloat
        
        public init(strokeColor: Color = .black,
                    strokeWidth: CGFloat = 3.5,
                    clipShape: AnyShape = .init(.rect(cornerRadius: 12)),
                    horizontalPadding: CGFloat = 2) {
            
            self.strokeColor = strokeColor
            self.strokeWidth = strokeWidth
            self.clipShape = clipShape
            self.horizontalPadding = horizontalPadding
            
        }
        
    }
    
    @Binding private var selectedOption: Value?
    @State private var customRowHeight: CGFloat?
    
    private let options: [Value]
    private let sizingStyle: WheelPickerSizeStyle
    private let visibleRows: CGFloat
    private let overlayConfig: OverlayConfig
    private let interitemSpacing: CGFloat
    private let content: (Value, Bool) -> Content
    
    private var rowHeight: CGFloat {
        
        switch self.sizingStyle {
        case .automatic: return self.customRowHeight ?? 44
        case .fixed(let value): return value
        }
        
    }
    
    public init(selectedOption: Binding<Value?>,
                options: [Value],
                sizingStyle: WheelPickerSizeStyle = .automatic,
                visibleRows: CGFloat = 3,
                interitemSpacing: CGFloat = 16,
                overlayConfig: OverlayConfig = .init(),
                @ViewBuilder content: @escaping (Value, Bool) -> Content) {
        
        self._selectedOption = selectedOption
        self.options = options
        self.sizingStyle = sizingStyle
        self.visibleRows = visibleRows
        self.interitemSpacing = interitemSpacing
        self.overlayConfig = overlayConfig
        self.content = content
        
    }
    
    public var body: some View {
        
        // Total height of the visible area now includes spacing
        let pickerHeight = (self.rowHeight * self.visibleRows) +
                           (self.interitemSpacing * (self.visibleRows - 1))
        
        // The center overlay still only takes up one rowHeight,
        // so the vertical margins are based on that (unchanged logic).
        let verticalMargin = (pickerHeight - self.rowHeight) / 2
        
        ScrollView(.vertical) {
            
            LazyVStack(spacing: self.interitemSpacing) {
                
                ForEach(self.options, id: \.self) { option in
                    item(option)
                }
                
            }
            .scrollTargetLayout()
            
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollPosition(id: self.$selectedOption, anchor: .bottom)
        .contentMargins(.vertical, verticalMargin, for: .scrollContent)
        .frame(height: pickerHeight)
        .overlay(alignment: .center) {
            overlay()
        }
        .onChange(of: self.selectedOption) { _, _ in
            Haptics.shared.vibrate(option: .selection)
        }
        
    }
    
    @ViewBuilder
    private func item(_ option: Value) -> some View {
        
        let isSelected = (option == self.selectedOption)
        
        content(option, isSelected)
            .frame(maxWidth: .infinity)
            .onGeometryChange(for: CGFloat.self) { geo in
                geo.size.height
            } action: { newHeight in
                
                if self.customRowHeight == nil, newHeight > 0 {
                    self.customRowHeight = newHeight
                }
                
            }
            .frame(height: self.rowHeight)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .tag(option)
            .id(option)
            .animation(.smooth, value: self.selectedOption)
        
    }
    
    private func overlay() -> some View {
        
        self.overlayConfig.clipShape
            .stroke(
                self.overlayConfig.strokeColor,
                style: StrokeStyle(lineWidth: self.overlayConfig.strokeWidth),
                antialiased: true
            )
            .frame(height: self.rowHeight + 2)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, self.overlayConfig.horizontalPadding)
            .allowsHitTesting(false)
        
    }
    
}

fileprivate struct PokemonWheelExample: View {
    
    struct Pokemon: Identifiable, Hashable {
        
        let id = UUID()
        let name: String
        
    }
    
    private let options: [Pokemon] = [
        .init(name: "Charmander"),
        .init(name: "Squirtle"),
        .init(name: "Bulbasaur"),
        .init(name: "Pikachu"),
        .init(name: "Jigglypuff"),
        .init(name: "Eevee"),
        .init(name: "Vaporeon"),
        .init(name: "Jolteon"),
        .init(name: "Flareon"),
    ]
    
    @State private var selectedPokemon: Pokemon? = nil
    
    var body: some View {
        
        AppBaseView {
            
            VStack(spacing: 24) {
                
                WheelPickerView(
                    selectedOption: $selectedPokemon,
                    options: options,
                    sizingStyle: .automatic,
                    visibleRows: 3,
                    interitemSpacing: 0,
                    overlayConfig: .init(strokeColor: Color.mint, strokeWidth: 2, clipShape: .init(.rect(cornerRadius: 8)), horizontalPadding: 24),
                    
                ) { pokemon, isSelected in
                    
                    Text(pokemon.name)
                        .font(isSelected ? .subheadline : .caption)
                        .fontWeight(isSelected ? .bold : .regular)
                        .foregroundStyle(isSelected ? .mint : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
//                        .background(.white)
//                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                        .appShadow(style: .card)
                        .scaleEffect(isSelected ? 1 : 0.98)
                        .opacity(isSelected ? 1 : 0.75)
                        .animation(.bouncy, value: isSelected)
                        .overlay(alignment: .topLeading) {
                            
                            if isSelected {
                                
//                                Image(systemName: "checkmark.circle.fill")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .foregroundStyle(.mint)
//                                    .frame(width: 32, height: 32)
//                                    .padding([.top, .leading], 8)
//                                    .transition(.asymmetric(
//                                        insertion: .move(edge: .leading).combined(with: .opacity),
//                                        removal: .opacity.animation(.easeOut(duration: 0.1))
//                                    ))
                                
                            }
                            
                        }
                        .padding(.horizontal, .large)
                    
                }

            }
            .background(Color(.systemGray5).opacity(0.45))
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal, 24)
            
        }
        .onChange(of: selectedPokemon) { oldValue, newValue in
            print(newValue?.name ?? "")
        }
        .onAppear {
            self.selectedPokemon = self.options.first
        }
        
    }
    
}

#Preview {
    
    PokemonWheelExample()
    
}
