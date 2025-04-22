//
//  ScratcherView.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI

let image = Image(.prize)

struct ScratchCardPathMaskView: View {
    @State var points = [CGPoint]()
    
    var body: some View {
        ZStack {
            // MARK: Scratchable overlay view
            RoundedRectangle(cornerRadius: 20)
                .fill(.yellow)
                .frame(width: 250, height: 250)

            // MARK: Hidden content view
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
                .mask(
                    Path { path in
                        path.addLines(points)
                    }.stroke(style: StrokeStyle(lineWidth: 30, lineCap: .round, lineJoin: .round))
                )
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged({ value in
                            points.append(value.location)
                        })
                )
        }
    }
}

struct Line {
    var points = [CGPoint]()
    var lineWidth: Double = 50.0
}

struct ScratchCardCanvasMaskView: View {
    @State private var currentLine = Line()
    @State private var lines = [Line]()

    var body: some View {
        ZStack {
            // MARK: Scratchable overlay view
            RoundedRectangle(cornerRadius: 20)
                .fill(.red)
                .frame(width: 250, height: 250)

            // MARK: Hidden content view
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
                .mask(
                    Canvas { context, _ in
                        for line in lines {
                            var path = Path()
                            path.addLines(line.points)
                            context.stroke(path,
                                           with: .color(.white),
                                           style: StrokeStyle(lineWidth: line.lineWidth,
                                                              lineCap: .round,
                                                              lineJoin: .round)
                            )
                        }
                    }
                )
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged({ value in
                            let newPoint = value.location
                            currentLine.points.append(newPoint)
                            lines.append(currentLine)
                        }).onEnded({ _ in
                            self.currentLine = .init()
                        })
                )
        }
    }
}

#Preview {
    ScratchCardPathMaskView()
}

#Preview {
    ScratchCardCanvasMaskView()
}
