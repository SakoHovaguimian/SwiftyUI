//
//  ImageTransition.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/29/26.
//

import SwiftUI

struct SymbolTransitionDemo: View {

    @State private var isOn = false

    var body: some View {
        VStack {
            Button {
                withAnimation {
                    isOn.toggle()
                }
            } label: {
                Label("Toggle Favorite", systemImage: isOn ? "checkmark": "heart")
            }
            .contentTransition(.symbolEffect(.replace))
        }
        .font(.largeTitle)
    }
}

import SwiftUI

struct SymbolTransitionConditional: View {

    @State private var isPlaying = false

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Image(systemName: isPlaying ? "heart.fill" : "house.fill")
                    .symbolEffect(.bounce.down, value: isPlaying)
            }
            .animation(.snappy, value: isPlaying)

            Button(isPlaying ? "Pause" : "Play") {
                withAnimation(.snappy) {
                    isPlaying.toggle()
                }
            }
        }
    }
}

import SwiftUI

struct LabelTransitionDemo: View {

    @State private var sent = false

    var body: some View {
        Button {
            withAnimation(.snappy) {
                sent.toggle()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: sent ? "paperplane.fill" : "paperplane")
                    .contentTransition(.symbolEffect(.replace))
                    .symbolEffect(.pulse, value: sent)

                Text(sent ? "Sent" : "Send")
                    .contentTransition(.opacity)
            }
            .font(.system(size: 20, weight: .semibold))
        }
        .buttonStyle(.plain)
    }
}

struct ColorSymbolTest: View {
    @State private var animationsRunning = false

    var body: some View {

        Button("Start Animations") {
            withAnimation {
                animationsRunning.toggle()
            }
        }

        VStack {
            HStack {
                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.iterative, value: animationsRunning)

                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.cumulative, value: animationsRunning)

                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.reversing.iterative, value: animationsRunning)

                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.reversing.cumulative, value: animationsRunning)
            }

            HStack {
                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.iterative, options: .repeating, value: animationsRunning)

                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.cumulative, options: .repeat(3), value: animationsRunning)

                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.reversing.iterative, options: .speed(3), value: animationsRunning)

                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.reversing.cumulative, options: .repeat(3).speed(3), value: animationsRunning)
            }
        }
        .font(.largeTitle)
    }
}

#Preview {
    SymbolTransitionDemo()
}

#Preview {
    SymbolTransitionConditional()
}

#Preview {
    LabelTransitionDemo()
}

#Preview {
    ColorSymbolTest()
}
