//
//  SleepSeriesType.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/15/25.
//


//
//  SleepSeriesType.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/15/25.
//


import SwiftUI
import Charts

// MARK: - Data Models

enum SleepSeriesType: String, Plottable, CaseIterable {
    case demand = "Demand"
    case actual = "Time asleep"
    
    var color: Color {
        switch self {
        case .demand: return Color(red: 135/255, green: 224/255, blue: 119/255) // Light Green
        case .actual: return Color(red: 90/255, green: 135/255, blue: 250/255)  // Blue
        }
    }
}

struct SleepDataPoint: Identifiable {
    let id = UUID()
    let dayIndex: Int
    let dayLabel: String
    let hours: Double
    let type: SleepSeriesType
    
    // Helper to display Double (9.5) as String ("9:30")
    var timeLabel: String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        return String(format: "%d:%02d", h, m)
    }
}

// MARK: - Chart View

struct SleepLineChart: View {
    
    let data: [SleepDataPoint]
    
    // Calculation for summary stats (mocked logic based on typical usage)
    private var averageSleep: String {
        let actuals = data.filter { $0.type == .actual }
        let total = actuals.reduce(0.0) { $0 + $1.hours }
        let avg = actuals.isEmpty ? 0 : total / Double(actuals.count)
        
        let h = Int(avg)
        let m = Int((avg - Double(h)) * 60)
        return "\(h)h \(m)m"
    }
    
    var body: some View {
        
        BaseChartCardView(
            title: "Sleep Goal vs Actual",
            attributedMessage: AttributedText {
                
                Text(self.averageSleep + " ")
                    .font(.title)
                    .foregroundStyle(.black)
                
                Text("avg. time asleep")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                
            },
            description: "Duration tracking over the last 7 days") {
                
                VStack(spacing: 8) {
                    
                    chart()
                    
                }
                
            }
        
    }
    
    private func chart() -> some View {
        
        Chart {
            ForEach(self.data) { item in
                
                // 1. The Line
                LineMark(
                    x: .value("Day", item.dayIndex),
                    y: .value("Hours", item.hours)
                )
                .foregroundStyle(by: .value("Type", item.type))
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                // 2. The Points
                PointMark(
                    x: .value("Day", item.dayIndex),
                    y: .value("Hours", item.hours)
                )
                .foregroundStyle(by: .value("Type", item.type))
                .symbolSize(60)
                // Annotations (Time labels)
                .annotation(position: item.type == .demand ? .top : .bottom, spacing: 10) {
                    Text(item.timeLabel)
                        .font(.caption)
                        .foregroundStyle(item.type.color)
                }
            }
        }
        .chartForegroundStyleScale([
            SleepSeriesType.demand: SleepSeriesType.demand.color,
            SleepSeriesType.actual: SleepSeriesType.actual.color
        ])
        .chartYAxis(.hidden)
        
        // --- THE FIX IS HERE ---
        
        .chartXAxis {
            // 2. Use explicit values to match the domain exactly
            AxisMarks(preset: .aligned,
                      values: [0,1,2,3,4,5,6]) { value in
                
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.gray.opacity(0.3))
                
                AxisValueLabel(collisionResolution: .greedy) {
                    if let intValue = value.as(Int.self),
                       let match = data.first(where: { $0.dayIndex == intValue }) {
                        
                        Text(match.dayLabel)
                            .font(.caption)
                            .foregroundStyle(.black)
                    } else {
                        Text("FUCK")
                    }
                }
            }
        }
        .chartLegend(.hidden)
        // Add horizontal padding to the View itself so the edge labels (Su, Sa)
        // aren't flush against the screen edge.
//        .padding(.horizontal, 12)
//        .padding(.vertical, 10)
    }
    
}

// MARK: - Dummy Data & Preview

extension SleepDataPoint {
    static let DUMMY_DATA: [SleepDataPoint] = [
        // Demand (Green)
        .init(dayIndex: 0, dayLabel: "Su", hours: 9.5, type: .demand),  // 9:30
        .init(dayIndex: 1, dayLabel: "Mo", hours: 8.23, type: .demand), // 8:14
        .init(dayIndex: 2, dayLabel: "Tu", hours: 8.11, type: .demand), // 8:07
        .init(dayIndex: 3, dayLabel: "We", hours: 8.5, type: .demand),  // 8:30
        .init(dayIndex: 4, dayLabel: "Th", hours: 10.18, type: .demand),// 10:11
        .init(dayIndex: 5, dayLabel: "Fr", hours: 10.4, type: .demand), // 10:24
        .init(dayIndex: 6, dayLabel: "Sa", hours: 9.76, type: .demand), // 9:46
        
        // Actual (Blue)
        .init(dayIndex: 0, dayLabel: "Su", hours: 9.08, type: .actual), // 9:05
        .init(dayIndex: 1, dayLabel: "Mo", hours: 7.5, type: .actual),  // 7:30
        .init(dayIndex: 2, dayLabel: "Tu", hours: 5.35, type: .actual), // 5:21
        .init(dayIndex: 3, dayLabel: "We", hours: 3.53, type: .actual), // 3:32
        .init(dayIndex: 4, dayLabel: "Th", hours: 6.4, type: .actual),  // 6:24
        .init(dayIndex: 5, dayLabel: "Fr", hours: 8.5, type: .actual),  // 8:30
        .init(dayIndex: 6, dayLabel: "Sa", hours: 10.0, type: .actual)  // 10:00
    ]
}

#Preview {
    ZStack {
        Color(white: 0.95).ignoresSafeArea()
        SleepLineChart(data: SleepDataPoint.DUMMY_DATA)
            .frame(height: 300)
    }
}
