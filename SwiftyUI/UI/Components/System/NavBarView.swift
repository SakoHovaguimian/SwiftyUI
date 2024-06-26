//
//  NavBarView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import SwiftUI

enum BackgroundStyle {
    
    case color(Color)
    case material(Material)
    case linearGradient(LinearGradient)
    
}

struct NavBarView: View {
    
    struct NavProperties {
        
        let title: String
        let subtitle: String?
        let leftButtonView: AnyView?
        let rightButtonView: AnyView?

        init(title: String,
             subtitle: String? = nil,
             leftButtonView: AnyView? = nil,
             rightButtonView: AnyView? = nil) {
            
            self.title = title
            self.subtitle = subtitle
            self.leftButtonView = leftButtonView
            self.rightButtonView = rightButtonView
            
        }
        
    }
    
    enum NavBarStyle {
        
        case content(AnyView)
        case standard(NavProperties)
        
    }
    
    let navBarStyle: NavBarStyle
    let backgroundStyle: BackgroundStyle
    
    init(navBarStyle: NavBarStyle,
         backgroundStyle: BackgroundStyle) {
        
        self.navBarStyle = navBarStyle
        self.backgroundStyle = backgroundStyle
        
    }
    
    init(title: String,
         subtitle: String? = nil,
         leftButtonView: AnyView? = nil,
         rightButtonView: AnyView? = nil,
         navBackgroundStyle: BackgroundStyle = .color(.white)) {
        
        self.navBarStyle = .standard(
            .init(
                title: title,
                subtitle: subtitle,
                leftButtonView: leftButtonView,
                rightButtonView: rightButtonView
            )
        )
        
        self.backgroundStyle = navBackgroundStyle
        
    }
    
    var body: some View {
        
        Group {
            switch navBarStyle {
            case .content(let content):
                applyCommonStyle(content)
            case .standard(let navProperties):
                applyCommonStyle(standardView(navProperties: navProperties))
            }
        }
        .background(content: {
            
            switch self.backgroundStyle {
            case .color(let color):
                
                color
                    .ignoresSafeArea()
                
            case .material(let material):
                
                AnyView(Rectangle().fill(material))
                    .ignoresSafeArea()
                
            case .linearGradient(let linearGradient):
                
                linearGradient
                    .ignoresSafeArea()
                
            }
            
        })
        
    }
    
    @ViewBuilder
    private func standardView(navProperties: NavProperties) -> some View {
        
        ZStack(alignment: .center) {
            
            HStack {
                
                // Left Button View
                
                Group {
                    
                    if let leftButtonView = navProperties.leftButtonView {
                        leftButtonView
                    }
                    else {
                        navProperties.rightButtonView
                            .opacity(0)
                    }
                    
                }
                
                Spacer()
                
                // Right Button View
                
                Group {
                    
                    if let rightButtonView = navProperties.rightButtonView {
                        rightButtonView
                    }
                    else {
                        
                        navProperties.leftButtonView
                            .opacity(0)
                    }
                    
                }
                
            }
            .frame(maxWidth: .infinity)
            
            // Center Title & Subtitle
            
            VStack {
                
                Text(navProperties.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.serif)
                
                if let subtitle = navProperties.subtitle {
                    
                    Text(subtitle)
                        .font(.body)
                        .fontWeight(.regular)
                        .fontDesign(.default)
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 48)
            
        }
        
    }
    
    private func applyCommonStyle<V: View>(_ view: V) -> some View {
                
        return view
            .customSafeAreaPadding(
                padding: Spacing.none.value,
                for: .top
            )
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(content: {
                switch self.backgroundStyle {
                case .color(let color):
                    color
                case .material(let material):
                    AnyView(Rectangle().fill(material)).ignoresSafeArea()
                case .linearGradient(let linearGradient):
                    linearGradient
                }
            })
        
    }
    
}

// MARK: - PREVIEWS

#Preview("NavBarStyle: Basic Init", body: {
    
    ZStack(alignment: .top) {
        
        Color.black.opacity(0.8)
            .ignoresSafeArea()
        
        NavBarView(
            title: "Woah",
            subtitle: "This is a subtitle",
            leftButtonView: (Circle().fill(.red).frame(width: 32).asAnyView()),
            rightButtonView: (Circle().fill(.red).frame(width: 32).asAnyView()),
            navBackgroundStyle: .color(.green)
        )
        .background(Color.green)
        
    }
    
})

#Preview("NavBarStyle: Custom", body: {
    
    ZStack(alignment: .top) {
        
        Color.black.opacity(0.8)
            .ignoresSafeArea()
        
        NavBarView(navBarStyle: .content(
            AnyView(HStack {
                
                Circle().fill(.red)
                    .frame(width: 24)
                
                Text("This is some test")
                    .frame(maxWidth: .infinity)
                
                Circle().fill(.red)
                    .frame(width: 24)
                
            }
                   )), backgroundStyle: .color(.red))
        .background(.white)
        
    }
    
})

#Preview("NavBarStyle: Standard",
         body: {
    
    ZStack {
        
        Color.white.ignoresSafeArea()
        
        VStack(spacing: 0) {
            
            NavBarView(navBarStyle: .standard(NavBarView.NavProperties(
                title: "Welcome Home",
                subtitle: "This is fun, come over here",
                leftButtonView: (
                    Image(systemName: "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .background {
                            Color.black.opacity(0.000001)
                                .frame(width: 40, height: 40)
                        }
                        .onTapGesture {
                            print("Test 1")
                        }
                        .asAnyView()
                ),
                rightButtonView: (
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 18)
                        .background {
                            Color.black.opacity(0.000001)
                                .frame(width: 40, height: 40)
                        }
                        .onTapGesture {
                            print("Test 2")
                        }
                        .asAnyView()
                )
            )),  backgroundStyle: .color(.red))
            
            VStack {
                
                Text("Hello")
                Spacer()
                Text("Doogbye")
                
            }
            .frame(maxWidth: .infinity)
            .background(.blue)
            .ignoresSafeArea()
            
        }
        
    }
    .frame(
        maxWidth: .infinity,
        maxHeight: .infinity
    )
    
})
