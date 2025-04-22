//
//  ContentView.swift
//  Tardr
//
//  Created by Sako Hovaguimian on 3/29/24.
//

import SwiftUI

enum ColorDemo: CaseIterable {
    
    case green
    case red
    case blue
    case purple
    case yellow
    
    var lightColor: Color {
        switch self {
        case .green: return .green
        case .red: return .red
        case .blue: return .blue
        case .purple: return .purple
        case .yellow: return .yellow
        }
    }
    
    var darkColor: Color {
        switch self {
        case .green: return .green
        case .red: return .red
        case .blue: return .blue
        case .purple: return .purple
        case .yellow: return .yellow
        }
    }
    
    var icon: Image {
        switch self {
        case .green: return .init(systemName: "person")
        case .red: return .init(systemName: "house")
        case .blue: return .init(systemName: "heart")
        case .purple: return .init(systemName: "lightbulb")
        case .yellow: return .init(systemName: "arrow.left")
        }
    }
    
    var title: String {
        switch self {
        case .green: return "Profile"
        case .red: return "Home"
        case .blue: return "Love"
        case .purple: return "Power"
        case .yellow: return "Back"
        }
    }
    
}

struct ColorDemoView: View {
    
    var body: some View {
        
        VStack {
            
            ForEach(ColorDemo.allCases, id: \.self) { colorDemo in
                circleView(colorDemo: colorDemo)
                    .offset(x: randomNumber())
            }
            
        }
        
    }
    
    private func randomNumber() -> Double {
        return .random(in: -100...100)
    }
    
}

#Preview {
    ColorDemoView()
}

@ViewBuilder
private func circleView(colorDemo: ColorDemo) -> some View {
    
    VStack {
        
        Circle()
            .fill(colorDemo.lightColor)
            .overlay {
                
                VStack(spacing: 8) {
                    
                    colorDemo.icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(colorDemo.darkColor)
                        .frame(maxWidth: 64, maxHeight: 64)
                    
                    Text(colorDemo.title)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                        .font(.title)
                        .fontWeight(.light)
                        .foregroundStyle(colorDemo.darkColor)
                    
                }
                .padding(24)
                
            }
        
    }
    
}


struct RectangleColorScreen: View {
    
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                
                VStack(spacing: 24) {
                    
                    Rectangle()
                        .fill(Color(.lightPurple))
                        .frame(maxWidth: .infinity)
                        .cornerRadius(23)
                        .overlay {
                            
                            VStack(alignment: .leading) {
                                
                                Text("Welcome Sako")
                                    .font(.title)
                                    .fontDesign(.serif)
                                    .fontWeight(.heavy)
                                //                                .padding(.top, -36)
                                    .scaleEffect(titleTextScrolloffset())
                                
                                Text("Father of 2 year old Leon")
                                    .font(.caption)
                                    .fontWeight(.regular)
                                //                                .padding(.top, -36)
                                    .scaleEffect(titleTextScrolloffset())
                                
                            }
                        }
                        .asStretchyHeader(startingHeight: 150)
//                        .background(.red)
                        .readingFrame { frame in
                            self.scrollOffset = frame.minY
                        }
                    
                    ForEach(ColorDemo.allCases, id: \.self) { colorDemo in
                        row(colorDemo: colorDemo)
                    }
                    
                    ForEach(ColorDemo.allCases, id: \.self) { colorDemo in
                        row(colorDemo: colorDemo)
                    }
                    
                    ForEach(ColorDemo.allCases, id: \.self) { colorDemo in
                        row(colorDemo: colorDemo)
                    }
                    
                    ForEach(ColorDemo.allCases, id: \.self) { colorDemo in
                        row(colorDemo: colorDemo)
                    }
                    
                    ForEach(ColorDemo.allCases, id: \.self) { colorDemo in
                        row(colorDemo: colorDemo)
                    }
                    
                    ForEach(ColorDemo.allCases, id: \.self) { colorDemo in
                        row(colorDemo: colorDemo)
                    }
                    
                }
                
            }
            .overlay {
                Text("\(scrollOffset)")
                    .foregroundStyle(.white)
                    .padding(32)
                    .background(.black)
                    .clipShape(.rect(cornerRadius: 24))
            }
            
            fakeHeaderView(shouldShow: scrollOffset < -100)
            
        }
        
    }
    
    private func titleTextScrolloffset() -> CGFloat {
        guard self.scrollOffset > 0 else { return 1 }
        let ratio = (self.scrollOffset + 200) / 200
        return ratio >= 1.2 ? 1.2 : ratio
    }
    
    @ViewBuilder
    private func fakeHeaderView(shouldShow: Bool) -> some View {
        
        HStack(alignment: .center) {
            
            Circle()
                .fill(.gray)
                .frame(width: 32, height: 32)
            
            Text("Home")
                .font(.title3)
                .fontWeight(.bold)
                .opacity(shouldShow ? 1 : 0)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Circle()
                .fill(.gray)
                .frame(width: 32, height: 32)
                .offset(x: shouldShow ? 0 : 400)
            
        }
        .frame(height: shouldShow ? 100 : 150)
        .padding(.top, shouldShow ? 24 : 0)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(.blue)
        .background(shouldShow ? .clear : .black.opacity(0.001))
        .background {
            if shouldShow {
                Rectangle().fill(.ultraThinMaterial)
            }
            else {
                Rectangle().fill(.clear)
            }
        }
        .animation(.smooth, value: scrollOffset)
    }
    
    @ViewBuilder
    private func row(colorDemo: ColorDemo) -> some View {
            
            HStack(spacing: 12) {
                
                colorDemo.icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(colorDemo.darkColor)
                    .frame(maxWidth: 32, maxHeight: 32)
                
                VStack(alignment: .leading) {
                    
                    Text(colorDemo.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(colorDemo.darkColor)
                    
                    Text("This is a description...")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(colorDemo.darkColor)
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(32)
            .background(colorDemo.lightColor)
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal, 24)
//            .clipped()
//            .shadow(color: .black.opacity(0.2), radius: 4)
        
    }
    
}

#Preview {
    ZStack {
        RectangleColorScreen()
    }
    .ignoresSafeArea()
}


