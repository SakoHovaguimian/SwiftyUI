//
//  FrameReader.swift
//  
//
//  Created by Nick Sarno on 4/10/22.
//

import SwiftUI

@available(iOS 14, *)
/// Adds a transparent View and read it's frame.
///
/// Adds a GeometryReader with infinity frame.
public struct FrameReader: View {
    
    let coordinateSpace: CoordinateSpace
    let onChange: (_ frame: CGRect) -> Void
    
    public init(coordinateSpace: CoordinateSpace, onChange: @escaping (_ frame: CGRect) -> Void) {
        self.coordinateSpace = coordinateSpace
        self.onChange = onChange
    }

    public var body: some View {
        GeometryReader { geo in
            Text("")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear(perform: {
                    onChange(geo.frame(in: coordinateSpace))
                })
                .onChange(of: geo.frame(in: coordinateSpace)) { oldValue, newValue in
                    onChange(newValue)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(iOS 14, *)
public extension View {
    
    /// Get the frame of the View
    ///
    /// Adds a GeometryReader to the background of a View.
    func readingFrame(coordinateSpace: CoordinateSpace = .global, onChange: @escaping (_ frame: CGRect) -> ()) -> some View {
        background(FrameReader(coordinateSpace: coordinateSpace, onChange: onChange))
    }
    
}

@available(iOS 14, *)
struct FrameReader_Previews: PreviewProvider {
    
    struct PreviewView: View {
        
        @State private var yOffset: CGFloat = 0
        @State private var selectedId: String? = nil
        
        var body: some View {
            ZStack(alignment: .top) {
                
                Color.white.ignoresSafeArea()
                
                ScrollView(.vertical) {
                    
                    LazyVStack {
                        
                        Rectangle()
                            .fill(.green)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                            .background(Color.green)
                            .overlay {
                                Text("Home Page Title")
                            }
//                            .asStretchyHeader(startingHeight: 200)
                        
                        
                        ForEach(0..<30) { x in
                            Text("")
                                .frame(maxWidth: .infinity)
                                .frame(height: 800)
                                .cornerRadius(10)
                                .background(Color.green)
                                .padding()
                                .id("\(x)")
                        }
                        
                    }
                    .scrollTargetLayout()
                    .readingFrame { frame in
                        yOffset = frame.minY
                    }
                    
                }
                .overlay(Text("Offset: \(yOffset)"))
                .scrollPosition(id: $selectedId)
                .onChange(of: self.selectedId) { oldValue, newValue in
                    print("WOAH MY NEW SLEECTED ID IS \(newValue ?? "NO VALUE")")
                }
                
                fakeHeaderView(shouldShow: yOffset < -160)
                    
            }
            .ignoresSafeArea()
            
        }
        
        @ViewBuilder
        private func fakeHeaderView(shouldShow: Bool) -> some View {
            HStack(alignment: .center) {
                
                Circle()
                    .fill(.white)
                    .frame(width: 32, height: 32)
                
                Text("Home Page Title")
                    .opacity(shouldShow ? 1 : 0)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Circle()
                    .fill(.white)
                    .frame(width: 32, height: 32)
                    .offset(x: shouldShow ? 0 : 400)
                
            }
            .frame(height: 100)
            .padding(.top, 32)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(shouldShow ? .red : .black.opacity(0.001))
            .animation(.smooth, value: yOffset)
        }
            
    }

    static var previews: some View {
        PreviewView()
    }
    
}
