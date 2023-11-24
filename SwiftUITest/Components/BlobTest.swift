//
//  BlobTest.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 11/14/23.
//

//import SwiftUI
//
//struct BlobTest: View {
//    
//    @State var animate: Bool = false
//
//    var body: some View {
//        
//        VStack {
//            
//            Spacer()
//            
//            Canvas { context, size in
//                // The real magic lies in these two filters.
//                // This is an approach common with SVG using feGaussianBlur and feColorMatrix
//            
//                // https://developer.apple.com/documentation/swiftui/graphicscontext/filter/alphathreshold(min:max:color:)?changes=_7_3_5&language=objc
//                // Returns a filter that replaces each pixel with alpha components within a range by a constant color, or transparency otherwise.
//                context.addFilter(.alphaThreshold(min: 0.5, color: .black))
//                
//                // Gaussian blur
//                context.addFilter(.blur(radius: 15))
//                
//                // drawLayer creates a new transparency layer that you can draw into
//                // the above filters won't work without drawing the swiftui symbols into their single layer added to the main context
//                context.drawLayer { ctx in
//                    // access the passed in symbols using their .tag() id
//                    let circle0 = ctx.resolveSymbol(id: 0)!
//                    let circle1 = ctx.resolveSymbol(id: 1)!
//                    
//                    ctx.draw(circle0, at: CGPoint(x: 131, y: 50))
//                    ctx.draw(circle1, at: CGPoint(x: 262, y: 50))
//                }
//                
//            } symbols: {
//                // symbols is how you can tell canvas to accept a regular SwiftUI view to work with
//                // required to .tag() so you get an id to resolve the symbol inside canvas
//                Circle()
//                    .fill(.black)
//                    .frame(width: 90, height: 90)
//                    .offset(x: animate ? 66 : -40)
//                    .tag(0)
//                
//                Circle()
//                    .fill(.black)
//                    .frame(width: 90, height: 90)
//                    .offset(x: animate ? -66 : 40)
//                    .tag(1)
//            }
//            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
//            .frame(height: 100)
//            
//            Spacer()
//        }
//        .task {
//            self.animate = true
//        }
//    }
//}
//
//#Preview {
//    BlobTest()
//}
