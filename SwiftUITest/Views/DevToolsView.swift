//
//  DevToolsView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/15/23.
//

import SwiftUI

enum DevToolsNavigationRoute: Hashable {
    
    case tabBarView
    case styledLabelButton
    case customButton
    case progressBar
    case gradientLabel
    case redactedView
    case chip
    case textView
    case toggle
    
    case sideMenu
    case tikTokView
    case signupContentView
    case grid
    case safari
    case zoomView
    case typewriterView
    case wildView
    case socialMediaView
    case horizontalPagingViewAppleAPI
    case horizontalPagingView
    case onboarding
    
    case product(productId: String)
    
    var displayTitle: String {
        switch self {
        case .sideMenu: return "Side Menu"
        case .signupContentView: return "Create Account"
        case .grid: return "Grid"
        case .safari: return "Safari"
        case .tabBarView: return "Tab Bar View"
        case .progressBar: return "Progress Bar"
        case .zoomView: return "Pinch To Zoom"
        case .styledLabelButton: return "Styled Label Button"
        case .customButton: return "Custom Button"
        case .gradientLabel: return "Gradient Label"
        case .redactedView: return "Shimmer View"
        case .chip: return "Chip Demo"
        case .textView: return "Text View"
        case .typewriterView: return "Typewriter View"
        case .wildView: return "Wild View"
        case .socialMediaView: return "Social Media View"
        case .horizontalPagingView: return "Horizontal Paging View"
        case .horizontalPagingViewAppleAPI: return "Horizontal Paging Apple's API"
        case .product: return "Product Demo Page"
        case .onboarding: return "Onboarding"
        case .tikTokView: return "TikTok View"
        case .toggle: return "Custom Toggle Components"
        }
    }
    
    var icon: String {
        switch self {
        case .sideMenu: return "person.fill"
        case .signupContentView: return "person.fill"
        case .grid: return "square.grid.3x2.fill"
        case .safari: return "safari.fill"
        case .tabBarView: return "chart.bar.fill"
        case .progressBar: return "sun.haze.fill"
        case .zoomView: return "magnifyingglass.circle.fill"
        case .styledLabelButton: return "button.programmable.square.fill"
        case .customButton: return "cursorarrow.square.fill"
        case .gradientLabel: return "pencil.tip"
        case .redactedView: return "sink.fill"
        case .chip: return "globe"
        case .textView: return "abc"
        case .typewriterView: return "window.vertical.open"
        case .wildView: return "paperplane.fill"
        case .socialMediaView: return "book.fill"
        case .horizontalPagingView: return "briefcase.fill"
        case .horizontalPagingViewAppleAPI: return "rectangle.fill.on.rectangle.fill"
        case .product: return "person.crop.artframe"
        case .onboarding: return "person.2.crop.square.stack"
        case .tikTokView: return "books.vertical.fill"
        case .toggle: return "slider.vertical.3"
        }
    }
    
    var color: Color {
        switch self {
        case .signupContentView: return .teal.opacity(0.5)
        case .sideMenu: return AppColor.charcoal.opacity(0.8)
        case .grid: return .green.opacity(0.4)
        case .safari: return .blue
        case .tabBarView: return .pink
        case .progressBar: return .green
        case .zoomView: return .orange
        case .styledLabelButton: return .mint
        case .customButton: return .red
        case .gradientLabel: return .indigo
        case .redactedView: return .gray.opacity(0.5)
        case .chip: return .blue.opacity(0.2)
        case .textView: return .pink.opacity(0.4)
        case .typewriterView: return .purple
        case .wildView: return .yellow.opacity(0.6)
        case .socialMediaView: return .cyan.opacity(0.7)
        case .horizontalPagingView: return .red.opacity(0.4)
        case .horizontalPagingViewAppleAPI: return .red.opacity(0.8)
        case .product: return .black.opacity(0.3)
        case .onboarding: return .pink.opacity(0.1)
        case .toggle: return .yellow.opacity(0.5)
        case .tikTokView: return .green.opacity(0.5)
        }
    }
    
    static func components() -> [DevToolsNavigationRoute] {
        
        return [
            .tabBarView,
            .styledLabelButton,
            .customButton,
            .progressBar,
            .gradientLabel,
            .redactedView,
            .chip,
            .textView,
            .toggle,
        ]
        
    }
    
    static func views() -> [DevToolsNavigationRoute] {
        
        return [
            .onboarding,
            .tikTokView,
            .sideMenu,
            .signupContentView,
            .grid,
            .safari,
            .zoomView,
            .typewriterView,
            .wildView,
            .socialMediaView,
            .horizontalPagingViewAppleAPI,
            .horizontalPagingView
        ]
        
    }
    
}

class NavSettings: ObservableObject {
    
    @Published var currentTintColor: Color = .indigo
    private var originalTintColor: Color = .indigo
    
    func setTintToOriginalColor() {
        self.currentTintColor = self.originalTintColor
    }
    
}

struct DevToolsView: View {
    
    @EnvironmentObject var navSettings: NavSettings
    
    @State private var petCount: Int = 100
    @State private var pathItems: [DevToolsNavigationRoute] = []
    @State private var shouldPresentSheet: Bool = false
    @State private var shouldPresentFullScreen: Bool = false
    
