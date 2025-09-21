//
//  PopInToast.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/20/25.
//

import SwiftUI

// MARK: - Protocol

public protocol PopInToast: Identifiable, Hashable {
    
    // Identity
    var id: UUID { get }
    
    // Content
    var title: String { get }
    var subtitle: String? { get }
    var icon: Image? { get }
    
    // Behavior
    var duration: TimeInterval { get }            // controls how long THIS item stays visible
    var allowsHitTesting: Bool { get }            // item-level hit testing control
    
    // Style (defaults provided below)
    var backgroundStyle: AnyShapeStyle { get }
    var foregroundStyle: AnyShapeStyle { get }
    var titleFont: Font { get }
    var subtitleFont: Font { get }
    var titleColor: Color? { get }                // prioritized if provided
    var subtitleColor: Color? { get }
    var clipShape: AnyShape { get }               // rounded, capsule, etc.
    var horizontalPadding: CGFloat { get }
    var verticalPadding: CGFloat { get }
}

// MARK: - Defaults

public extension PopInToast {
    
    var id: UUID { UUID() }
    
    var duration: TimeInterval { 1.5 }
    var allowsHitTesting: Bool { false }
    
    var backgroundStyle: AnyShapeStyle { AnyShapeStyle(.thinMaterial) }
    var foregroundStyle: AnyShapeStyle { AnyShapeStyle(.primary) }
    
    var titleFont: Font { .callout.weight(.semibold) }
    var subtitleFont: Font { .footnote }
    
    var titleColor: Color? { nil }
    var subtitleColor: Color? { nil }
    
    var clipShape: AnyShape { AnyShape(Capsule()) }
    var horizontalPadding: CGFloat { 16 }
    var verticalPadding: CGFloat { 10 }
}

// MARK: - View Modifier (Protocol + Builder)

struct PopInToastModifier<Item: PopInToast, ToastContent: View>: ViewModifier {
    
    @Binding private var items: [Item]
    @State private var currentIndex: Int? = nil
    
    private let alignment: Alignment
    private let transition: AnyTransition
    @ViewBuilder private let contentBuilder: (Item) -> ToastContent
    
    init(items: Binding<[Item]>,
         alignment: Alignment = .top,
         transition: AnyTransition = .scale.combined(with: .opacity),
         @ViewBuilder content: @escaping (Item) -> ToastContent) {
        
        self._items        = items
        self.alignment     = alignment
        self.transition    = transition
        self.contentBuilder = content
    }
    
    func body(content: Content) -> some View {
        
        content
            .overlay(alignment: self.alignment) {
                
                presentedToastView()
                    .onChange(of: self.items) { _, newValue in
                        
                        guard self.currentIndex == nil,
                              let last = newValue.indices.last else { return }
                        
                        withAnimation(.bouncy) {
                            self.currentIndex = last
                        }
                    }
                    .zIndex(1)
                    .animation(.bouncy, value: self.currentIndex)
                    // item-specific hit testing is applied to the toast itself below
            }
    }
    
    @ViewBuilder
    private func presentedToastView() -> some View {
        
        if let index = self.currentIndex,
           self.items.indices.contains(index) {
            
            let item = self.items[index]
            
            contentBuilder(item)
                .allowsHitTesting(item.allowsHitTesting)
                .task(id: self.currentIndex) {
                    
                    // 1) Keep visible per-item duration
                    try? await Task.sleep(nanoseconds: UInt64(item.duration * 1_000_000_000))
                    
                    // 2) Hide (animate out)
                    withAnimation(.bouncy) {
                        self.currentIndex = nil
                    }
                    
                    // 3) Allow exit transition to settle, then advance if another exists
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    
                    let next = index + 1
                    
                    if self.items.indices.contains(next) {
                        withAnimation(.bouncy) {
                            self.currentIndex = next
                        }
                    }
                }
                .transition(self.transition)
        }
    }
}

