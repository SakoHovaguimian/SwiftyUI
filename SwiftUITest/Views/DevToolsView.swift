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
    
    case sideMenu
    case grid
    case safari
    case zoomView
    case typewriterView
    case wildView
    case socialMediaView
    case horizontalPagingView
    
    case product(productId: String)
    
    var displayTitle: String {
        switch self {
        case .sideMenu: return "Side Menu"
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
        case .typewriterView: return "Typewriter View"
        case .wildView: return "Wild View"
        case .socialMediaView: return "Social Media View"
        case .horizontalPagingView: return "Horizontal Paging View"
        case .product: return "Product Demo Page"
        }
    }
    
    var icon: String {
        switch self {
        case .sideMenu: return "person.fill"
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
        case .typewriterView: return "window.vertical.open"
        case .wildView: return "paperplane.fill"
        case .socialMediaView: return "book.fill"
        case .horizontalPagingView: return "briefcase.fill"
        case .product: return ""
        }
    }
    
    var color: Color {
        switch self {
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
        case .typewriterView: return .purple
        case .wildView: return .yellow.opacity(0.6)
        case .socialMediaView: return .cyan.opacity(0.7)
        case .horizontalPagingView: return .red.opacity(0.4)
        case .product: return .black.opacity(0.3)
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
            .chip
        ]
        
    }
    
    static func views() -> [DevToolsNavigationRoute] {
        
        return [
            .sideMenu,
            .grid,
            .safari,
            .zoomView,
            .typewriterView,
            .wildView,
            .socialMediaView,
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
    
    @State private var pathItems: [DevToolsNavigationRoute] = []
    @State private var shouldPresentSheet: Bool = false
    
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.shouldPresentSheet = true
                    } label: {
                        Image(systemName: "heart.fill")
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
            .presentationBackground(alignment: .bottom) {
                LinearGradient(colors: [Color.pink, Color.purple], startPoint: .bottomLeading, endPoint: .topTrailing)
//            .presentationCornerRadius(180)
            }
            
        }
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
                        Text("Click me")
                            .padding(24)
                            .background(Color.indigo)
                            .cornerRadius(12)
                            .asButton {
                                print("You clicked me")
                            }
                    }

                )
//            }
            
        case .progressBar: selectedView = CustomProgressBarTest()
        case .gradientLabel: selectedView = GradientLabelView()
        case .redactedView: selectedView = RedactedView().environmentObject(self.navSettings)
        case .chip: selectedView = ChipDemoContentView()
        case .grid: selectedView = GridContentView()
        case .safari: selectedView = (SafariWebContentView(url: URL(string: "https://www.google.com")!))
        case .zoomView: selectedView = ZoomView(image: Image("sunset"), cornerRadius: 24).padding(.horizontal, 24)
        case .typewriterView: selectedView = (TypewriterContentView())
        case .wildView: selectedView = (WildButtonView())
        case .socialMediaView: selectedView = (SocialMediaView())
        case .horizontalPagingView: selectedView = (HorizontalPagingView())
        case .product(let productId): selectedView = Text("PRODUCT PAGE \(productId)")
        case .sideMenu: selectedView = SideMenuParentContentView()
        }
        
        return AnyView(selectedView)
        
    }
    
}
