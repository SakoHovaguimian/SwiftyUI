//
//  ChartCarousel.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/5/25.
//

import SwiftUI
import Charts

struct ChartCarousel: View {
    
    var body: some View {
        carouselView()
    }
    
    @ViewBuilder
    private func carouselView() -> some View {
        
        ScrollView(.horizontal) {
            
            HStack(spacing: 8) {
                
                cardView(
                    title: "Weekly Capture Volume",
                    subtitle: "See which days your team captures the most client media."
                ) {
                    chart1()
                }
                .asButton { }

                cardView(
                    title: "Client Engagement Trend",
                    subtitle: "Track how often clients are viewing their results over time."
                ) {
                    chart2()
                }
                .asButton { }

                cardView(
                    title: "Media Mix Breakdown",
                    subtitle: "Understand your balance of before, after, and video content."
                ) {
                    chart3()
                }
                .asButton { }
                
            }
            .scrollTargetLayout()
            
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollClipDisabled()
        .safeAreaPadding(.horizontal, .appLarge)
        
    }
    
    @ViewBuilder
    private func cardView(title: String,
                          subtitle: String,
                          content: () -> some View) -> some View {
        
        VStack(alignment: .leading, spacing: 2) {
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
            
            content()
                .padding(.top, 16)
                .frame(height: 160)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .containerRelativeFrame([.horizontal])
        .background(Color.white)
        .clipShape(.rect(cornerRadius: 24))
        .shadow(
            color: Color.black.opacity(0.15),
            radius: 10,
            x: 0,
            y: 0
        )
        
    }
    
    @ViewBuilder
    private func chart1() -> some View {
        
        let data = weeklyMediaData
        
        Chart {
            
            let dayOrder: [String: Int] = [
                "Sun": 0,
                "Mon": 1,
                "Tue": 2,
                "Wed": 3,
                "Thu": 4,
                "Fri": 5,
                "Sat": 6
            ]

            let dailyTotals: [DailyMediaTotal] = Dictionary(grouping: data, by: \.dayLabel)
                .map { dayLabel, items in
                    DailyMediaTotal(
                        dayLabel: dayLabel,
                        totalCount: items.reduce(0) { $0 + Int($1.count) }
                    )
                }
                .sorted { lhs, rhs in
                    (dayOrder[lhs.dayLabel] ?? 0) < (dayOrder[rhs.dayLabel] ?? 0)
                }
            
            ForEach(dailyTotals, id: \.self) { item in
                BarMark(
                    x: .value("Day", item.dayLabel),
                    y: .value("Media Count", item.totalCount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.mint, .cyan],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
        }
        
    }
    
    @ViewBuilder
    private func chart2() -> some View {
        
        let data = engagementData
        let lineColor = Color(red: 0.3, green: 0.5, blue: 0.9)
        
        Chart {
            ForEach(data) { point in
                AreaMark(
                    x: .value("Day", point.dayLabel),
                    y: .value("Sessions", point.sessionCount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [lineColor.opacity(0.3), lineColor.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
                
                LineMark(
                    x: .value("Day", point.dayLabel),
                    y: .value("Sessions", point.sessionCount)
                )
                .foregroundStyle(lineColor)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Day", point.dayLabel),
                    y: .value("Sessions", point.sessionCount)
                )
                .foregroundStyle(lineColor)
                .symbolSize(65)
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 20, 40, 60]) {
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.gray.opacity(0.3))
                AxisValueLabel()
                    .foregroundStyle(Color.gray)
            }
        }
        .chartXAxis {
            AxisMarks { value in
                if let str = value.as(String.self), (str == "Aug 12" || str == "Aug 18") {
                    AxisValueLabel()
                        .foregroundStyle(Color.gray)
                }
            }
        }
        
    }
    
    @ViewBuilder
    private func chart3() -> some View {
        
        VStack(spacing: 8) {
            
            Chart {
                ForEach(treatmentData) { segment in
                    BarMark(
                        x: .value("Percentage", segment.percentage),
                        y: .value("Category", "Mix")
                    )
                    .foregroundStyle(segment.color)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .clipShape(.rect(cornerRadius: 0))
            .frame(height: 50)
            .padding(.top, -8)
            
            // Legend
            VStack(spacing: 8) {
                ForEach(treatmentData) { segment in
                    HStack {
                        Circle()
                            .fill(segment.color)
                            .frame(width: 8, height: 8)
                        Text(segment.category)
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.8))
                        Spacer()
                        Text("\(String(format: "%.1f", segment.percentage))%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
            }
            
        }
        
    }
    
    
}

#Preview {
    
    AppBaseView {
        ChartCarousel()
    }
    
}