// MARK: - Default Builder

private struct DefaultToastView<Item: PopInToast>: View {
    
    let item: Item
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = item.icon {
                icon.imageScale(.medium)
            }
            
            VStack(alignment: .leading, spacing: item.subtitle == nil ? 0 : 2) {
                Text(item.title)
                    .font(item.titleFont)
                    .foregroundStyle(item.titleColor ?? Color.primary)
                
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(item.subtitleFont)
                        .foregroundStyle(item.subtitleColor ?? Color.secondary)
                }
            }
        }
        .padding(.horizontal, item.horizontalPadding)
        .padding(.vertical, item.verticalPadding)
        .background(item.backgroundStyle, in: item.clipShape)
        .foregroundStyle(item.foregroundStyle)
        .shadow(radius: 8)
    }
}

// MARK: - View Extension

extension View {
    
    /// Fully custom: provide your own `@ViewBuilder` that takes an `Item: PopInToast`
    /// and returns a view for complete control per item.
    func popInToast<Item: PopInToast, ToastContent: View>(items: Binding<[Item]>,
                                                          alignment: Alignment = .top,
                                                          transition: AnyTransition = .scale.combined(with: .opacity),
                                                          @ViewBuilder content: @escaping (Item) -> ToastContent) -> some View {
        
        self.modifier(
            PopInToastModifier(
                items: items,
                alignment: alignment,
                transition: transition,
                content: content
            )
        )
    }
    
    /// Convenience: use the default renderer derived from `PopInToast` styling.
    func popInToast<Item: PopInToast>(items: Binding<[Item]>,
                                      alignment: Alignment = .top,
                                      transition: AnyTransition = .scale.combined(with: .opacity)) -> some View {
        
        self.modifier(
            PopInToastModifier(
                items: items,
                alignment: alignment,
                transition: transition,
                content: { item in
                    DefaultToastView(item: item)
                }
            )
        )
    }
}

// MARK: - Example Item

struct BasicToast: PopInToast {
    
    static func == (lhs: BasicToast, rhs: BasicToast) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id = UUID()
    
    let title: String
    let subtitle: String?
    let icon: Image?
    
    let duration: TimeInterval
    let allowsHitTesting: Bool
    
    // Style (override any default)
    var backgroundStyle: AnyShapeStyle = AnyShapeStyle(.ultraThinMaterial)
    var foregroundStyle: AnyShapeStyle = AnyShapeStyle(.red)
    var titleFont: Font = .callout.weight(.semibold)
    var subtitleFont: Font = .footnote
    var titleColor: Color? = nil
    var subtitleColor: Color? = nil
    var clipShape: AnyShape = AnyShape(Capsule())
    var horizontalPadding: CGFloat = 16
    var verticalPadding: CGFloat = 10
    
    init(title: String,
         subtitle: String? = nil,
         icon: Image? = nil,
         duration: TimeInterval = 1.5,
         allowsHitTesting: Bool = false) {
        
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.duration = duration
        self.allowsHitTesting = allowsHitTesting
    }
}

// MARK: - Preview