    var body: some View {
        
        NavigationStack(path: self.$pathItems) {
            
            ZStack {
                
                List() {
                    
                    // Component Section
                    
                    sectionView(
                        sectionTitle: "Components",
                        routes: DevToolsNavigationRoute.components()
                    )
                    
                    // Views Section
                    
                    sectionView(
                        sectionTitle: "Views",
                        routes: DevToolsNavigationRoute.views()
                    )
                    
                }
                .listStyle(.insetGrouped)
                .listRowBackground(Color.clear)
                .scrollContentBackground(.hidden)
                .background(LinearGradient(
                    colors: [
                        .purple.opacity(0.7),
                        .indigo.opacity(0.4),
                        .black.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .navigationDestination(for: DevToolsNavigationRoute.self) { route in
                    didSelectRoute(route)
                }
                
            }
            .navigationTitle("Dev Tools")
            .background(Color.clear)
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        self.shouldPresentSheet = true
                    } label: {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: 16, height: 16)
                    }

                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.shouldPresentFullScreen.toggle()
                    } label: {
                        Image(systemName: "person.fill")
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: 16, height: 16)
                    }

                }
            }
            
        }
        .sheet(isPresented: self.$shouldPresentSheet) {
            
            VStack {
                Text("My Sheet")
            }
            .presentationDetents([.large, .medium])
            .presentationBackground(alignment: .bottom) {
                LinearGradient(colors: [Color.pink, Color.purple], startPoint: .bottomLeading, endPoint: .topTrailing)
//            .presentationCornerRadius(180)
            }
            
        }
        .fullScreenCover(isPresented: self.$shouldPresentFullScreen, onDismiss: {
            print("[DEBUG]: DISMISSING THE VIEW")
        }, content: {
            FullScreenModalView()
        })
        .tint(self.navSettings.currentTintColor)
        
    }
    
    
    private func sectionView(sectionTitle: String, routes: [DevToolsNavigationRoute]) -> some View {
        
        Section(content: {
            
            ForEach(routes, id: \.self) { route in
                itemView(route: route)
            }
            
        }, header: {
            
            Text(sectionTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            
        })
        .textCase(nil)
        .listRowSeparator(.hidden)
        .listRowBackground(
            Color.clear
        )
        
    }
    
    private func itemView(route: DevToolsNavigationRoute) -> some View {
         
            ZStack {
                
                Color
                    .white
                    .opacity(0.3)
                
                HStack(
                    alignment: .center,
                    spacing: 16) {
                        
                        Image(systemName: route.icon)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(16)
                            .background(route.color)
                            .cornerRadius(4)
                        
                        Text(route.displayTitle)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                        
                    }
                    .padding(.horizontal, 16)
                
            }
            .cornerRadius(8)
            .overlay {
                NavigationLink(value: route) {
                    EmptyView()
                }
                .opacity(0)
            }
        
        
    }
    
    private func didSelectRoute(_ route: DevToolsNavigationRoute) -> AnyView {
        
        var selectedView: any View
        
        switch route {
        case .tabBarView: selectedView = ProductionTabBarContentView()
        case .styledLabelButton: selectedView = WildButtonView()
        case .customButton:
            
            selectedView =  AnyView(
            
                
                VStack {
                    
                    AnimationView(petCount: petCount)
                    
                    Text("Click me")
                        .padding(24)
                        .background(Color.indigo)
                        .cornerRadius(12)
                        .asButton {
                            self.petCount += 1
                        }
                }
                
            )
            
        case .progressBar: selectedView = CustomProgressBarTest()
        case .gradientLabel: selectedView = GradientLabelView()
        case .redactedView: selectedView = RedactedView().environmentObject(self.navSettings)
        case .chip: selectedView = ChipDemoContentView()
        case .textView: selectedView = CustomTextView()
        case .grid: selectedView = GridContentView()
        case .safari: selectedView = (SafariWebContentView(url: URL(string: "https://www.google.com")!))
        case .zoomView: selectedView = ZoomView(image: Image("sunset"), cornerRadius: 24).padding(.horizontal, 24)
        case .typewriterView: selectedView = (TypewriterContentView())
        case .wildView: selectedView = (WildButtonView())
        case .socialMediaView: selectedView = (SocialMediaView(image: Image("pond")))
        case .horizontalPagingView: selectedView = (HorizontalPagingView())
        case .horizontalPagingViewAppleAPI: selectedView = ScrollViewPagingAPI()
        case .product(let productId): selectedView = Text("PRODUCT PAGE \(productId)")
        case .sideMenu: selectedView = SideMenuParentContentView()
        case .signupContentView: selectedView = SignUpContentView()
        case .onboarding: selectedView = (OnboardingViewCarousel().navigationBarBackButtonHidden())
        case .tikTokView: selectedView = (TikTokView().navigationBarBackButtonHidden())
        case .toggle: selectedView = (SettingsView().navigationBarBackButtonHidden())
        }
        
        return AnyView(selectedView)
        
    }
    
}

struct FullScreenModalView: View {
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.indigo, Color.cyan], startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
                VStack(spacing: 32) {
                 
                    Button("Dismiss Modal") {
                        dismiss()
                    }
                    .font(.largeTitle)
                    .fontDesign(.serif)
                    .fontWeight(.heavy)
                    .padding()
                    .foregroundColor(.white)
                    .background(.pink)
                    .cornerRadius(10)
                    
//                    Button("Push New Modal") {
                        NavigationLink("Push New Modal") {
                            Text("New Push")
                        }
//                    }
                    .font(.largeTitle)
                    .fontDesign(.serif)
                    .fontWeight(.heavy)
                    .padding()
                    .foregroundColor(.white)
                    .background(.pink)
                    .cornerRadius(10)
                    
                }
            }
        }
    }
}
