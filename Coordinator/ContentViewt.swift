//
//  ContentView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/23/26.
//

import SwiftUI

let forestGreen = Color(hex: "4682b4") //014421


struct ContentView5: View {

    @State private var titleOpacity: CGFloat = 0.0
    @State private var pulse: Bool = false
    @State private var buttonOffset: CGFloat = 0

//    @State private var stars: [Star] = []

    var body: some View {
        ZStack {
            
            Color.darkBlue.ignoresSafeArea()
            
            background

//            starField

            VStack(spacing: 24) {

                title
                
                Text("Some New Text")
                    .padding(.horizontal, .small)
                    .padding(.vertical, 64)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(1))
                    .clipShape(.rect(cornerRadius: 16))
                    .geometryGroup()
                    .compositingGroup()
                    .shadow(color: .white.opacity(0.3), radius: 8, x: 0, y: 0)
                
                Text("Some New Text")
                    .padding(.horizontal, .small)
                    .padding(.vertical, 64)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(1))
                    .clipShape(.rect(cornerRadius: 16))
                    .geometryGroup()
                    .compositingGroup()
                    .shadow(color: .white.opacity(0.3), radius: 8, x: 0, y: 0)
                
                Text("Some New Text")
                    .padding(.horizontal, .small)
                    .padding(.vertical, 64)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(1))
                    .clipShape(.rect(cornerRadius: 16))
                    .geometryGroup()
                    .compositingGroup()
                    .shadow(color: .white.opacity(0.3), radius: 8, x: 0, y: 0)

//                findSomeoneButton

//                heart

                Spacer(minLength: 0)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
        }
        .onAppear {
//            self.generateStarsIfNeeded()

            withAnimation(.easeOut(duration: 0.6)) {
                self.titleOpacity = 1.0
            }

            // Start repeating pulse + bob.
            self.startPulse()
        }
    }

}

// MARK: - Pieces

private extension ContentView5 {

    var background: some View {
        LinearGradient(
            colors: [.black, .black.opacity(0.65), .black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    var title: some View {
        Text("Welcome")
            .font(.system(size: 48, weight: .bold))
            .foregroundColor(.darkBlue)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var findSomeoneButton: some View {
        Button {
            self.triggerTapPulse()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(self.pulse ? Color.purple.opacity(0.5) : Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(Color.white.opacity(self.pulse ? 0.25 : 0.12), lineWidth: 1)
                    )
                    .shadow(color: Color.purple.opacity(self.pulse ? 0.55 : 0.25), radius: self.pulse ? 18 : 10)

                Text("Find Someone")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .overlay {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.white.opacity(0.9), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 40
                                )
                            )
                            .opacity(self.pulse ? 1.0 : 0.0)
                            .blur(radius: self.pulse ? 10 : 0)
                            .scaleEffect(self.pulse ? 1.4 : 0.6)
                            .allowsHitTesting(false)
                    }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
        }
        .buttonStyle(.plain)
        .offset(y: self.buttonOffset)
    }

    var heart: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 34, weight: .semibold))
            .foregroundColor(.pink)
            .scaleEffect(self.pulse ? 1.12 : 1.0)
            .shadow(color: .pink.opacity(self.pulse ? 0.55 : 0.25), radius: self.pulse ? 14 : 8)
            .offset(y: 6)
            .animation(.spring(response: 0.45, dampingFraction: 0.55), value: self.pulse)
    }

//    var starField: some View {
//        GeometryReader { geo in
//            ZStack {
//                ForEach(self.stars) { star in
//                    Circle()
//                        .fill(Color.white.opacity(star.opacity))
//                        .frame(width: star.size, height: star.size)
//                        .position(
//                            x: star.x * geo.size.width,
//                            y: star.y * geo.size.height
//                        )
//                        .blur(radius: star.blur)
//                }
//            }
//            .rotationEffect(.degrees(self.pulse ? 1.2 : -1.2))
//            .animation(.linear(duration: 6).repeatForever(autoreverses: true), value: self.pulse)
//            .allowsHitTesting(false)
//        }
//        .ignoresSafeArea()
//    }

}

// MARK: - Actions

private extension ContentView5 {

    func startPulse() {
        // Repeating pulse
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            self.pulse = true
        }

        // Repeating bob
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            self.buttonOffset = -14
        }
    }

    func triggerTapPulse() {
        // Quick tap "kick" that returns to the repeating state cleanly.
        let kick = Animation.spring(response: 0.35, dampingFraction: 0.55)

        withAnimation(kick) {
            self.buttonOffset = -22
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(kick) {
                self.buttonOffset = -14
            }
        }
    }
//
//    func generateStarsIfNeeded() {
//        guard self.stars.isEmpty else { return }
//
//        self.stars = (0..<28).map { _ in
//            Star(
//                x: CGFloat.random(in: 0...1),
//                y: CGFloat.random(in: 0...1),
//                size: CGFloat.random(in: 1...5),
//                opacity: CGFloat.random(in: 0.03...0.10),
//                blur: CGFloat.random(in: 0...1.2)
//            )
//        }
//    }

}

// MARK: - Model
//
//private struct Star: Identifiable {
//    let id: UUID = UUID()
//    let x: CGFloat
//    let y: CGFloat
//    let size: CGFloat
//    let opacity: CGFloat
//    let blur: CGFloat
//}

// MARK: - Preview

#Preview {
    ContentView5()
}
