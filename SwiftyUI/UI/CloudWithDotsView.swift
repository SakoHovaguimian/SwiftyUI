//
//  CloudWithDotsView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 10/1/24.
//


import SwiftUI

struct CloudWithDotsView: View {
    @State private var showCloud = false

    var body: some View {
        VStack {
            if !showCloud {
                DotsAnimationView(showCloud: $showCloud)
                    .frame(height: 150)
            } else {
                ZStack {
                    CloudShape()
                        .fill(Color.white)
                        .frame(width: 250, height: 150)
                        .shadow(radius: 5)

                    Text("Your text here")
                        .font(.title3)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showCloud)
    }
}

struct DotsAnimationView: View {
    @Binding var showCloud: Bool
    @State private var animate = false

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 10) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 10, height: 10)
                        .offset(y: animate ? -50 : 0)
                        .animation(
                            Animation.easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: animate
                        )
                }
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .onAppear {
                animate = true
                // Total duration: (duration + delay) * repeatCount
//                let totalDuration = (0.5 + 0.2 * 2) * 5
//                DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
//                    showCloud = true
//                }
            }
        }
    }
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Calculate positions and sizes based on rect
        let width = rect.width
        let height = rect.height

        // Cloud arcs
        let arcCenter1 = CGPoint(x: width * 0.25, y: height * 0.5)
        let arcCenter2 = CGPoint(x: width * 0.5, y: height * 0.3)
        let arcCenter3 = CGPoint(x: width * 0.75, y: height * 0.5)
        let radius1 = width * 0.2
        let radius2 = width * 0.25
        let radius3 = width * 0.2

        path.addArc(center: arcCenter1, radius: radius1, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addArc(center: arcCenter2, radius: radius2, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addArc(center: arcCenter3, radius: radius3, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)

        // Bottom of the cloud
        path.addRect(CGRect(x: width * 0.1, y: height * 0.5, width: width * 0.8, height: height * 0.2))

        return path
    }
}

struct CloudContentView: View {
    var body: some View {
        CloudWithDotsView()
            .padding()
            .background(Color.blue.opacity(0.1))
    }
}

#Preview {
    @Previewable @State var showCloud = true
    DotsAnimationView(showCloud: $showCloud)
}