struct TestBarView: View {
    
    var body: some View {
        
        // Bar
        
        HStack {
            
            Rectangle()
                .fill(.blue)
                .frame(
                    width: 32,
                    height: 32
                )
            
            VStack {
                
                Text("Test Title")
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.serif)
                
                Text("This is a test body")
                    .font(.body)
                    .fontWeight(.regular)
                    .fontDesign(.default)
                
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            
            Rectangle()
                .fill(.gray)
                .frame(
                    width: 32,
                    height: 32
                )
            
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(.white)
        
    }
    
}

struct TestPreviewView: View {
    
    @State var scrollOffset: CGFloat = 0
        
    var body: some View {
        ZStack(alignment: .top) {
            
            Color.black
                .opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                NavBarView(navBarStyle: .standard(.init(
                    title: "Home",
//                    subtitle: "This is the home page",
                    leftButtonView: (
                        HStack(spacing: 16) {
                            
                            Image(systemName: "bell")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.black)
                            
                            Image(systemName: "person.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.black)
                            
                        }
                            .offset(x: scrollOffset < -150 ? 0 : -80)
                            .animation(.smooth, value: scrollOffset)
                            .asAnyView()
                    ),
                    rightButtonView: (
                        HStack(spacing: 16) {
//                            
//                            Image(systemName: "bell")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 24, height: 24)
//                                .foregroundStyle(.black)
                            
//                            Image(systemName: "person.fill")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 24, height: 24)
//                                .foregroundStyle(.black)
                            
                        }
                            .animation(.smooth, value: scrollOffset)
                            .asAnyView()
                    )
                )), backgroundStyle: .color(.white))
                .background(.white)
                
                ScrollView {
                    
                    LazyVStack(spacing: 0) {
                        
                        Rectangle().fill(.red)
                            .frame(height: 600)
                        
                        Rectangle().fill(.blue)
                            .frame(height: 600)
                        
                        Rectangle().fill(.red)
                            .frame(height: 600)
                        
                    }
                    .readingFrame { frame in
                        scrollOffset = frame.minY
                    }
                    
                }
                
            }
            
            
//            fakeHeaderView(shouldShow: scrollOffset < -150)
//                .ignoresSafeArea()
            
        }
        .overlay {
            Text("\(scrollOffset)")
                .foregroundStyle(.white)
                .padding(32)
                .background(.black)
                .clipShape(.rect(cornerRadius: 24))
        }
    }
    
    private func titleTextScrolloffset() -> CGFloat {
        guard self.scrollOffset > 0 else { return 1 }
        let ratio = (self.scrollOffset + 200) / 200
        return ratio >= 1.2 ? 1.2 : ratio
    }
    
    @ViewBuilder
    private func fakeHeaderView(shouldShow: Bool) -> some View {
        
        HStack(alignment: .center) {
            
            Circle()
                .fill(.gray)
                .frame(width: 24, height: 24)
                .padding(.top, 24)
            
            Text("Home")
                .font(.title)
                .fontWeight(.bold)
                .fontDesign(.serif)
                .opacity(shouldShow ? 1 : 0)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Circle()
                .fill(.gray)
                .frame(width: 24, height: 24)
                .offset(x: shouldShow ? 0 : 400)
                .padding(.top, 24)
            
        }
//        .frame(height: shouldShow ? 100 : 150)
//        .padding(.vertical, shouldShow ? 24 : 0)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(.blue)
        .background(shouldShow ? .clear : .black.opacity(0.001))
        .background {
            if shouldShow {
                Rectangle().fill(.ultraThinMaterial)
            }
            else {
                Rectangle().fill(.clear)
            }
        }
        .animation(.smooth, value: scrollOffset)
    }
    
}

#Preview {
    TestPreviewView()
}
