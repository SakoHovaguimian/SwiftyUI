//
//  SampleCharts.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/13/25.
//

import SwiftUI
import Charts

// TODO: -
/// Use real enum values
/// Have real types for the charts
/// Use real colors for correct metric
/// Use real spacing, appFont values
/// Use real textColor colors
/// `self` in correct places
/// move previews to somehwere better
/// move types into top of file

// 1. Define the new Media Types
enum MediaKind1: String, CaseIterable, Plottable {
    case collage = "Collage"
    case photo = "Photo"
    case diagram = "Diagram"
    
    var color: Color {
        switch self {
        case .collage: return Color.indigo
        case .photo: return Color.blue
        case .diagram: return Color.orange
        }
    }
}

// 2. Define the Weekly Data Structure
struct WeeklyMediaDataPoint: Identifiable {
    let id = UUID()
    let weekLabel: String
    let mediaKind: MediaKind1
    let count: Int
}

struct ClientGrowthPoint: Identifiable {
    let id = UUID()
    let dateLabel: String
    let activeClients: Int
}

let weeklyMediaData1: [WeeklyMediaDataPoint] = [
    // Week 1: Oct 1
    .init(weekLabel: "Oct 1", mediaKind: .collage, count: 15),
    .init(weekLabel: "Oct 1", mediaKind: .photo, count: 45),
    .init(weekLabel: "Oct 1", mediaKind: .diagram, count: 8),

    // Week 2: Oct 8
    .init(weekLabel: "Oct 8", mediaKind: .collage, count: 18),
    .init(weekLabel: "Oct 8", mediaKind: .photo, count: 52),
    .init(weekLabel: "Oct 8", mediaKind: .diagram, count: 12),

    // Week 3: Oct 15
    .init(weekLabel: "Oct 15", mediaKind: .collage, count: 12),
    .init(weekLabel: "Oct 15", mediaKind: .photo, count: 38),
    .init(weekLabel: "Oct 15", mediaKind: .diagram, count: 5),

    // Week 4: Oct 22
    .init(weekLabel: "Oct 22", mediaKind: .collage, count: 25),
    .init(weekLabel: "Oct 22", mediaKind: .photo, count: 60),
    .init(weekLabel: "Oct 22", mediaKind: .diagram, count: 15),
]

let clientGrowthData: [ClientGrowthPoint] = [
    .init(dateLabel: "Oct 1",  activeClients: 120),
    .init(dateLabel: "Oct 8",  activeClients: 145),
    .init(dateLabel: "Oct 15", activeClients: 162),
    .init(dateLabel: "Oct 22", activeClients: 158),
    .init(dateLabel: "Oct 29", activeClients: 185),
    .init(dateLabel: "Oct 30", activeClients: 210)
]

enum ActivityKind: String, CaseIterable, Plottable {
    case collage = "Collage"
    case photo = "Photo"
    case diagram = "Diagram"
    
    var color: Color {
        switch self {
        case .collage: return Color.indigo
        case .photo: return Color.blue
        case .diagram: return Color.orange
        }
    }
}

struct PractitionerActivityPoint: Identifiable {
    let id = UUID()
    let name: String
    let kind: ActivityKind
    let count: Int
}

let practitionerData: [PractitionerActivityPoint] = [
    // Dr. Smith
    .init(name: "Dr. Smith", kind: .collage, count: 12),
    .init(name: "Dr. Smith", kind: .photo, count: 40),
    .init(name: "Dr. Smith", kind: .diagram, count: 5),
    
    // Sarah J (Top performer)
    .init(name: "Sarah J", kind: .collage, count: 25),
    .init(name: "Sarah J", kind: .photo, count: 65),
    .init(name: "Sarah J", kind: .diagram, count: 15),
    
    // Nurse Joy
    .init(name: "Nurse Joy", kind: .collage, count: 18),
    .init(name: "Nurse Joy", kind: .photo, count: 35),
    .init(name: "Nurse Joy", kind: .diagram, count: 8),
    
    // Dr. Lee
    .init(name: "Dr. Lee", kind: .collage, count: 10),
    .init(name: "Dr. Lee", kind: .photo, count: 28),
    .init(name: "Dr. Lee", kind: .diagram, count: 12),
]

// 4. The Updated View
struct WeeklyMediaCard3: View {
    let data: [WeeklyMediaDataPoint]
    
