//
//  SocialMediaView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/13/23.
//

import SwiftUI

//struct SocialMediaView: View {
//    
//    var initialHeaderHeight: CGFloat = UIScreen.main.bounds.height * 0.4
//    @State private var offsetY: CGFloat = 0
//    
//    // This is nice to make blurs that look like they end in fuzz
//    //    let gradient = LinearGradient(
//    //        gradient: Gradient(stops: [
//    //            .init(color: .purple, location: 0),
//    //            .init(color: .clear, location: 0.4)
//    //        ]),
//    //        startPoint: .bottom,
//    //        endPoint: .top
//    //    )
//    
//    var body: some View {
//        
//        GeometryReader { geometry in
//            
//            let minY = geometry.frame(in: .global).minY
//            
//            ZStack(alignment: .top) {
//                
//                LinearGradient(
//                    colors: [.green.opacity(0.7), .mint.opacity(0.3)],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                
//                ScrollView(.vertical) {
//                    
//                    //                VStack(spacing: 0) {
//                    
//                    StretchableHeader(image: Image("sunset"), geometryProxy: geometry, initialHeight: 300)
//                        .overlay {
//
//                            VStack(spacing: 8) {
//
//                                Text("Sunset")
//                                    .bold()
//                                    .font(.largeTitle)
//
//                                Text("Shot on an iphone")
//                                    .font(.caption)
//
//                                TextField("Add text", text: .constant("Something"))
//                                    .padding(6)
//                                    .background(Color.gray.opacity(0.3))
//                                    .cornerRadius(10)
//                                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
//                                    .padding(.horizontal)
//
//                            }
//                            .foregroundColor(.white)
//                            .offset(y: minY > 0 ? -minY : 0)
//
//                        }
////
////
////
////                    ForEach((0...10), id: \.self) { _ in
////
////                        Color.pink
////                            .frame(height: 200)
////                            .cornerRadius(12)
////                            .shadow(radius: 23)
////                            .padding()
////
////                    }
//                    
//                    
//                    //
//                    //                }
//                    //                    .frame(maxHeight: .infinity)
//                    //                    .foregroundStyle(.ultraThickMaterial)
//                }
//                //                .frame(maxHeight: .infinity)
//                
//            }
//            .ignoresSafeArea(edges: .bottom)
//            
//        }
//        
//    }
//    
//}
//
//struct StretchableHeader: View {
//    
//    var image: Image
//    var geometryProxy: GeometryProxy
//    var initialHeight: CGFloat = UIScreen.main.bounds.height * 0.4
//    
//    var body: some View {
//        
//        GeometryReader(content: { geometry in
//            
//            let minY = calculateScrollViewOffSet(minY: geometry.frame(in: .global).minY)
//            
//            ZStack {
//                self.image
//                    .resizable()
//                    .offset(y: minY > 0 ? -minY : 0)
//                    .aspectRatio(1, contentMode: .fill)
//            }
//            .frame(height: minY > 0 ? self.initialHeight + minY : self.initialHeight)
//            .scaleEffect((300 + minY) / 300) // 300 is initial height
//            .offset(x: minY > 59 ? -minY : 0)
//            
//        })
//        .frame(height: self.initialHeight)
//        
//    }
//    
//    private func calculateScrollViewOffSet(minY: CGFloat) -> CGFloat {
//        
//        if minY < 0 {
//            print(minY)
//            return 50
//        } else {
//            print(minY)
//        }
//        
//        return minY
//        
//    }
//    
//}

// Create new strechyHEaderView class
// STATE: image, binding - offset,

struct SocialMediaView: View {
    
    var image: Image
    @State var scrollOffset: CGFloat = 0
    
    var body: some View {
        
        ZStack{
            
            AppColor.charcoal
                .edgesIgnoringSafeArea(.all)
            
            ScrollViewWithScrollOffset(scrollOffset: self.$scrollOffset) {
                
                VStack {
                    
                    self.imageView
                        .frame(maxHeight: 300)
                    
                    AppColor.charcoal
                        .edgesIgnoringSafeArea(.all)
                        .frame(height: 1000)
                    
                }
                
            }
            
        }
        .edgesIgnoringSafeArea(.all)
        
    }
    
