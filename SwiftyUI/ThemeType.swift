//
//  ThemeType.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 4/4/25.
//


// TODO: -
/// We need to change all AppForeground / AppBackground to use Color source
/// We need to rename all of these internal types to Singular names / Not Plural

import SwiftUI

// MARK: - Theme Model

protocol ThemeType: Identifiable, Equatable {
    
    var id: String { get }
    var accentColor: AppForegroundStyle { get }
    var accentColorSecondary: AppBackgroundStyle { get }
    var background: CustomTheme.Background { get }
    var textColor: CustomTheme.TextColor { get }
    var spacing: CustomTheme.Spacing { get }
    var radius: CustomTheme.Radius { get }
    var fonts: CustomTheme.Fonts { get }
    var shadow: CustomTheme.Shadow { get }
    
}

struct CustomTheme: Equatable, Identifiable, ThemeType {
    
    static func == (lhs: CustomTheme, rhs: CustomTheme) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let accentColor: AppForegroundStyle
    let accentColorSecondary: AppBackgroundStyle
    let background: Background
    let textColor: TextColor
    let spacing: Spacing
    let radius: Radius
    let fonts: Fonts
    let shadow: Shadow

    struct Background {
        
        let primary: AppBackgroundStyle
        let secondary: AppBackgroundStyle
        let tertiary: AppBackgroundStyle
        let quaternary: AppBackgroundStyle
        
        func value(for key: BackgroundKey) -> AppBackgroundStyle {
            
            switch key {
            case .primary: return primary
            case .secondary: return secondary
            case .tertiary: return tertiary
            case .quaternary: return quaternary
            }
            
        }
        
    }

    struct TextColor {
        
        let title: AppForegroundStyle
        let titleInverted: AppForegroundStyle
        let body: AppForegroundStyle
        let bodyInverted: AppForegroundStyle
        
        func value(for key: TextColorKey) -> AppForegroundStyle {
            
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
    
    struct DecodableShadow {
        
        var color: Color
        var radius: CGFloat
        var x: CGFloat
        var y: CGFloat
        
    }
    
    struct Shadow {
        
        let card: DecodableShadow
        let subtle: DecodableShadow
        let offset: DecodableShadow
        let neon: DecodableShadow
        let hard: DecodableShadow
        let inner: DecodableShadow
        
        func value(for key: ShadowKey) -> DecodableShadow {
            
            switch key {
            case .card: return card
            case .subtle: return subtle
            case .offset: return offset
            case .neon: return neon
            case .hard: return hard
            case .inner: return inner
            }
            
        }
        
    }
    
    enum BackgroundKey {
        
        case primary
        case secondary
        case tertiary
        case quaternary
        
    }
    
    enum SpacingKey {
        
        case extraSmall
        case small
        case small2
        case medium
        case medium2
        case large
        case extraLarge
        case custom(CGFloat)
        
    }
    
    enum RadiusKey {
        
        case extraSmall
        case small
        case small2
        case medium
        case medium2
        case large
        case extraLarge
        case custom(CGFloat)
        
    }
    
    enum FontKey {
        
        case title
        case subtitle
        case body
        case caption
        
    }
    
    enum TextColorKey {
        
        case title
        case titleInverted
        case body
        case bodyInverted
        
    }
    
    enum ShadowKey {
        
        case card
        case subtle
        case offset
        case neon
        case hard
        case inner
        
    }
    
}

// MARK: - Default Theme

extension CustomTheme {
    
    static let `default` = CustomTheme(
        id: "DEFAULT",
        accentColor: .color(.blue),
        accentColorSecondary: .color(.cyan),
        background: .init(
            primary: .color(Color(uiColor: .systemGray6)),
            secondary: .color(Color(.secondarySystemBackground)),
            tertiary: .color(Color(.tertiarySystemBackground)),
            quaternary: .color(Color(.quaternarySystemFill))
        ),
        textColor: .init(
            title: .color(.primary),
            titleInverted: .color(.white),
            body: .color(.gray),
            bodyInverted: .color(.gray)
        ),
        spacing: .default,
        radius: .default,
        fonts: .init(
            title: .system(size: 28, weight: .bold),
            subtitle: .system(size: 20, weight: .medium),
            body: .system(size: 16, weight: .regular),
            caption: .system(size: 12, weight: .light)
        ),
        shadow: .init(
            card: DecodableShadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4),
            subtle: DecodableShadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2),
            offset: DecodableShadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10),
            neon: DecodableShadow(color: Color.blue.opacity(0.7), radius: 20, x: 0, y: 0),
            hard: DecodableShadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 2),
            inner: DecodableShadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        )
    )

    static let alternate = CustomTheme(
        id: "ALTERNATE",
        accentColor: .color(.orange),
        accentColorSecondary: .color(.pink),
        background: .init(
            primary: .color(.black),
            secondary: .color(.gray),
            tertiary: .color(.blue),
            quaternary: .color(.init(white: 0.1))
        ),
        textColor: .init(
            title: .color(.white),
            titleInverted: .color(.black),
            body: .color(.init(white: 0.8)),
            bodyInverted: .color(.init(white: 0.2))
        ),
        spacing: .default,
        radius: .default,
        fonts: .init(
            title: .system(size: 20, weight: .semibold),
            subtitle: .system(size: 18, weight: .medium),
            body: .system(size: 15, weight: .regular),
            caption: .system(size: 11, weight: .light)
        ),
        shadow: .init(
            card: DecodableShadow(color: Color.brandGreen.opacity(0.1), radius: 8, x: 0, y: 4),
            subtle: DecodableShadow(color: Color.brandGreen.opacity(0.05), radius: 4, x: 0, y: 2),
            offset: DecodableShadow(color: Color.brandGreen.opacity(0.2), radius: 10, x: 10, y: 10),
            neon: DecodableShadow(color: Color.brandGreen.opacity(0.7), radius: 20, x: 0, y: 0),
            hard: DecodableShadow(color: Color.brandGreen.opacity(0.25), radius: 0, x: 0, y: 2),
            inner: DecodableShadow(color: Color.brandGreen.opacity(0.3), radius: 4, x: 0, y: 2)
        )
    )
    
}