#Preview {
    
    @Previewable @State var items: [BasicToast] = []
    
    VStack(spacing: 24) {
        Text("Tap anywhere").font(.title)
        Text("Top uses default renderer • Center uses custom renderer")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    
    // Default rendering based on the item's own styles
    .popInToast(items: $items, alignment: .top)
    
    // Custom rendering via builder
    .popInToast(items: $items, alignment: .center) { item in
        HStack(spacing: 10) {
            (item.icon ?? Image(systemName: "sparkles"))
                .imageScale(.medium)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(item.titleColor ?? .white)
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(item.subtitleColor ?? .white.opacity(0.9))
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            AnyShapeStyle(.regularMaterial),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .shadow(radius: 10)
    }
    .onTapGesture {
        let id = String(UUID().uuidString.prefix(6))
        items.append(
            BasicToast(
                title: "Saved \(id)",
                subtitle: Bool.random() ? "All set 🎉" : nil,
                icon: Image(systemName: Bool.random() ? "checkmark.seal.fill" : "sparkles"),
                duration: [1.0, 1.5, 2.0, 2.5].randomElement()!,
                allowsHitTesting: false
            )
        )
    }
}

// OLD SIMPLE WAY
////
////  PopInView.swift
////  GlowPro
////
////  Created by Sako Hovaguimian on 9/20/25.
////
//
//import SwiftUI
//
//struct PopInViewModifier: ViewModifier {
//    
//    @Binding private var strings: [String]
//    @State private var currentIndex: Int? = nil
//    
//    private let duration: TimeInterval
//    private let alignment: Alignment
//    private let transition: AnyTransition
//    
//    init(strings: Binding<[String]>,
//         duration: TimeInterval = 1.5,
//         alignment: Alignment = .top,
//         transition: AnyTransition = .scale.combined(with: .opacity)) {
//        
//        self._strings = strings
//        self.duration = duration
//        self.alignment = alignment
//        self.transition = transition
//    }
//    
//    func body(content: Content) -> some View {
//        
//        content
//            .overlay(alignment: self.alignment) {
//                
//                presentedStringView()
//                    .onChange(of: self.strings) { _, newValue in
//                        
//                        guard self.currentIndex == nil,
//                              let last = newValue.indices.last else { return }
//                        
//                        withAnimation(.bouncy) {
//                            self.currentIndex = last
//                        }
//                        
//                    }
//                    .zIndex(1)
//                    .animation(.bouncy, value: self.currentIndex)
//                    .allowsHitTesting(false)
//            }
//    }
//    
//    @ViewBuilder
//    private func presentedStringView() -> some View {
//        
//        if let index = self.currentIndex,
//           self.strings.indices.contains(index) {
//            
//            let presentedString = self.strings[index]
//            
//            TokenView(
//                text: presentedString,
//                foregroundStyle: Style.shared.textColor(.button),
//                backgroundStyle: Style.shared.accent,
//                horizontalPadding: .custom(64),
//                verticalPadding: .medium,
//                clipShape: .init(.rect(cornerRadius: Style.shared.radius(.extraSmall)))
//            )
//            .task(id: self.currentIndex) {
//                
//                // Show for `duration`, then hide (transition out), then (optionally) advance.
//                try? await Task.sleep(nanoseconds: UInt64(self.duration * 1_000_000_000))
//                
//                // 1) Hide to trigger exit transition
//                withAnimation(.bouncy) {
//                    self.currentIndex = nil
//                }
//                
//                // 2) After the exit transition settles, move to the next index if it exists
//                try? await Task.sleep(nanoseconds: 300_000_000) // ~0.3s to match your timing
//                
//                let next = index + 1
//                
//                if self.strings.indices.contains(next) {
//                    
//                    withAnimation(.bouncy) {
//                        self.currentIndex = next
//                    }
//                    
//                }
//                
//            }
//            .transition(self.transition)
//            
//        }
//        
//    }
//    
//}
//
//extension View {
//    
//    func popInToast(strings: Binding<[String]>,
//                    duration: TimeInterval = 1.5,
//                    alignment: Alignment = .top,
//                    transition: AnyTransition = .scale.combined(with: .opacity)) -> some View {
//        
//        self.modifier(
//            PopInViewModifier(
//                strings: strings,
//                duration: duration,
//                alignment: alignment,
//                transition: transition
//            )
//        )
//    }
//}
//
//#Preview {
//    
//    @Previewable @State var strings: [String] = []
//    
//    AppBaseView {
//        Text("Screen")
//    }
//    .popInToast(
//        strings: $strings,
//        alignment: .center
//    )
//    .onTapGesture {
//        strings.append(String(UUID().uuidString.prefix(8)))
//    }
//    
//}
//
