//
//  ScrollView.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/12/24.
//

import SwiftUI

@available(iOS 14, *)
/// Adds a transparent View and read it's center point.
///
/// Adds a GeometryReader with 0px by 0px frame.
public struct LocationReader: View {
    
    let coordinateSpace: CoordinateSpace
    let onChange: (_ location: CGPoint) -> Void

    public init(coordinateSpace: CoordinateSpace, onChange: @escaping (_ location: CGPoint) -> Void) {
        self.coordinateSpace = coordinateSpace
        self.onChange = onChange
    }
    
    public var body: some View {
        FrameReader(coordinateSpace: coordinateSpace) { frame in
            onChange(CGPoint(x: frame.midX, y: frame.midY))
        }
        .frame(width: 0, height: 0, alignment: .center)
    }
}

@available(iOS 14, *)
public extension View {
    
    /// Get the center point of the View
    ///
    /// Adds a 0px GeometryReader to the background of a View.
    func readingLocation(coordinateSpace: CoordinateSpace = .global, onChange: @escaping (_ location: CGPoint) -> ()) -> some View {
        background(LocationReader(coordinateSpace: coordinateSpace, onChange: onChange))
    }
    
}

@available(iOS 14, *)
struct LocationReader_Previews: PreviewProvider {
    
    struct PreviewView: View {
        
        @State private var yOffset: CGFloat = 0
        
        var body: some View {
            ScrollView(.vertical) {
                VStack {
                    Text("Hello, world!")
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .cornerRadius(10)
                        .background(Color.green)
                        .padding()
                        .readingLocation { location in
                            yOffset = location.y
                        }
                    
                    ForEach(0..<30) { x in
                        Text("")
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .cornerRadius(10)
                            .background(Color.green)
                            .padding()
                    }
                }
            }
            .coordinateSpace(name: "test")
            .overlay(Text("Offset: \(yOffset)"))
        }
    }

    static var previews: some View {
        PreviewView()
    }
}


@available(iOS 14, *)
public struct ScrollViewWithOnScrollChanged<Content:View>: View {
    
    let axes: Axis.Set
    let showsIndicators: Bool
    let content: Content
    let onScrollChanged: (_ origin: CGPoint) -> ()
    @State private var coordinateSpaceID: String = UUID().uuidString
    
    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = false,
        @ViewBuilder content: () -> Content,
        onScrollChanged: @escaping (_ origin: CGPoint) -> ()) {
            self.axes = axes
            self.showsIndicators = showsIndicators
            self.content = content()
            self.onScrollChanged = onScrollChanged
        }
    
    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            LocationReader(coordinateSpace: .named(coordinateSpaceID), onChange: onScrollChanged)
            content
        }
        .coordinateSpace(name: coordinateSpaceID)
    }
    
}

@available(iOS 14, *)
struct ScrollViewWithOnScrollChanged_Previews: PreviewProvider {
    
    struct PreviewView: View {
        
        @State private var yPosition: CGFloat = 0
        @State private var fullHeaderSize: CGSize = .zero

        var body: some View {
            ZStack(alignment: .top) {
                
                Color.black.opacity(1)
                    .ignoresSafeArea()
                
                ZStack {
                    
                    LinearGradient(colors: [
                        .red.opacity(0.3),
                        .red.opacity(0)
                    ], startPoint: .top,
                       endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                }
                .frame(maxHeight: max(10, 400 + (yPosition * 0.75)))
                .opacity(yPosition <= -500 ? 0 : 1)
                
                ScrollViewWithOnScrollChanged {
                    LazyVStack {
                        
                        ForEach(0..<30) { x in
                            Text("x: \(x)")
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .cornerRadius(10)
                                .background(Color.gray)
                                .padding()
                                .id(x)
                        }
                    }
                    .padding(.top, fullHeaderSize.height)
                } onScrollChanged: { origin in
                    yPosition = origin.y
                }
                .overlay(Text("Offset: \(yPosition)"))
                
                VStack {
                    
                    Text("This is some banner")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .fontDesign(.serif)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 24)
                    
                    if yPosition >= -30 {
                        
                        ScrollView(.horizontal) {
                            
                            HStack {
                                
                                Rectangle()
                                    .fill(.blue)
                                    .frame(width: 150, height: 50)
                                    .id("123")
                                    .ignoresSafeArea()
                                    .clipShape(.capsule)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                
                                Rectangle()
                                    .fill(.blue)
                                    .frame(width: 150, height: 50)
                                    .id("123")
                                    .ignoresSafeArea()
                                    .clipShape(.capsule)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                
                                Rectangle()
                                    .fill(.blue)
                                    .frame(width: 150, height: 50)
                                    .id("123")
                                    .ignoresSafeArea()
                                    .clipShape(.capsule)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                
                                Rectangle()
                                    .fill(.blue)
                                    .frame(width: 150, height: 50)
                                    .id("123")
                                    .ignoresSafeArea()
                                    .clipShape(.capsule)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                
                            }
                            .padding(.horizontal, 16)
                            
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                    }
                    
                }
                .padding(.bottom, 16)
                .background {
                    ZStack {
                        if yPosition >= -30  {
                            Rectangle()
                                .fill(.clear)
                                .ignoresSafeArea()
                        }
                        else {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .ignoresSafeArea()
                        }
                    }
                }
                .animation(.smooth, value: self.yPosition)
                .readingFrame { frame in
                    if fullHeaderSize == .zero {
                        fullHeaderSize = frame.size
                    }
                }
                
            }
            .toolbar(.hidden, for: .navigationBar)
            .animation(.smooth, value: self.yPosition)
        }
    }
    
    static var previews: some View {
        PreviewView()
    }
}
