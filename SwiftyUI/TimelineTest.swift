//
//  TimelineTest.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/5/25.
//

import SwiftUI

struct ClockView: View {
    var body: some View {
        SwiftUI.TimelineView(.animation(minimumInterval: 1.0)) { context in
            let date = context.date
            VStack {
                Text(dateFormatter.string(from: date))
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                Text(dateOnlyFormatter.string(from: date))
                    .font(.title)
                    .padding()
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .long
        return formatter
    }

    private var dateOnlyFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

#Preview {
    ClockView()
}