    // Calculate total for the entire period shown
    private var totalMediaPeriod: Int {
        data.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        
        BaseChartCardView(
            title: "Photo Activity Volume",
            attributedMessage: AttributedText {
                
                Text("\(totalMediaPeriod) ")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("captures")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
            },
            description: "Media Captured in the last 6 weeks") {
                
                VStack(spacing: 6) {
                    
                    Chart {
                        ForEach(data) { item in
                            BarMark(
                                x: .value("Week", item.weekLabel),
                                y: .value("Count", item.count)
                            )
                            .foregroundStyle(by: .value("Kind", item.mediaKind.rawValue))
                        }
                    }
                    .chartForegroundStyleScale([
                        MediaKind1.collage.rawValue: MediaKind1.collage.color,
                        MediaKind1.photo.rawValue: MediaKind1.photo.color,
                        MediaKind1.diagram.rawValue: MediaKind1.diagram.color
                    ])
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                .foregroundStyle(Color.gray.opacity(0.3))
                            AxisValueLabel() {
                                if let intValue = value.as(Int.self) {
                                    Text("\(intValue)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks { value in
                            AxisValueLabel()
                                .font(.caption2)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .chartLegend(.hidden)
                    
                    // Custom Legend
                    HStack(spacing: 16) {
                        Spacer()
                        LegendItem(color: MediaKind1.collage.color, label: "Collage")
                        LegendItem(color: MediaKind1.photo.color, label: "Photo")
                        LegendItem(color: MediaKind1.diagram.color, label: "Diagram")
                        Spacer()
                    }
                    
                }
                
            }
            .frame(height: 300)
    }
}

// 3. The View
struct ClientGrowthCard: View {
    let data: [ClientGrowthPoint]
    
    // Brand color
    let lineColor = Color(red: 0.3, green: 0.5, blue: 0.9)
    
    var body: some View {
        
        BaseChartCardView(
            title: "Client Growth (30 Days)",
            attributedMessage: AttributedText {
                Text("Total Active Clients")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            },
            description: "Clients joined over the past 30 days") {
                
                // Area + Line Chart
                Chart {
                    ForEach(data) { point in
                        // 1. The Gradient Area
                        AreaMark(
                            x: .value("Date", point.dateLabel),
                            y: .value("Clients", point.activeClients)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [lineColor.opacity(0.3), lineColor.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        
                        // 2. The Line
                        LineMark(
                            x: .value("Date", point.dateLabel),
                            y: .value("Clients", point.activeClients)
                        )
                        .foregroundStyle(lineColor)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
    //                     3. The Points (Dots)
                        PointMark(
                            x: .value("Date", point.dateLabel),
                            y: .value("Clients", point.activeClients)
                        )
    //                    .foregroundStyle(Color.white)
                        .foregroundStyle(.blue)
                        .symbol(Circle())
                        .symbolSize(40)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundStyle(Color.gray.opacity(0.3))
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        if let str = value.as(String.self) {
                            // LOGIC: Only show label if it matches the first or last item in the data array
                            if str == data.first?.dateLabel || str == data.last?.dateLabel {
                                AxisValueLabel()
                                    .font(.caption)
    //                                .fontWeight(.medium)
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                }
                
            }
            .frame(height: 300)
    }
    
}

// 4. The View
struct PractitionerActivityCard: View {
    let data: [PractitionerActivityPoint]
    
    // Total for the header
    private var totalActivity: Int {
        data.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        
        BaseChartCardView(
            title: "Practitioner Activity",
            attributedMessage: AttributedText {
                
                Text("\(totalActivity) ")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("logged items")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
            },
            description: "Photos / Sessions Logged (Last 30 Days)",
            chartTopSpacing: 4,
            content: {
                
                VStack(spacing: 6) {
                    
                    Chart {
                        ForEach(data) { item in
                            // Note: For Horizontal Bars, we swap X and Y
                            BarMark(
                                x: .value("Count", item.count),
                                y: .value("Practitioner", item.name)
                            )
                            .foregroundStyle(by: .value("Kind", item.kind.rawValue))
                        }
                    }
                    .chartForegroundStyleScale([
                        ActivityKind.collage.rawValue: ActivityKind.collage.color,
                        ActivityKind.photo.rawValue: ActivityKind.photo.color,
                        ActivityKind.diagram.rawValue: ActivityKind.diagram.color
                    ])
                    // X-Axis (Bottom) now shows the values
                    .chartXAxis {
                        AxisMarks(position: .bottom) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                .foregroundStyle(Color.gray.opacity(0.3))
                            AxisValueLabel()
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    //            // Y-Axis (Leading) now shows the names
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel()
                                .font(.caption)
                            //                        .fontWeight(.medium)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .chartLegend(.hidden)
                    
                    // Custom Legend
                    HStack(spacing: 16) {
                        Spacer()
                        LegendItem(color: ActivityKind.collage.color, label: "Collage")
                        LegendItem(color: ActivityKind.photo.color,   label: "Photo")
                        LegendItem(color: ActivityKind.diagram.color, label: "Diagram")
                        Spacer()
                    }
                    
                }
                
            }
        )
        .frame(height: 300)
        
    }
    
}

struct LegendDot2: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
        }
    }
}

struct MetricScoreCard: View {
    let title: String
    let subtitle: String
    let description: String
    let score: Double // 0-100
    
    // Visual Configuration
    let statusText: String
    let statusColor: Color
    let gradientColors: [Color]
    let legendItems: [LegendDot2]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        // The Big Number
                        Text(String(format: "%.0f%%", score))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        
                        // Subtext
                        Text(subtitle)
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        // Status Badge
                        Text(statusText)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor)
                            .clipShape(Capsule())
                    }
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.gray)
            }
            
            // MARK: - Custom Gauge (Replaces Chart)
            // This ensures the bar is full width, and the dot sits on top without clipping.
            GeometryReader { proxy in
                let dotSize: CGFloat = 24
                let inset: CGFloat = 4
                
                // 1. Calculate the specific travel range
                // Start X (0%) = Inset + Half Dot
                let startX = inset + (dotSize / 2)
                
                // End X (100%) = Width - Inset - Half Dot
                let endX = proxy.size.width - inset - (dotSize / 2)
                
                // The total distance the dot travels
                let travelDistance = endX - startX
                
                // current X = Start + (Total Distance * percentage)
                let currentX = startX + (travelDistance * CGFloat(score / 100.0))
                
                ZStack(alignment: .leading) {
                    // 1. The Gradient Bar
                    RoundedRectangle(cornerRadius: 99)
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 32)
                    
                    // 2. The Indicator Dot
                    Circle()
                        .fill(Color.white)
                        .frame(width: dotSize, height: dotSize)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 1)
                        // 3. Precise Position
                        .position(
                            x: currentX,
                            y: proxy.size.height / 2
                        )
                }
            }
            .frame(height: 32)
            
