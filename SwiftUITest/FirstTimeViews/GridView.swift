//
//  GridView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/13/23.
//

import SwiftUI

// [] Make a "button" that fills as progress gets better
// [] Grid. Learn how to take up the full space based on height and stuff

struct GridView: View {
    
//    private var imageList: some View {
//        ForEach(0...49, id: \.self) { _ in
//            Image("sunset")
//                .resizable()
//                .clipped()
//                .clipShape(RoundedRectangle(cornerRadius: 15))
//                .frame(width: 180, height: CGFloat.random(in: 180...300), alignment: .center)
//        }
//    }
    
    private var imageView: some View {
            Image("sunset")
                .resizable()
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 15))
//                .frame(maxWidth: .infinity, maxHeight: CGFloat.random(in: 180...300), alignment: .center)
    }
    
    private func buildViews() -> [some View] {
        return [self.imageView, imageView, imageView, imageView]
    }
    
    var body: some View {
        
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible(maximum: .infinity))
        ]
        
        Grid() {
            GridRow {
//                Color.clear.gridCellUnsizedAxes([])
                buildViews()[0]
//                ForEach(0..<3) { _ in
//                    buildViews()[0]
//                }
                
            }
            GridRow {
                buildViews()[1]
                    .gridCellColumns(2)

            }
            GridRow {
                buildViews()[2]
//                    .gridCellAnchor(.center)
                    .gridCellColumns(3)
            }
        }
//        .background(Color.red)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .padding(-5)
        .blur(radius: 3)
//            .padding(24)
        

//        LazyVGrid(columns: columns) {
//            GridRow {
////                ForEach(0..<3) { _ in
//                    Text("TRUS")
//                    .font(.largeTitle)
////                }
//                // 1
//                imageView
////                    .gridCellColumns(6)
//            }
//            GridRow {
//                // 2
//                Color.yellow
////                    .gridCellColumns(4)
//
//                Color.yellow
////                    .gridCellColumns(3)
//
//            }
//            GridRow {
////                ForEach(0..<5) { _ in
//                    Color.mint
////                }
//            }
//        }
//            .padding(24)
        
//        let homeGridItems: [GridItem] = [
//            .init(.fixed(180))
//        ]
//
//        ScrollView {
//            HStack(alignment: .top) {
//                LazyVGrid(columns: homeGridItems) {
//                    imageList
//
//                }
//                LazyVGrid(columns: homeGridItems) {
//                    imageList
//                }
//            }
//        }
        
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView()
    }
}

struct CustomProgressBarTest: View {
    
    @State private var progress: Float = 1
    
    var body: some View {
        
        VStack(
            alignment: .center,
            spacing: 24) {
            
            CustomProgressBar(
                value: self.$progress,
                trackColor: .mint,
                fillColor: .green.opacity(0.8)
            )
            .frame(height: 16)
                
                Text("Progress: \((self.progress * 100), specifier: "%.2f")%")
                    .font(.title)
                    .bold()
                
                Text("Goal: 60")
                    .font(.title)
                    .bold()
                
                if self.progress * 100 >= 60 {
                    
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .font(.largeTitle)
                        .foregroundColor(Color.green.opacity(0.7))
                    
                }
                
            Spacer()
                
            StyledLabel(
                title: "Update progress",
                systemImageName: "plus.circle.fill",
                color: .mint) {
                    self.progress = Float.random(in: 0...1)
                }
                .frame(height: 32)
                
                StyledLabel(
                    title: "Reset",
                    systemImageName: "arrow.uturn.backward.circle.fill",
                    color: .red.opacity(0.8)) {
                        self.progress = 0
                    }
                    .frame(height: 32)
                
        }
            .padding(64)
        
    }
    
}