extension CustomTheme.Spacing {
    
    static let `default` = CustomTheme.Spacing(
        extraSmall: 4,
        small: 8,
        small2: 12,
        medium: 16,
        medium2: 20,
        large: 24,
        extraLarge: 32
    )
    
}

extension CustomTheme.Radius {
    
    static let `default` = CustomTheme.Radius(
        extraSmall: 2,
        small: 4,
        small2: 6,
        medium: 8,
        medium2: 10,
        large: 12,
        extraLarge: 16
    )
    
}

struct NewAppShadow: ViewModifier {
    
    let style: CustomTheme.DecodableShadow
    
    func body(content: Content) -> some View {
        
        content
            .shadow(
                color: self.style.color,
                radius: self.style.radius,
                x: self.style.x,
                y: self.style.y
            )
        
    }
    
}

extension View {
    
    @ViewBuilder
    func newAppShadow(_ shadow: CustomTheme.DecodableShadow) -> some View {
        self.modifier(NewAppShadow(style: shadow))
    }
    
}

// MARK: - DesignSystem & Environment

protocol DesignSystemProviding: AnyObject {
    
    var theme: any ThemeType { get }
    
    func toggleTheme()
    
    func background(_ key: CustomTheme.BackgroundKey) -> AppBackgroundStyle
    func spacing(_ key: CustomTheme.SpacingKey) -> CGFloat
    func radius(_ key: CustomTheme.RadiusKey) -> CGFloat
    func font(_ key: CustomTheme.FontKey) -> Font
    func textColor(_ key: CustomTheme.TextColorKey) -> AppForegroundStyle
    func shadow(_ key: CustomTheme.ShadowKey) -> CustomTheme.DecodableShadow
    
    var accent: AppForegroundStyle { get }
    var titleTextColor: AppForegroundStyle { get }
    
}

@Observable
class DesignSystemProvider: DesignSystemProviding {
    
    static let shared = DesignSystemProvider()
    
    var theme: any ThemeType = CustomTheme.default

    func toggleTheme() {
        theme = (theme.id == "DEFAULT") ? CustomTheme.alternate : CustomTheme.default
    }
    
    func background(_ key: CustomTheme.BackgroundKey) -> AppBackgroundStyle {
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

    func textColor(_ key: CustomTheme.TextColorKey) -> AppForegroundStyle {
        theme.textColor.value(for: key)
    }
    
    func shadow(_ key: CustomTheme.ShadowKey) -> CustomTheme.DecodableShadow {
        theme.shadow.value(for: key)
    }

    var accent: AppForegroundStyle { theme.accentColor }
    var titleTextColor: AppForegroundStyle { theme.textColor.title }
    
}

extension EnvironmentValues {
    @Entry var designSystem: DesignSystemProviding = DesignSystemProvider.shared
}

// MARK: - Demo View


@main
struct ThemeApp: App {
    
    @Environment(\.designSystem) private var theme
    
    var body: some Scene {
        
        WindowGroup {
            
            PullToRefreshExample(style: .arrow)
                .onFirstAppear {
                    
                    let service = MyService()
                    let monkeyService = MonkeyService()

                    monkeyService.log(message: "Did some work")
                    monkeyService.error("Something borked")
                    monkeyService.logDeinit()

                    print("COMPLETE")
                    
                }
//
//            VStack(spacing: theme.spacing(.medium)) {
//                
//                Text("Design System Theme")
//                    .font(theme.font(.title))
//                    .foregroundStyle(theme.theme.textColor.title.foregroundStyle())
//                    .contentTransition(.interpolate)
//                    .newAppShadow(theme.shadow(.hard))
//                
//                Text("Design System Theme")
//                    .font(theme.font(.title))
//                    .foregroundStyle(theme.theme.textColor.title.foregroundStyle())
//                    .contentTransition(.interpolate)
//                    .newAppShadow(theme.shadow(.inner))
//                
//                Text("Design System Theme")
//                    .font(theme.font(.title))
//                    .foregroundStyle(theme.theme.textColor.title.foregroundStyle())
//                    .contentTransition(.interpolate)
//                    .newAppShadow(theme.shadow(.neon))
//                
//                Text("Design System Theme")
//                    .font(theme.font(.title))
//                    .foregroundStyle(theme.theme.textColor.title.foregroundStyle())
//                    .contentTransition(.interpolate)
//                    .newAppShadow(theme.shadow(.offset))
//                
//                Button("Toggle Theme") {
//                    theme.toggleTheme()
//                }
//                .padding(theme.spacing(.small))
//                .background(theme.accent.foregroundStyle())
//                .clipShape(.rect(cornerRadius: theme.radius(.small2)))
//                .newAppShadow(theme.shadow(.subtle))
//                .foregroundColor(.white)
//                .contentTransition(.interpolate)
//                
//            }
//            .padding(theme.spacing(.large))
//            .background(theme.background(.primary).backgroundStyle())
//            .clipShape(.rect(cornerRadius: theme.radius(.medium2)))
//            .newAppShadow(theme.shadow(.card))
//            .compositingGroup()
//            .contentTransition(.interpolate)
//            .animation(.easeOut(duration: 1.2), value: self.theme.theme.id)
            
//            StringViewTest()
            
        }
        
    }
    
}