            // Legend
            HStack(spacing: 12) {
                ForEach(0..<legendItems.count, id: \.self) { index in
                    legendItems[index]
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct UntaggedContentCard: View {
    let untaggedPercentage: Double // 0-100% (Percentage of items WITHOUT tags)
    
    // Logic: Lower is better (0% untagged is perfect)
    private var status: (text: String, color: Color) {
        switch untaggedPercentage {
        case ..<15: return ("Optimized", .green)
        case 15..<40: return ("Attention", .yellow)
        default: return ("Critical", .red)
        }
    }
    
    var body: some View {
        MetricScoreCard(
            title: "Untagged Content",
            subtitle: "Library is",
            description: "Percentage of Collages & Photos missing search tags.",
            score: untaggedPercentage,
            statusText: status.text,
            statusColor: status.color,
            gradientColors: [
                Color.green,  // Low % untagged (Good)
                Color.yellow, // Medium
                Color.red     // High % untagged (Bad)
            ],
            legendItems: [
                LegendDot2(color: .green, label: "Tagged"),
                LegendDot2(color: .yellow, label: "Missing some"),
                LegendDot2(color: .red, label: "Untagged")
            ]
        )
    }
}

struct DataQualityCard: View {
    let dataQualityScore: Double // 0-100%
    
    // Logic: Higher is better
    private var status: (text: String, color: Color) {
        switch dataQualityScore {
        case ..<50: return ("Needs Review", .orange)
        case 50..<80: return ("Good", .blue)
        default: return ("Excellent", .green)
        }
    }
    
    var body: some View {
        MetricScoreCard(
            title: "Client Data Quality",
            subtitle: "Profiles are",
            description: "Based on presence of Name, Email, Phone, and DOB.",
            score: dataQualityScore,
            statusText: status.text,
            statusColor: status.color,
            gradientColors: [
                Color.orange, // Missing Data
                Color.blue.opacity(0.6),
                Color.green   // Complete Data
            ],
            legendItems: [
                LegendDot2(color: .orange, label: "Incomplete"),
                LegendDot2(color: .blue, label: "Good"),
                LegendDot2(color: .green, label: "Complete")
            ]
        )
    }
}

struct ChartCard<Content: View>: View {
    
    let content: () -> Content
    
    var body: some View {
        
        self.content()
            .padding(24)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 24)
        
    }
    
}

struct BaseChartCardView<Content: View>: View {
    
    private let title: String
    private let attributedMessage: AttributedText
    private let description: String
    private let chartTopSpacing: CGFloat
    private let content: () -> Content
    
    init(title: String,
         attributedMessage: AttributedText,
         description: String,
         chartTopSpacing: CGFloat = 24,
         @ViewBuilder content: @escaping () -> Content) {
        
        self.title = title
        self.attributedMessage = attributedMessage
        self.description = description
        self.chartTopSpacing = chartTopSpacing
        self.content = content
        
    }
    
    var body: some View {
        
        ChartCard {
            
            VStack(alignment: .leading, spacing: self.chartTopSpacing) {
                
                // Header
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(self.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    self.attributedMessage
                        .padding(.top, 2)
                    
                    Text(self.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, .small)
                    
                }
                
                self.content()
                
            }
            
        }
        
    }
    
}

#Preview("Weekly Metric") {
    WeeklyMediaCard3(data: weeklyMediaData1)
}

#Preview("Client Growth") {
    ClientGrowthCard(data: clientGrowthData)
}

#Preview("Practitioner Activity") {
    PractitionerActivityCard(data: practitionerData)
}

#Preview("Metric Cards") {
    
    ChartCard {
        
        VStack(spacing: 8) {
            
            DataQualityCard(dataQualityScore: 0)
            UntaggedContentCard(untaggedPercentage: 50)
            
        }
        
    }
    
}