    var imageView: some View {
        
        GeometryReader { proxy in // 2. get actual size on screen
            
            let _ = print(proxy.size.height)
            
            self.image // 3. use scrollOffset to adjust image
                .resizable()
//                .aspectRatio(contentMode: .fill) // Use fit for system images, test with landscape photo
                .padding(.horizontal, min(0, -scrollOffset))
                .frame(width: proxy.size.width,
                       height: proxy.size.height + max(0, scrollOffset))
                .offset(CGSize(width: 0, height: min(0, -scrollOffset)))
            
        }
        .aspectRatio(CGSize(width: UIScreen.main.bounds.width, height: 300), contentMode: .fill)
        
    }
    
}

//struct SocialMediaView: View {
//    
//    var image: Image
//    @State var scrollOffset: CGFloat = 0
//    
//    private let coordinateSpaceName = "scrollViewSpaceName"
//    var body: some View {
//        
//        ZStack{
//            
//            AppColor.charcoal
//                .edgesIgnoringSafeArea(.all)
//            
//            ScrollView {
//                
//                VStack {
//                    
//                    ZStack {
//                        
//                        imageView
//                            .overlay {
//    
//                                VStack(spacing: 8) {
//    
//                                    Text("Sunset")
//                                        .bold()
//                                        .font(.largeTitle)
//    
//                                    Text("Shot on an iphone")
//                                        .font(.caption)
//    
//                                    TextField("Add text", text: .constant("Something"))
//                                        .padding(6)
//                                        .background(Color.gray.opacity(0.3))
//                                        .cornerRadius(10)
//                                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
//                                        .padding(.horizontal)
//    
//                                }
//                                .foregroundColor(.white)
//                                .offset(y: self.scrollOffset > 0 ? -self.scrollOffset : 0)
//                                
//                                let _ = print(self.scrollOffset)
//    
//                            }
//                            .frame(height: 300) // Add custom height
//                        
//                    }
//                    Color.gray.frame(height: 1000)
//                }
//                .background( // 1. find scrollOffset
//                    GeometryReader { proxy in
//                        let offset = proxy.frame(in: .named(coordinateSpaceName)).minY
//                        Color.clear.preference(key: ScrollViewWithPullDownOffsetPreferenceKey.self, value: offset)
//                    }
//                )
//            }
//            .coordinateSpace(name: coordinateSpaceName)
//            .onPreferenceChange(ScrollViewWithPullDownOffsetPreferenceKey.self) { value in
//                scrollOffset = value
//            }
//            .edgesIgnoringSafeArea(.all)
//        }
//    }
//
//    var imageView: some View {
//        GeometryReader { proxy in // 2. get actual size on screen
//            self.image // 3. use scrollOffset to adjust image
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .padding(.horizontal, min(0, -scrollOffset))
//                .frame(width: proxy.size.width,
//                       height: proxy.size.height + max(0, scrollOffset))
//                .offset(CGSize(width: 0, height: min(0, -scrollOffset)))
//        }
//        .aspectRatio(CGSize(width: 375, height: 280), contentMode: .fit)
//    }
//}

public struct ScrollViewWithScrollOffset<V: View>: View {
    
    @Binding var scrollOffset: CGFloat
    @ViewBuilder let content: V
    
    public init(scrollOffset: Binding<CGFloat>, content: () -> V) {
        _scrollOffset = scrollOffset
        self.content = content()
    }
    
    private let coordinateSpaceName = "scrollViewSpaceName"
    public var body: some View {
        ScrollView {
            content
                .background(
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .named(coordinateSpaceName)).minY
                        Color.clear.preference(key: ScrollViewWithPullDownOffsetPreferenceKey.self, value: offset)
                    }
                )
        }
        .coordinateSpace(name: coordinateSpaceName)
        .onPreferenceChange(ScrollViewWithPullDownOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
    }
}

struct ScrollViewWithPullDownOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
