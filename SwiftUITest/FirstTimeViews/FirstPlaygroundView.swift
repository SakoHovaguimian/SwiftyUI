//
//  ContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/11/23.
//

// MARK: - TODO:

// [] Break views down into seperate files
// [] Combine https://www.waldo.com/blog/swiftui-combine
// [] async await https://medium.com/geekculture/from-combine-to-async-await-c08bf1d15b77
// [] ViewModels
// [] Enviornment variables
// [] Settings page
// [] Navigation with custom routes + sheet support. Check answer and bottom answer to make navigation suite https://stackoverflow.com/questions/73877466/presenting-a-sheet-view-with-navigationstack-in-swiftui
// [] Image card views
// [] Strechy Header
// [] Interactions, longPress, etc...
// [] Tinder style learnings https://github.com/bbaars/SwiftUI-Tinder-SwipeableCards/blob/master/SwipeableCards/CardView.swift
// [] From link above add the cardView + blob-bubble logic of the header into this codebase
// [] Play with components from this link https://a11y-guidelines.orange.com/en/mobile/ios/wwdc/nota11y/2022/2210052/#graphics-and-layout
// [] Charts

// [] Custom Tab Bar resources: https://youtu.be/FxW9Dxt896U || https://jacobko.info/swiftui/swiftui-31/

/// MARK: - Questions:
///
/// Why do i need to use the frame property and how can i get intrinsic size?
/// VStack centering without frame being invloved
/// Overlay for centering content instead of a Vstack for itself?

/// MARK: - Future Work
/// Create modifiers that override system padding for custom app padding how Spacing works
/// Create init for custom color catalog like WNGColor but app wide
/// Create font like WNGFont

import SwiftUI

enum NavigationPath: Hashable {
    
    case product(productName: String)
    case test
    case string
    
}

struct FirstPlaygroundView: View {
    
    @State private var pathItems: [NavigationPath] = []
    @State private var items: [String] = [
        "Sako",
        "Mitch",
        "Michael",
        "Shaun",
        "Julian",
        "Taleen",
        "Duncan",
        "Walter",
        "Walter"
    ]
    
    @State private var isAnimated: Bool = false
    
    var body: some View {
        
//        ScrollView(.horizontal) {
            
//        NavigationStack {
//            List {
//
//                ForEach(Array(items.enumerated()), id: \.offset) { index, element in
//
//                    if index < 3 {
//                        Section(header: Text(element)) {
//
//                            Text(element)
//                                .font(.largeTitle)
//                                .foregroundColor(Color.white)
//                            //                                .shadow(radius: 3)
//                                .padding([.horizontal], 24)
//                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
//
//                                    Button {
//                                        print("Muting conversation")
//                                    } label: {
//                                        Label("Mute", systemImage: "heart.fill")
//                                    }
//                                    .tint(.indigo)
//
//                                    Button {
//                                        print("Muting conversation")
//                                    } label: {
//                                        Label("Mute", systemImage: "clock")
//                                    }
//                                    .tint(.red)
//
//                                    Button {
//                                        print("Muting conversation")
//                                    } label: {
//                                        Label("Mute", systemImage: "bell")
//                                    }
//                                    .tint(.blue)
//
//                                }
//                                .frame(minWidth: 100, maxHeight: 50)
//                                .background(Color.blue)
//                                .clipShape(RoundedRectangle(cornerRadius: 12))
//                                .clipShape(Capsule())
//
//
//                        }
//                    }
//                    else {
//                        Text(element)
//                    }
//
//
//                }
//            }
//            .navigationTitle("Dad")
//            .listStyle(GroupedListStyle())
//            .offset(x: isAnimated ? 120 : 0)
//        }
//
//        Button {
//            self.isAnimated.toggle()
//        } label: {
//            VStack {
//                Group {
//                    HStack(spacing: 8) {
//
//                        Text("Hello")
//                            .foregroundColor(Color.white)
//                            .padding(16)
//
//                        Text("Hello")
//                            .foregroundColor(Color.white)
//                            .padding(16)
//
//
//                    }
//                }
//                .background(Color.indigo)
//                .clipShape(RoundedRectangle(cornerRadius: 11))
//
//            }
//            .offset(y: isAnimated ? 48 : 0)
//        }
//        .tint(.indigo)
////        }
//
//    }
//
//}
//
        GeometryReader { geometry in

            NavigationStack(path: self.$pathItems) {

                ZStack(alignment: .topLeading, content: {

                    Color.gray.opacity(0.2).edgesIgnoringSafeArea(.all)

                    VStack(alignment: .center, spacing: 24) {

                        Group {

                            horizontalScrollView(items: self.items)
                            horizontalScrollView(items: self.items)
                            horizontalScrollView(items: self.items)

                        }
                        .frame(height: 70)

                        VStack(alignment: .center) {

                            Color.clear.overlay(alignment: .center) {

                                CardView {

                                    VStack(alignment: .center, content: {

                                        Label {
                                            Text("Favorites")
                                                .bold()
                                                .foregroundColor(.pink)
                                        } icon: {
                                            Image(systemName: "heart")
                                                .symbolVariant(.fill)
                                                .foregroundColor(.pink)

                                        }

                                        Label {
                                            Text("Sako Hovaguimian")
                                                .foregroundColor(.primary)
                                                .font(.title)
                                                .padding()
                                                .background(.gray.opacity(0.2))
                                                .clipShape(Capsule())
                                        } icon: {
                                            blockView
                                        }

                                    })
                                }
                                .frame(height: 200) // If no frame it doesn't center.
                                .offset(y: -50)

                            }



                        }
                        .background(Color.red)

                        //                    Spacer()

//                        NavigationLink("TEST", value: "TRUE UTEST")
//                        NavigationLink(value: "SOMETHING") {
                            Button(action: {
                                // Handle button action here

    //                            self.items.append("Josh")
                                self.pathItems.append(.product(productName: "T-shirt"))

                            }) {

    //                            NavigationLink(value: "TEST") {

                                    Text("Tap Me")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(width: geometry.size.width - 32, height: 50)
                                        .background(Color.blue)
                                        .cornerRadius(10)
    //                            }

                            }
//                        }



                    }

                })
                .frame(
                    width: geometry.size.width, height: geometry.size.height
                )
                .navigationDestination(for: NavigationPath.self) { value in

//                    NavigationStack {

                        VStack {
                            Text("\(value.hashValue)")
                                .onTapGesture {
                                    self.pathItems.append(.product(productName: "Pants"))
                                    self.pathItems.append(.product(productName: "Shorts"))
                                    self.pathItems.append(.product(productName: "Tees"))
                                    self.pathItems.append(.product(productName: "Pants"))
                                }
                        }
//                        .interactiveDismissDisabled(false)

//                    }

                }
//                .navigationTitle("TEST")
            }

        }

    }

