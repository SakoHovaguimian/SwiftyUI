//
//  PixelTileView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/31/26.
//

import SwiftUI
import Combine

// MARK: - PixelTileView

struct PixelTileView: View {

    // MARK: Configuration

    let pattern: [[Int]]
    var color: Color = .white

    var tileSize: CGFloat = 64
    var pixelSize: CGFloat = 14
    var spacing: CGFloat = 4

    var rotation: Double = 0
    var brightness: Int = 1
    var shadowBrightness: Int = 1

    var animationDuration: Double = 0.35
    var interval: Double = 0.55

    // MARK: State

    @State private var step: Int = 0

    private var timer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
    }

    private var frames: [[Int]] {

        guard let first = pattern.first else { return [] }

        // If a single "frame" is provided, treat it as a sequence of single-pixel frames.
        // Example: [[1, 5, 9]] -> [[1], [5], [9]]
        if pattern.count == 1 { return first.map { [$0] } }

        // If every frame is a single pixel, merge them into one frame + an empty frame for a blink.
        // Example: [[1], [5], [9]] -> [[1, 5, 9], []]
        let allSingles = pattern.allSatisfy { $0.count == 1 }

        if allSingles {
            let merged = pattern.compactMap { $0.first }
            return [merged, []]
        }

        return pattern
    }

    var body: some View {

        let onSet = Set(frames.isEmpty ? [] : frames[step])

        return VStack(spacing: spacing) {

            ForEach(0..<3, id: \.self) { row in

                HStack(spacing: spacing) {

                    ForEach(0..<3, id: \.self) { col in

                        let index = row * 3 + col + 1

                        PixelCell(
                            isOn: onSet.contains(index),
                            size: pixelSize,
                            color: color,
                            brightness: brightness,
                            shadowBrightness: shadowBrightness
                        )
                        .rotationEffect(.degrees(rotation))
                    }
                }
            }
        }
        .frame(width: tileSize, height: tileSize)
        .onReceive(timer) { _ in

            guard !frames.isEmpty else { return }

            withAnimation(.smooth(duration: animationDuration)) {
                step = (step + 1) % frames.count
            }
        }
        .onChange(of: frames.count) { _, _ in
            if step >= frames.count { step = 0 }
        }
    }
}

// MARK: - PixelCell

struct PixelCell: View {

    let isOn: Bool
    let size: CGFloat
    let color: Color

    var brightness: Int = 1
    var shadowBrightness: Int = 1

    var body: some View {

        ZStack {

            ForEach(0..<brightness, id: \.self) { _ in
                Rectangle()
            }
        }
        .foregroundStyle(isOn ? color : .clear)
        .frame(width: size, height: size)
        .modifier(
            ShadowStack(
                enabled: isOn,
                color: color,
                count: shadowBrightness
            )
        )
    }
}

// MARK: - ShadowStack

struct ShadowStack: ViewModifier {

    let enabled: Bool
    let color: Color
    let count: Int

    func body(content: Content) -> some View {

        content
            .overlay(
                ForEach(0..<count, id: \.self) { _ in
                    content.shadow(
                        color: enabled ? color : .clear,
                        radius: 10,
                        x: 0,
                        y: 0
                    )
                }
            )
    }
}

// MARK: - Previews

#Preview("PixelTileView – Permutations") {

    let patterns: [(String, [[Int]])] = [
        ("Corners", [[1, 3, 7, 9]]),
        ("X", [[1, 5, 9], [3, 5, 7]]),
        ("Plus", [[2, 4, 5, 6, 8]]),
        ("Diagonal", [[1], [5], [9]]),                // merges -> [[1,5,9], []]
        ("Scan Row", [[1, 2, 3], [4, 5, 6], [7, 8, 9]]),
        ("Ping", [[1], [2], [3], [6], [9], [8], [7], [4]]),
        ("Dot Pulse", [[5]]),                         // single list -> [[5]]
        ("Smile-ish", [[2, 8], [1, 3, 7, 9], [2, 8]]),
    ]

    struct TileCard: View {

        let title: String
        let pattern: [[Int]]
        let config: (color: Color, tile: CGFloat, pixel: CGFloat, spacing: CGFloat, rot: Double, bright: Int, shadow: Int, dur: Double, interval: Double)

        var body: some View {

            VStack(alignment: .leading, spacing: 10) {

                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .opacity(0.9)

                PixelTileView(
                    pattern: pattern,
                    color: config.color,
                    tileSize: config.tile,
                    pixelSize: config.pixel,
                    spacing: config.spacing,
                    rotation: config.rot,
                    brightness: config.bright,
                    shadowBrightness: config.shadow,
                    animationDuration: config.dur,
                    interval: config.interval
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .padding(14)
            .background(.black.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    let configs: [(String, (Color, CGFloat, CGFloat, CGFloat, Double, Int, Int, Double, Double))] = [
        ("Indigo Glow", (.indigo, 100, 32, 5, 0, 1, 3, 0.35, 0.55)),
        ("Mint Soft", (.mint, 72, 14, 4, 0, 1, 1, 0.25, 0.65)),
        ("Hot Pink", (.pink, 76, 15, 4, 0, 2, 2, 0.35, 0.50)),
        ("Big Pixels", (.cyan, 92, 20, 6, 0, 1, 2, 0.40, 0.70)),
        ("Rotated", (.orange, 80, 16, 5, 10, 1, 2, 0.35, 0.55)),
        ("Very Bright", (.purple, 80, 16, 5, 0, 4, 2, 0.35, 0.55)),
        ("Slow", (.green, 80, 16, 5, 0, 1, 2, 0.65, 1.10)),
        ("Fast", (.red, 80, 16, 5, 0, 1, 2, 0.20, 0.30)),
    ]

    return ScrollView {

        LazyVStack(alignment: .leading, spacing: 16) {

            ForEach(patterns.indices, id: \.self) { idx in

                let (name, pattern) = patterns[idx]

                VStack(alignment: .leading, spacing: 12) {

                    Text(name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .padding(.horizontal, 6)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        ForEach(configs.indices, id: \.self) { c in

                            let (label, raw) = configs[c]

                            TileCard(
                                title: label,
                                pattern: pattern,
                                config: (
                                    raw.0,
                                    raw.1,
                                    raw.2,
                                    raw.3,
                                    raw.4,
                                    raw.5,
                                    raw.6,
                                    raw.7,
                                    raw.8
                                )
                            )
                        }
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .padding(16)
    }
    .background(
        LinearGradient(
            colors: [
                .black,
                .black.opacity(0.85),
                .black.opacity(0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    )
}
