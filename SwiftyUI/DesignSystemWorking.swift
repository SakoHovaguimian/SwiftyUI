//
//  DesignSystemWorking.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 4/3/25.
//

import SwiftUI

// MARK: - Theme Model

protocol ThemeType: Identifiable, Equatable {
    var id: String { get }
    var accentColor: Color { get }
    var accentColorSecondary: Color { get }
    var background: CustomTheme.Background { get }
    var textColor: CustomTheme.TextColor { get }
    var spacing: CustomTheme.Spacing { get }
    var radius: CustomTheme.Radius { get }
    var fonts: CustomTheme.Fonts { get }
}

struct CustomTheme: Equatable, Identifiable, ThemeType {
    
    static func == (lhs: CustomTheme, rhs: CustomTheme) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let accentColor: Color
    let accentColorSecondary: Color
    let background: Background
    let textColor: TextColor
    let spacing: Spacing
    let radius: Radius
    let fonts: Fonts

    struct Background {
        let primary: Color
        let secondary: Color
        let tertiary: Color
        let quad: Color
        
        func value(for key: BackgroundKey) -> Color {
            switch key {
            case .primary: return primary
            case .secondary: return secondary
            case .tertiary: return tertiary
            case .quad: return quad
            }
        }
    }

    struct TextColor {
        let title: Color
        let titleInverted: Color
        let body: Color
        let bodyInverted: Color
        
        func value(for key: TextColorKey) -> Color {
            switch key {
            case .title: return title
            case .titleInverted: return titleInverted
            case .body: return body
            case .bodyInverted: return bodyInverted
            }
        }
    }

    struct Spacing {
        let extraSmall: CGFloat
        let small: CGFloat
        let small2: CGFloat
        let medium: CGFloat
        let medium2: CGFloat
        let large: CGFloat
        let extraLarge: CGFloat

        func value(for key: SpacingKey) -> CGFloat {
            switch key {
            case .extraSmall: return extraSmall
            case .small: return small
            case .small2: return small2
            case .medium: return medium
            case .medium2: return medium2
            case .large: return large
            case .extraLarge: return extraLarge
            case .custom(let value): return value
            }
        }
    }

    struct Radius {
        let extraSmall: CGFloat
        let small: CGFloat
        let small2: CGFloat
        let medium: CGFloat
        let medium2: CGFloat
        let large: CGFloat
        let extraLarge: CGFloat

        func value(for key: RadiusKey) -> CGFloat {
            switch key {
            case .extraSmall: return extraSmall
            case .small: return small
            case .small2: return small2
            case .medium: return medium
            case .medium2: return medium2
            case .large: return large
            case .extraLarge: return extraLarge
            case .custom(let value): return value
            }
        }
    }

    struct Fonts {
        let title: Font
        let subtitle: Font
        let body: Font
        let caption: Font

        func value(for key: FontKey) -> Font {
            switch key {
            case .title: return title
            case .subtitle: return subtitle
            case .body: return body
            case .caption: return caption
            }
        }
    }
    
    enum BackgroundKey {
        case primary, secondary, tertiary, quad
    }

    enum SpacingKey {
        case extraSmall, small, small2, medium, medium2, large, extraLarge
        case custom(CGFloat)
    }

    enum RadiusKey {
        case extraSmall, small, small2, medium, medium2, large, extraLarge
        case custom(CGFloat)
    }

    enum FontKey {
        case title, subtitle, body, caption
    }
    
    enum TextColorKey {
        case title, titleInverted, body, bodyInverted
    }
}

// MARK: - Default Theme

extension CustomTheme {
    static let `default` = CustomTheme(
        id: "DEFAULT",
        accentColor: .blue,
        accentColorSecondary: .cyan,
        background: .init(
            primary: Color(uiColor: .systemGray6),
            secondary: Color(.secondarySystemBackground),
            tertiary: Color(.tertiarySystemBackground),
            quad: Color(.quaternarySystemFill)
        ),
        textColor: .init(
            title: .primary,
            titleInverted: .white,
            body: .gray,
            bodyInverted: .gray
        ),
        spacing: .default,
        radius: .default,
        fonts: .init(
            title: .system(size: 28, weight: .bold),
            subtitle: .system(size: 20, weight: .medium),
            body: .system(size: 16, weight: .regular),
            caption: .system(size: 12, weight: .light)
        )
    )