    var blockView: some View {

        RoundedRectangle(cornerRadius: 4)
            .fill(.blue)
            .frame(width: 24, height: 24)

    }

}

extension View {
    func onBackSwipe(perform action: @escaping () -> Void) -> some View {
        gesture(
            DragGesture()
                .onEnded({ value in
                    if value.startLocation.x < 50 && value.translation.width > 80 {
                        action()
                    }
                })
        )
    }
}

func horizontalScrollView(items: [String]) -> some View {

    return GeometryReader { geometry in
        
        ScrollView(.horizontal,
                   showsIndicators: false,
                   content:  {
            
            HStack(spacing: 16, content: {
                
                ForEach(items, id: \.self) { item in
                    itemView(item: item)
                }
                
            })
            .padding(16)
            
        })
        .frame(width: geometry.size.width)
    }
    
}

func itemView(item: String) -> some View {
    
    return VStack {
        Text(item)
            .font(.title)
    }
    .frame(width: 125, height: 60)
    .background(Color.white)
    .shadow(radius: 3)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .onTapGesture {
        print("DID TAP \(item)")
    }
    
}

func cardView(item: String) -> some View {
    
    return VStack {
        Text(item)
            .font(.title)
    }
    .frame(width: 125, height: 100)
    .background(Color.white)
    .shadow(radius: 3)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .onTapGesture {
        print("DID TAP \(item)")
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FirstPlaygroundView()
    }
}


struct CardView<Content: View>: View {
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            HStack(alignment: .center, spacing: 0) {
                
                Spacer()
                
                content
                    .frame(minWidth: geometry.size.width - 32, minHeight: 200)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 23)
                
                Spacer()
                
            }
            
        }
        
    }
    
}

public enum AppSpacing: CGFloat {
    
    case extraSmall = 4
    case small = 8
    case medium = 16
    case large = 24
    
}

extension View {
    
    func embedInNavigation() -> some View {
        NavigationStack { self }
    }
    
    //    func padding(_ edges: Edge.Set = .all, _ length: AppSpacing? = nil) -> some View {
    //        padding(edges, length?.rawValue)
    //    }
    
}
//
//struct Spacing: ViewModifier {
//
//    func body(content: Content) -> some View {
//
//        content
//            .font(.largeTitle)
//            .foregroundColor(.white)
//            .padding()
//            .background(.blue)
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//
//    }
//
//}
