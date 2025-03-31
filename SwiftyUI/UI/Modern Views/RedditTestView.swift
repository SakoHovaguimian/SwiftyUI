//
//  RedditTestView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/24/25.
//

import SwiftUI

struct RedditTestView: View {
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(0..<20) { _ in
                    NewCard()
                        .padding(.horizontal)
                        .containerRelativeFrame(.vertical)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .containerRelativeFrame(.vertical, count: 1, spacing: 0)
        .scrollClipDisabled()
    }
}

private struct NewCard: View {
    var body: some View {
        ZStack {
            CardContent()
                .padding(.top, 4)
                .padding(.bottom, 24)
        }
        .scrollTransition { content, phase in
            content.opacity(phase.isIdentity ? 1 : 0.5)
        }
    }
}

private struct CardContent: View {
    var body: some View {
        VStack {
            Spacer()

            Text("Words")
                .font(.title)

            Spacer()

            HStack {
                Text("Postcard for Mia")

                Spacer()

                Button {
                } label: {
                    Image(systemName: "phone")
                        .foregroundStyle(.white)
                }
            }

            Spacer()
        }
        .padding()
        .background(.red)
        .cornerRadius(30)
    }
}

#Preview {
    RedditTestView()
}