    static let alternate = CustomTheme(
        id: "ALTERNATE",
        accentColor: .orange,
        accentColorSecondary: .pink,
        background: .init(
            primary: .black,
            secondary: .gray,
            tertiary: .darkBlue,
            quad: .init(white: 0.1)
        ),
        textColor: .init(
            title: .white,
            titleInverted: .black,
            body: .init(white: 0.8),
            bodyInverted: .init(white: 0.2)
        ),
        spacing: .default,
        radius: .default,
        fonts: .init(
            title: .system(size: 20, weight: .semibold),
            subtitle: .system(size: 18, weight: .medium),
            body: .system(size: 15, weight: .regular),
            caption: .system(size: 11, weight: .light)
        )
    )
}

extension CustomTheme.Spacing {
    static let `default` = CustomTheme.Spacing(
        extraSmall: 4, small: 8, small2: 12, medium: 16,
        medium2: 20, large: 24, extraLarge: 32
    )
}

extension CustomTheme.Radius {
    static let `default` = CustomTheme.Radius(
        extraSmall: 2, small: 4, small2: 6, medium: 8,
        medium2: 10, large: 12, extraLarge: 16
    )
}

// MARK: - DesignSystem & Environment

protocol DesignSystemProviding: AnyObject {
    var theme: any ThemeType { get }
    func toggleTheme()
    func background(_ key: CustomTheme.BackgroundKey) -> Color
    func spacing(_ key: CustomTheme.SpacingKey) -> CGFloat
    func radius(_ key: CustomTheme.RadiusKey) -> CGFloat
    func font(_ key: CustomTheme.FontKey) -> Font
    func textColor(_ key: CustomTheme.TextColorKey) -> Color
    var accent: Color { get }
}

@Observable
class DesignSystemProvider: DesignSystemProviding {
    
    var theme: any ThemeType = CustomTheme.default

    func toggleTheme() {
        theme = (theme.id == "DEFAULT") ? CustomTheme.alternate : CustomTheme.default
    }
    
    func background(_ key: CustomTheme.BackgroundKey) -> Color {
        theme.background.value(for: key)
    }

    func spacing(_ key: CustomTheme.SpacingKey) -> CGFloat {
        theme.spacing.value(for: key)
    }

    func radius(_ key: CustomTheme.RadiusKey) -> CGFloat {
        theme.radius.value(for: key)
    }

    func font(_ key: CustomTheme.FontKey) -> Font {
        theme.fonts.value(for: key)
    }

    func textColor(_ key: CustomTheme.TextColorKey) -> Color {
        theme.textColor.value(for: key)
    }

    var accent: Color { theme.accentColor }
    var titleColor: Color { theme.textColor.title }
    
}

struct DesignSystemKey: EnvironmentKey {
    static let defaultValue = DesignSystemProvider()
}

extension EnvironmentValues {
    var designSystem: DesignSystemProvider {
        get { self[DesignSystemKey.self] }
        set { self[DesignSystemKey.self] = newValue }
    }
}

// MARK: - Demo View

struct ThemeDemoView: View {
    @Environment(\.designSystem) private var theme

    var body: some View {
        VStack(spacing: theme.spacing(.medium)) {
            Text("Design System Theme")
                .font(theme.font(.title))
                .foregroundStyle(theme.theme.textColor.title)
                .contentTransition(.interpolate)

            Button("Toggle Theme") {
                theme.toggleTheme()
            }
            .padding(theme.spacing(.small))
            .background(theme.accent)
            .clipShape(.rect(cornerRadius: theme.radius(.small2)))
            .foregroundColor(.white)
            .contentTransition(.interpolate)
        }
        .padding(theme.spacing(.large))
        .background(theme.background(.primary))
        .clipShape(.rect(cornerRadius: theme.radius(.medium2)))
        .compositingGroup()
        .contentTransition(.interpolate)
        .animation(.easeOut(duration: 1.2), value: self.theme.theme.id)
    }
}

// MARK: - Entry

@main
struct ThemeApp: App {
    @State private var designSystem = DesignSystemProvider()

    var body: some Scene {
        
        WindowGroup {
            
            ThemeDemoView()
                .environment(\.designSystem, designSystem)
            
        }
        
    }
}
