//
//  ChartDataPoint.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/23/26.
//

import SwiftUI
import Charts

// MARK: - Data Model
struct ChartDataPoint2: Identifiable {
    let id = UUID()
    let index: Int
    let value: Double
}

// MARK: - Chart Style Enum
enum FinancialChartStyle {
    case line
    case lineArea
}

// MARK: - Main Chart View
struct FinancialChartView: View {
    let title: String
    let subtitle: String
    let trendText: String
    let isUp: Bool
    
    let style: FinancialChartStyle
    let chartColor: Color
    let titleColor: Color
    
    let data: [ChartDataPoint2]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(titleColor)
                
                Text(trendText)
                    .font(.system(size: 14, weight: .semibold))
                    // Uses red when down, green when up
                    .foregroundColor(isUp ? .green : .red)
            }
            
            Text(subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.bottom, 16)
            
            // Chart
            Chart(data) { point in
                // Base Line Mark
                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(chartColor)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                
                // Optional Area Fill
                if style == .lineArea {
                    AreaMark(
                        x: .value("Index", point.index),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                chartColor.opacity(0.3),
                                chartColor.opacity(0.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            // Hiding axes for the clean look
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            // .automatic(includesZero: false) prevents the chart from flattening
            // when dealing with large monetary values
            .chartYScale(domain: .automatic(includesZero: false))
            .frame(height: 140)
        }
    }
}

// MARK: - Previews
struct FinancialChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Dark background for Preview 1
            Color(red: 0.04, green: 0.09, blue: 0.18).ignoresSafeArea()
            
            VStack(spacing: 60) {
                // 1. Dark Mode / Basic Line Chart
                FinancialChartView(
                    title: "$2,489,510.19",
                    subtitle: "Portfolio",
                    trendText: "▼ $5,817.45 (2.43%)",
                    isUp: false,
                    style: .line,
                    chartColor: .white,
                    titleColor: Color(red: 0.2, green: 0.5, blue: 1.0),
                    data: sampleDataDown
                )
                .padding()
                
                // 2. Light Mode / Line Area Chart
                FinancialChartView(
                    title: "$7,892,876.31",
                    subtitle: "Net Worth",
                    trendText: "▲ $4,716.81 (0.10%)",
                    isUp: true,
                    style: .lineArea,
                    chartColor: Color(red: 0.5, green: 0.7, blue: 1.0),
                    titleColor: Color(red: 0.1, green: 0.4, blue: 0.9),
                    data: sampleDataUp
                )
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .padding()
            }
        }
    }
    
    // Sample Data
    static let sampleDataDown: [ChartDataPoint2] = [
        ChartDataPoint2(index: 0, value: 100),
        ChartDataPoint2(index: 1, value: 92),
        ChartDataPoint2(index: 2, value: 85),
        ChartDataPoint2(index: 3, value: 89),
        ChartDataPoint2(index: 4, value: 75),
        ChartDataPoint2(index: 5, value: 60),
        ChartDataPoint2(index: 6, value: 60),
        ChartDataPoint2(index: 7, value: 50),
        ChartDataPoint2(index: 8, value: 53)
    ]
    
    static let sampleDataUp: [ChartDataPoint2] = [
        ChartDataPoint2(index: 0, value: 50),
        ChartDataPoint2(index: 1, value: 48),
        ChartDataPoint2(index: 2, value: 55),
        ChartDataPoint2(index: 3, value: 55),
        ChartDataPoint2(index: 4, value: 65),
        ChartDataPoint2(index: 5, value: 62),
        ChartDataPoint2(index: 6, value: 70),
        ChartDataPoint2(index: 7, value: 80)
    ]
}
