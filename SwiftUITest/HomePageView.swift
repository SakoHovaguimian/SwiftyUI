//
//  HomePageView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/21/23.
//

import SwiftUI

struct HomePageView: View {
    
    var initialCornerRadius = UIScreen.main.bounds.height / 15
    
    private var circleInitialOffset: CGFloat = -(UIScreen.main.bounds.height - (UIScreen.main.bounds.height * 0.32))
    @State private var scrollViewOffset: CGPoint = .zero
    @State private var cornerRadius: CGFloat = UIScreen.main.bounds.height / 15
    
    @State private var isAnimating: Bool = true
    
    var body: some View {
        
        let _ = print(abs(UIScreen.main.bounds.height + self.circleInitialOffset))
        
        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            RoundedRectangle(cornerRadius: self.cornerRadius)
                .fill(Color.green.opacity(1))
                .animation(.snappy, value: self.isAnimating)
//                .overlay {
//                    VStack {
//                        HStack(alignment: .top) {
//                            Image(.sunset)
//                                .resizable()
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        }
//                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
//                }
                .offset(y: calculateStopPlaceForHeader())
                .ignoresSafeArea()
                .zIndex(1000)

            
            
            OffsetObservingScrollView(
                axes: .vertical,
                showsIndicators: false,
                offset: self.$scrollViewOffset
            ) {

                VStack(spacing: 16) {

                    ForEach(0..<100) { _ in

                        RoundedRectangle(cornerRadius: 11)
                            .fill(Color.teal.opacity(0.8))
                            .frame(width: UIScreen.main.bounds.width - 48, height: 100)
                            .tint(Color.purple)
                    }

                }
                .offset(y: abs(UIScreen.main.bounds.height + self.circleInitialOffset)) // remove magic 50 number

            }
            
        }
        .onChange(of: self.scrollViewOffset, perform: { _ in
            print(self.scrollViewOffset)
            calculateCornerRadiusForHeader()
        })
        
    }
    
    private func calculateCornerRadiusForHeader() {
        
        var cornerRadius: CGFloat = self.initialCornerRadius
        
        if scrollViewOffset.y > 165 {
            cornerRadius = 11
        }
        
        withAnimation(.linear(duration: 0.1)) {
            self.cornerRadius = cornerRadius
        }
        
    }
    
    private func calculateStopPlaceForHeader() -> CGFloat {
        
        // Print this is what was there before
//        self.circleInitialOffset - self.scrollViewOffset.y
        
        if scrollViewOffset.y == 0 {
            return self.circleInitialOffset
        }
        else if scrollViewOffset.y > 165 {
            return self.circleInitialOffset - (165)
        }
        else if scrollViewOffset.y <= -165 {
            return self.circleInitialOffset - (-165)
        }
        else {
            return self.circleInitialOffset - (self.scrollViewOffset.y)
        }
        
    }
}

struct HomePageVieww_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

private extension PositionObservingView {
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGPoint { .zero }

        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
            // No-op
        }
    }
}

struct PositionObservingView<Content: View>: View {
    var coordinateSpace: CoordinateSpace
@Binding var position: CGPoint
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background(GeometryReader { geometry in
                Color.clear.preference(
    key: PreferenceKey.self,
    value: geometry.frame(in: coordinateSpace).origin
)
            })
            .onPreferenceChange(PreferenceKey.self) { position in
                self.position = position
            }
    }
}

struct OffsetObservingScrollView<Content: View>: View {
    var axes: Axis.Set = [.vertical]
    var showsIndicators = true
    @Binding var offset: CGPoint
    @ViewBuilder var content: () -> Content

    // The name of our coordinate space doesn't have to be
    // stable between view updates (it just needs to be
    // consistent within this view), so we'll simply use a
    // plain UUID for it:
    private let coordinateSpaceName = UUID()

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            PositionObservingView(
                coordinateSpace: .named(coordinateSpaceName),
                position: Binding(
                    get: { offset },
                    set: { newOffset in
                        offset = CGPoint(
    x: -newOffset.x,
    y: -newOffset.y
)
                    }
                ),
                content: content
            )
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}
