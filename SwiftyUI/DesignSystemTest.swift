//import SwiftUI
//// MARK: - Keys
//
//enum CustomThemeKey {
//    enum BackgroundKey { case primary, secondary, tertiary, quad }
//    enum SpacingKey { case extraSmall, small, small2, medium, medium2, large, extraLarge, custom(CGFloat) }
//    enum RadiusKey { case extraSmall, small, small2, medium, medium2, large, extraLarge, custom(CGFloat) }
//    enum FontKey { case title, subtitle, body, caption }
//    enum TextKey { case title, titleInverted, body, bodyInverted }
//}
//
//// MARK: - Codable Raw Theme
//
//struct CustomThemeStyle: Codable, Equatable, Identifiable {
//    
//    static func == (lhs: CustomThemeStyle, rhs: CustomThemeStyle) -> Bool {
//        lhs.id == rhs.id
//    }
//    
//    let id: String
//    let accentColorHex: String
//    let accentColorSecondaryHex: String
//    let background: Background
//    let text: Text
//    let spacing: Spacing
//    let radius: Radius
//    let fonts: Fonts
//
//    struct Background: Codable {
//        let primaryHex: String
//        let secondaryHex: String
//        let tertiaryHex: String
//        let quadHex: String
//    }
//
//    struct Text: Codable {
//        let titleHex: String
//        let titleInvertedHex: String
//        let bodyHex: String
//        let bodyInvertedHex: String
//    }
//
//    struct Spacing: Codable {
//        let extraSmall: CGFloat
//        let small: CGFloat
//        let small2: CGFloat
//        let medium: CGFloat
//        let medium2: CGFloat
//        let large: CGFloat
//        let extraLarge: CGFloat
//    }
//
//    struct Radius: Codable {
//        let extraSmall: CGFloat
//        let small: CGFloat
//        let small2: CGFloat
//        let medium: CGFloat
//        let medium2: CGFloat
//        let large: CGFloat
//        let extraLarge: CGFloat
//    }
//
//    struct Fonts: Codable {
//        struct FontStyle: Codable {
//            let name: String
//            let size: CGFloat
//            let weight: String
//        }
//
//        let title: FontStyle
//        let subtitle: FontStyle
//        let body: FontStyle
//        let caption: FontStyle
//    }
//}
//
//extension CustomThemeStyle {
//    static let `default` = CustomThemeStyle(
//        id: "DEFAULT",
//        accentColorHex: "#007AFF",
//        accentColorSecondaryHex: "#00FFFF",
//        background: .init(
//            primaryHex: "#F2F2F7",
//            secondaryHex: "#EFEFF4",
//            tertiaryHex: "#D1D1D6",
//            quadHex: "#C7C7CC"
//        ),
//        text: .init(
//            titleHex: "#000000",
//            titleInvertedHex: "#FFFFFF",
//            bodyHex: "#4A4A4A",
//            bodyInvertedHex: "#AAAAAA"
//        ),
//        spacing: .init(extraSmall: 4, small: 8, small2: 12, medium: 16, medium2: 20, large: 24, extraLarge: 32),
//        radius: .init(extraSmall: 2, small: 4, small2: 6, medium: 8, medium2: 10, large: 12, extraLarge: 16),
//        fonts: .init(
//            title: .init(name: "Helvetica-Bold", size: 28, weight: "bold"),
//            subtitle: .init(name: "Helvetica", size: 20, weight: "medium"),
//            body: .init(name: "Helvetica", size: 16, weight: "regular"),
//            caption: .init(name: "Helvetica", size: 12, weight: "light")
//        )
//    )
//
//    static let alternate = CustomThemeStyle(
//        id: "ALTERNATE",
//        accentColorHex: "#FF9500",
//        accentColorSecondaryHex: "#FF2D55",
//        background: .init(
//            primaryHex: "#000000",
//            secondaryHex: "#2C2C2E",
//            tertiaryHex: "#1C1C1E",
//            quadHex: "#3A3A3C"
//        ),
//        text: .init(
//            titleHex: "#FFFFFF",
//            titleInvertedHex: "#000000",
//            bodyHex: "#CCCCCC",
//            bodyInvertedHex: "#333333"
//        ),
//        spacing: .init(extraSmall: 4, small: 8, small2: 12, medium: 16, medium2: 20, large: 24, extraLarge: 32),
//        radius: .init(extraSmall: 2, small: 4, small2: 6, medium: 8, medium2: 10, large: 12, extraLarge: 16),
//        fonts: .init(
//            title: .init(name: "HelveticaNeue-Bold", size: 20, weight: "semibold"),
//            subtitle: .init(name: "HelveticaNeue", size: 18, weight: "medium"),
//            body: .init(name: "HelveticaNeue", size: 15, weight: "regular"),
//            caption: .init(name: "HelveticaNeue", size: 11, weight: "light")
//        )
//    )
//}
//
//// MARK: - Real SwiftUI Theme
//
//struct CustomTheme: Equatable, Identifiable {
//    
//    static func == (lhs: CustomTheme, rhs: CustomTheme) -> Bool {
//        lhs.id == rhs.id
//    }
//
//    let id: String
//    let accentColor: Color
//    let accentColorSecondary: Color
//    let background: Background
//    let text: Text
//    let spacing: Spacing
//    let radius: Radius
//    let fonts: Fonts
//
//    struct Background {
//        let primary: Color
//        let secondary: Color
//        let tertiary: Color
//        let quad: Color
//
//        func value(for key: CustomThemeKey.BackgroundKey) -> Color {
//            switch key {
//            case .primary: return primary
//            case .secondary: return secondary
//            case .tertiary: return tertiary
//            case .quad: return quad
//            }
//        }
//    }
//
//    struct Text {
//        let title: Color
//        let titleInverted: Color
//        let body: Color
//        let bodyInverted: Color
//
//        func value(for key: CustomThemeKey.TextKey) -> Color {
//            switch key {
//            case .title: return title
//            case .titleInverted: return titleInverted
//            case .body: return body
//            case .bodyInverted: return bodyInverted
//            }
//        }
//    }
//
//    struct Spacing {
//        let extraSmall: CGFloat
//        let small: CGFloat
//        let small2: CGFloat
//        let medium: CGFloat
//        let medium2: CGFloat
//        let large: CGFloat
//        let extraLarge: CGFloat
//
//        func value(for key: CustomThemeKey.SpacingKey) -> CGFloat {
//            switch key {
//            case .extraSmall: return extraSmall
//            case .small: return small
//            case .small2: return small2
//            case .medium: return medium
//            case .medium2: return medium2
//            case .large: return large
//            case .extraLarge: return extraLarge
//            case .custom(let v): return v
//            }
//        }
//    }
//
//    struct Radius {
//        let extraSmall: CGFloat
//        let small: CGFloat
//        let small2: CGFloat
//        let medium: CGFloat
//        let medium2: CGFloat
//        let large: CGFloat
//        let extraLarge: CGFloat
//
//        func value(for key: CustomThemeKey.RadiusKey) -> CGFloat {
//            switch key {
//            case .extraSmall: return extraSmall
//            case .small: return small
//            case .small2: return small2
//            case .medium: return medium
//            case .medium2: return medium2
//            case .large: return large
//            case .extraLarge: return extraLarge
//            case .custom(let v): return v
//            }
//        }
//    }
//
//    struct Fonts {
//        let title: Font
//        let subtitle: Font
//        let body: Font
//        let caption: Font
//
//        func value(for key: CustomThemeKey.FontKey) -> Font {
//            switch key {
//            case .title: return title
//            case .subtitle: return subtitle
//            case .body: return body
//            case .caption: return caption
//            }
//        }
//    }
//
//    static func from(style: CustomThemeStyle) -> CustomTheme {
//        CustomTheme(
//            id: style.id,
//            accentColor: Color(hex: style.accentColorHex),
//            accentColorSecondary: Color(hex: style.accentColorSecondaryHex),
//            background: .init(
//                primary: Color(hex: style.background.primaryHex),
//                secondary: Color(hex: style.background.secondaryHex),
//                tertiary: Color(hex: style.background.tertiaryHex),
//                quad: Color(hex: style.background.quadHex)
//            ),
//            text: .init(
//                title: Color(hex: style.text.titleHex),
//                titleInverted: Color(hex: style.text.titleInvertedHex),
//                body: Color(hex: style.text.bodyHex),
//                bodyInverted: Color(hex: style.text.bodyInvertedHex)
//            ),
//            spacing: .init(
//                extraSmall: style.spacing.extraSmall,
//                small: style.spacing.small,
//                small2: style.spacing.small2,
//                medium: style.spacing.medium,
//                medium2: style.spacing.medium2,
//                large: style.spacing.large,
//                extraLarge: style.spacing.extraLarge
//            ),
//            radius: .init(
//                extraSmall: style.radius.extraSmall,
//                small: style.radius.small,
//                small2: style.radius.small2,
//                medium: style.radius.medium,
//                medium2: style.radius.medium2,
//                large: style.radius.large,
//                extraLarge: style.radius.extraLarge
//            ),
//            fonts: .init(
//                title: .custom(style.fonts.title.name, size: style.fonts.title.size).weight(style.fonts.title.weight.toFontWeight()),
//                subtitle: .custom(style.fonts.subtitle.name, size: style.fonts.subtitle.size).weight(style.fonts.subtitle.weight.toFontWeight()),
//                body: .custom(style.fonts.body.name, size: style.fonts.body.size).weight(style.fonts.body.weight.toFontWeight()),
//                caption: .custom(style.fonts.caption.name, size: style.fonts.caption.size).weight(style.fonts.caption.weight.toFontWeight())
//            )
//        )
//    }
//}
//
//// MARK: - Helpers
//
//private extension String {
//    func toFontWeight() -> Font.Weight {
//        switch self.lowercased() {
//        case "bold": return .bold
//        case "semibold": return .semibold
//        case "medium": return .medium
//        case "light": return .light
//        default: return .regular
//        }
//    }
//}
//
//
//// MARK: - Protocol
//
//protocol NewThemeProviding: ObservableObject {
//    var currentTheme: CustomTheme { get }
//    func background(_ key: CustomThemeKey.BackgroundKey) -> Color
//    func spacing(_ key: CustomThemeKey.SpacingKey) -> CGFloat
//    func radius(_ key: CustomThemeKey.RadiusKey) -> CGFloat
//    func font(_ key: CustomThemeKey.FontKey) -> Font
//    func textColor(_ key: CustomThemeKey.TextKey) -> Color
//    var accent: Color { get }
//}
//
//// MARK: - Provider
//
//@Observable
//class DesignSystemProvider: Equatable {
//    
//    static func == (lhs: DesignSystemProvider, rhs: DesignSystemProvider) -> Bool {
//        lhs.theme == rhs.theme
//    }
//    
//    var currentStyle: CustomThemeStyle = .default {
//        didSet {
//            theme = .from(style: currentStyle)
//        }
//    }
//
//    var theme: CustomTheme = .from(style: .default)
//
//    func toggleTheme() {
//        currentStyle = (currentStyle.id == "DEFAULT") ? .alternate : .default
//    }
//
//    func background(_ key: CustomThemeKey.BackgroundKey) -> Color {
//        theme.background.value(for: key)
//    }
//
//    func spacing(_ key: CustomThemeKey.SpacingKey) -> CGFloat {
//        theme.spacing.value(for: key)
//    }
//
//    func radius(_ key: CustomThemeKey.RadiusKey) -> CGFloat {
//        theme.radius.value(for: key)
//    }
//
//    func font(_ key: CustomThemeKey.FontKey) -> Font {
//        theme.fonts.value(for: key)
//    }
//
//    func textColor(_ key: CustomThemeKey.TextKey) -> Color {
//        theme.text.value(for: key)
//    }
//
//    var accent: Color { theme.accentColor }
//}
//
//extension EnvironmentValues {
//    @Entry var designSystem: DesignSystemProvider = DesignSystemProvider()
//}
//
//// MARK: - Demo View
//
//struct ThemeDemoView: View {
//    @Environment(\.designSystem) private var theme
//
//    var body: some View {
//        VStack(spacing: theme.spacing(.medium)) {
//            Text("Design System Theme")
//                .font(theme.font(.title))
//                .foregroundStyle(theme.theme.text.title)
//                .contentTransition(.interpolate)
//
//            Button("Toggle Theme") {
//                withAnimation {
//                    theme.toggleTheme()
//                }
//            }
//            .padding(theme.spacing(.small))
//            .background(theme.accent)
//            .clipShape(.rect(cornerRadius: theme.radius(.small2)))
//            .foregroundColor(.white)
//            .transition(.slide.combined(with: .opacity))
//        }
//        .padding(theme.spacing(.large))
//        .background(theme.background(.primary))
//        .clipShape(.rect(cornerRadius: theme.radius(.medium2)))
//        .compositingGroup()
//        .contentTransition(.interpolate)
//        .animation(.easeOut(duration: 1.2), value: self.theme.theme)
//    }
//}
//
//// MARK: - Entry Point
//
//@main
//struct ThemeApp: App {
//    @State private var designSystem = DesignSystemProvider()
//
//    var body: some Scene {
//        
//        WindowGroup {
//            
//            ThemeDemoView()
//                .environment(\.designSystem, designSystem)
//            
//        }
//        
//    }
//    
//}
