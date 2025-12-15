import SwiftUI
import Charts

// MARK: - Data Models

let treatmentData: [TreatmentCategorySegment] = [
    .init(category: "Injectables", percentage: 40.0,
          color: Color(red: 0.2, green: 0.1, blue: 0.4)),
    .init(category: "Skin",        percentage: 30.0,
          color: Color(red: 0.4, green: 0.2, blue: 0.8)),
    .init(category: "Body",        percentage: 18.0,
          color: Color(red: 0.6, green: 0.55, blue: 0.85)),
    .init(category: "Other",       percentage: 12.0,
          color: Color(red: 0.8, green: 0.8, blue: 0.9))
]

let weeklyMediaData: [DailyMediaCapture] = [
    .init(dayLabel: "Sun", mediaKind: .before, count: 12),
    .init(dayLabel: "Sun", mediaKind: .after,  count: 6),
    .init(dayLabel: "Sun", mediaKind: .video,  count: 3),
    
    // Monday - busiest content day
    .init(dayLabel: "Mon", mediaKind: .before, count: 30),
    .init(dayLabel: "Mon", mediaKind: .after,  count: 28),
    .init(dayLabel: "Mon", mediaKind: .video,  count: 12),
    
    .init(dayLabel: "Tue", mediaKind: .before, count: 10),
    .init(dayLabel: "Tue", mediaKind: .after,  count: 8),
    .init(dayLabel: "Tue", mediaKind: .video,  count: 4),
    
    .init(dayLabel: "Wed", mediaKind: .before, count: 6),
    .init(dayLabel: "Wed", mediaKind: .after,  count: 5),
    .init(dayLabel: "Wed", mediaKind: .video,  count: 2),
    
    .init(dayLabel: "Thu", mediaKind: .before, count: 14),
    .init(dayLabel: "Thu", mediaKind: .after,  count: 10),
    .init(dayLabel: "Thu", mediaKind: .video,  count: 4),
    
    .init(dayLabel: "Fri", mediaKind: .before, count: 20),
    .init(dayLabel: "Fri", mediaKind: .after,  count: 16),
    .init(dayLabel: "Fri", mediaKind: .video,  count: 7),
    
    .init(dayLabel: "Sat", mediaKind: .before, count: 8),
    .init(dayLabel: "Sat", mediaKind: .after,  count: 6),
    .init(dayLabel: "Sat", mediaKind: .video,  count: 3)
]

// 2. Client Engagement Trend (sessions per day)
let engagementData: [EngagementPoint] = [
    .init(dayLabel: "Aug 12", sessionCount: 18),
    .init(dayLabel: "Aug 13", sessionCount: 22),
    .init(dayLabel: "Aug 14", sessionCount: 46), // The spike day
    .init(dayLabel: "Aug 15", sessionCount: 28),
    .init(dayLabel: "Aug 16", sessionCount: 20),
    .init(dayLabel: "Aug 17", sessionCount: 24),
    .init(dayLabel: "Aug 18", sessionCount: 16)
]

struct DailyMediaTotal: Identifiable, Hashable {
    let id = UUID()
    let dayLabel: String
    let totalCount: Int
}

enum MediaKind: String, Plottable, CaseIterable {
    case before = "Before"
    case after = "After"
    case video = "Video"
    
    var color: Color {
        switch self {
        case .before: return Color(red: 0.75, green: 0.45, blue: 0.4) // Brown/Red
        case .after:  return Color(red: 0.85, green: 0.7, blue: 0.4)  // Gold/Tan
        case .video:  return Color(red: 0.5, green: 0.55, blue: 0.8)  // Periwinkle/Blue
        }
    }
}

struct DailyMediaCapture: Identifiable {
    let id = UUID()
    let dayLabel: String
    let mediaKind: MediaKind
    let count: Double // Number of media items captured
}

struct EngagementPoint: Identifiable {
    let id = UUID()
    let dayLabel: String
    let sessionCount: Double // Client sessions (or appointments) per day
}

struct FlowPoint: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
}

struct UsageGrowthPoint: Identifiable {
    let id = UUID()
    let date: Date
    let mediaCount: Double
    let activeClientsCount: Double
}

struct TreatmentCategorySegment: Identifiable {
    let id = UUID()
    let category: String
    let percentage: Double
    let color: Color
}

// MARK: - Main View

struct GlowProDashboardView: View {
    
    // 1. Weekly Media Captures (by type)
    let weeklyMediaData: [DailyMediaCapture] = [
        .init(dayLabel: "Sun", mediaKind: .before, count: 12),
        .init(dayLabel: "Sun", mediaKind: .after,  count: 6),
        .init(dayLabel: "Sun", mediaKind: .video,  count: 3),
        
        // Monday - busiest content day
        .init(dayLabel: "Mon", mediaKind: .before, count: 30),
        .init(dayLabel: "Mon", mediaKind: .after,  count: 28),
        .init(dayLabel: "Mon", mediaKind: .video,  count: 12),
        
        .init(dayLabel: "Tue", mediaKind: .before, count: 10),
        .init(dayLabel: "Tue", mediaKind: .after,  count: 8),
        .init(dayLabel: "Tue", mediaKind: .video,  count: 4),
        
        .init(dayLabel: "Wed", mediaKind: .before, count: 6),
        .init(dayLabel: "Wed", mediaKind: .after,  count: 5),
        .init(dayLabel: "Wed", mediaKind: .video,  count: 2),
        
        .init(dayLabel: "Thu", mediaKind: .before, count: 14),
        .init(dayLabel: "Thu", mediaKind: .after,  count: 10),
        .init(dayLabel: "Thu", mediaKind: .video,  count: 4),
        
        .init(dayLabel: "Fri", mediaKind: .before, count: 20),
        .init(dayLabel: "Fri", mediaKind: .after,  count: 16),
        .init(dayLabel: "Fri", mediaKind: .video,  count: 7),
        
        .init(dayLabel: "Sat", mediaKind: .before, count: 8),
        .init(dayLabel: "Sat", mediaKind: .after,  count: 6),
        .init(dayLabel: "Sat", mediaKind: .video,  count: 3)
    ]
    
    // 2. Client Engagement Trend (sessions per day)
    let engagementData: [EngagementPoint] = [
        .init(dayLabel: "Aug 12", sessionCount: 18),
        .init(dayLabel: "Aug 13", sessionCount: 22),
        .init(dayLabel: "Aug 14", sessionCount: 46), // The spike day
        .init(dayLabel: "Aug 15", sessionCount: 28),
        .init(dayLabel: "Aug 16", sessionCount: 20),
        .init(dayLabel: "Aug 17", sessionCount: 24),
        .init(dayLabel: "Aug 18", sessionCount: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // 1. Weekly Media Captures
                WeeklyMediaCard(data: weeklyMediaData)
                
                WeeklyMediaCard2(data: weeklyMediaData)
                
                // 2. Utilization Score (location usage)
                UtilizationScoreCard(utilizationScore: 72.0)
                
                // 3. Client Engagement Trend
                EngagementTrendCard(data: engagementData)
                
                // 4. Daily Flow (first/last booking)
                DailyFlowCard()
                
                // 5. Usage Growth (media vs active clients)
                UsageGrowthCard()
                
                // 6. Treatment Mix
                TreatmentMixCard()
                
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

// MARK: - Card 1: Weekly Media Captures

struct WeeklyMediaCard: View {
    let data: [DailyMediaCapture]
    
    private var totalMediaThisWeek: Int {
        Int(data.reduce(0) { $0 + $1.count })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Header
            VStack(alignment: .leading, spacing: 5) {
                Text("Weekly Media Captures")
                    .font(.headline)
                    .fontWeight(.bold)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(totalMediaThisWeek)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("items")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text("Before / After / Video captured across all staff")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Chart
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Day", item.dayLabel),
                        y: .value("Media Count", item.count)
                    )
                    .foregroundStyle(by: .value("Kind", item.mediaKind.rawValue))
                }
            }
            .chartForegroundStyleScale([
                MediaKind.before.rawValue: MediaKind.before.color,
                MediaKind.after.rawValue: MediaKind.after.color,
                MediaKind.video.rawValue: MediaKind.video.color
            ])
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 20, 40, 60, 80]) { value in
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
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                }
            }
            .chartLegend(.hidden)
            .frame(height: 250)
            
            // Custom Legend
            HStack(spacing: 20) {
                Spacer()
                LegendItem(color: MediaKind.before.color, label: "Before")
                LegendItem(color: MediaKind.after.color,  label: "After")
                LegendItem(color: MediaKind.video.color,  label: "Video")
                Spacer()
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct WeeklyMediaCard2: View {
    let data: [DailyMediaCapture]
    
    private var totalMediaThisWeek: Int {
        Int(data.reduce(0) { $0 + $1.count })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Header
            VStack(alignment: .leading, spacing: 5) {
                Text("Weekly Media Captures")
                    .font(.headline)
                    .fontWeight(.bold)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(totalMediaThisWeek)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("items")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text("Before / After / Video captured across all staff")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Chart
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
//            .chartForegroundStyleScale([
//                MediaKind.before.rawValue: MediaKind.before.color,
//                MediaKind.after.rawValue: MediaKind.after.color,
//                MediaKind.video.rawValue: MediaKind.video.color
//            ])
//            .chartYAxis {
//                AxisMarks(position: .leading, values: [0, 20, 40, 60, 80]) { value in
//                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
//                        .foregroundStyle(Color.gray.opacity(0.3))
//                    AxisValueLabel() {
//                        if let intValue = value.as(Int.self) {
//                            Text("\(intValue)")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                }
//            }
//            .chartXAxis {
//                AxisMarks { value in
//                    AxisValueLabel()
//                        .font(.caption)
//                        .foregroundStyle(Color.gray)
//                }
//            }
            .chartLegend(.hidden)
            .frame(height: 250)
//            
//            // Custom Legend
//            HStack(spacing: 20) {
//                Spacer()
//                LegendItem(color: MediaKind.before.color, label: "Before")
//                LegendItem(color: MediaKind.after.color,  label: "After")
//                LegendItem(color: MediaKind.video.color,  label: "Video")
//                Spacer()
//            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Card 2: Utilization Score

struct UtilizationScoreCard: View {
    let utilizationScore: Double // 0–100, how fully the location uses GlowPro
    
    // Gradient representing utilization zones
    let gradient = LinearGradient(
        colors: [
            Color(red: 0.4, green: 0.5, blue: 0.9), // Under-utilized
            Color(red: 0.4, green: 0.8, blue: 0.5), // Healthy
            Color(red: 0.9, green: 0.8, blue: 0.4), // High usage
            Color(red: 0.8, green: 0.4, blue: 0.3)  // Over-capacity / stressed
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    private var utilizationLabel: String {
        switch utilizationScore {
        case ..<40: return "Under-utilized"
        case 40..<75: return "Healthy"
        case 75..<90: return "High usage"
        default: return "Maxed out"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Location Utilization")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        Text(String(format: "%.0f", utilizationScore))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        
                        Text("GlowPro usage is")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        Text(utilizationLabel)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.4, green: 0.8, blue: 0.5))
                            .clipShape(Capsule())
                    }
                    
                    Text("Based on media captured, clients documented, and active staff.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.gray)
            }
            
            // Gauge Chart
            Chart {
                // Background utilization band (0–100)
                BarMark(
                    xStart: .value("Start", 0),
                    xEnd: .value("End", 100),
                    y: .value("Y", "Bar")
                )
                .cornerRadius(10)
                .foregroundStyle(gradient)
                
                // Current score indicator
                PointMark(
                    x: .value("Current Utilization", utilizationScore),
                    y: .value("Y", "Bar")
                )
                .symbol(Circle())
                .symbolSize(150)
                .foregroundStyle(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 1)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 25)
            
            // Legend
            HStack(spacing: 12) {
                LegendDot(color: Color(red: 0.4, green: 0.5, blue: 0.9), label: "Under-utilized")
                LegendDot(color: Color(red: 0.4, green: 0.8, blue: 0.5), label: "Healthy")
                LegendDot(color: Color(red: 0.9, green: 0.8, blue: 0.4), label: "High usage")
                LegendDot(color: Color(red: 0.8, green: 0.4, blue: 0.3), label: "Maxed out")
            }
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Helper Views

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 10))
                .foregroundColor(color)
                .rotationEffect(.degrees(45))
            
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)
        }
    }
}

struct LegendDot: View {
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

// MARK: - Card 3: Client Engagement Trend

struct EngagementTrendCard: View {
    let data: [EngagementPoint]
    
    let lineColor = Color(red: 0.3, green: 0.5, blue: 0.9)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Client Engagement Trend")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Sessions per day (last 7 days)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            
            // Area + Line Chart
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
            .frame(height: 180)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Card 4: Daily Client Flow

struct DailyFlowCard: View {
    
    // Generate normalized flow curve (e.g. bookings across the day)
    var flowPoints: [FlowPoint] {
        var points: [FlowPoint] = []
        for i in stride(from: 0.0, to: 3.2, by: 0.1) {
            points.append(FlowPoint(x: i, y: sin(i)))
        }
        return points
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            
            // Left Column: Times
            VStack(alignment: .leading, spacing: 20) {
                // First booking
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "sunrise.fill")
                            .symbolRenderingMode(.hierarchical)
                        Text("First booking")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    
                    Text("09:00 am")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                // Last booking
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "sunset.fill")
                            .symbolRenderingMode(.hierarchical)
                        Text("Last booking")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    
                    Text("07:30 pm")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Text("View full schedule")
                    .font(.caption)
                    .underline()
                    .foregroundColor(.gray)
            }
            .frame(width: 120)
            
            // Right Column: Flow curve
            Chart {
                ForEach(flowPoints) { point in
                    LineMark(
                        x: .value("X", point.x),
                        y: .value("Y", point.y)
                    )
                    .foregroundStyle(.gray.opacity(0.8))
                    .interpolationMethod(.catmullRom)
                }
                
                // "Current time" marker along the curve (example)
                PointMark(
                    x: .value("X", 1.2),
                    y: .value("Y", sin(1.2))
                )
                .symbol(Circle())
                .symbolSize(200)
                .foregroundStyle(Color(red: 0.95, green: 0.8, blue: 0.3))
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 120)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Card 5: Usage Growth (Media vs Active Clients)

struct UsageGrowthCard: View {
    
    let usageData: [UsageGrowthPoint] = {
        let calendar = Calendar.current
        let today = Date()
        var points: [UsageGrowthPoint] = []
        
        var mediaBase: Double = 1200
        var clientsBase: Double = 160
        
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -30 + i, to: today) {
                mediaBase += Double.random(in: 5...20)
                clientsBase += Double.random(in: 0...1.5)
                
                points.append(
                    UsageGrowthPoint(
                        date: date,
                        mediaCount: mediaBase,
                        activeClientsCount: clientsBase
                    )
                )
            }
        }
        return points
    }()
    
    let mediaColor = Color(red: 0.4, green: 0.5, blue: 0.9)
    let clientsColor = Color(red: 0.8, green: 0.5, blue: 0.3)
    
    private var latestMediaCount: Int {
        Int(usageData.last?.mediaCount ?? 0)
    }
    
    private var latestActiveClients: Int {
        Int(usageData.last?.activeClientsCount ?? 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Header with Two Columns
            HStack(alignment: .top) {
                // Media items
                VStack(alignment: .center, spacing: 4) {
                    Text("\(latestMediaCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color(uiColor: .darkText))
                    HStack(spacing: 4) {
                        Circle().fill(mediaColor).frame(width: 6, height: 6)
                        Text("media items")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Active clients
                VStack(alignment: .center, spacing: 4) {
                    Text("\(latestActiveClients)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color(uiColor: .darkText))
                    HStack(spacing: 4) {
                        Circle().fill(clientsColor).frame(width: 6, height: 6)
                        Text("active clients")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.gray.opacity(0.5))
            }
            
            // Chart
            Chart {
                ForEach(usageData) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Media", point.mediaCount),
                        series: .value("Series", "Media")
                    )
                    .foregroundStyle(mediaColor)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Active Clients", point.activeClientsCount),
                        series: .value("Series", "Clients")
                    )
                    .foregroundStyle(clientsColor)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .zIndex(10)
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis(.hidden)
            .frame(height: 120)
            
            // Time range selector (mock)
            HStack {
                ForEach(["1W", "1M", "YTD", "3M", "1Y"], id: \.self) { period in
                    Text(period)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(period == "1M" ? Color.gray.opacity(0.2) : Color.clear)
                        .foregroundColor(period == "1M" ? .black : .gray)
                        .cornerRadius(12)
                    if period != "1Y" { Spacer() }
                }
            }
            .padding(.horizontal, 10)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Card 6: Treatment Mix

struct TreatmentMixCard: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.title3)
                    Text("Treatment Mix")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                Text("Based on media captured in the last 30 days")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Stacked Bar Chart
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
            .clipShape(.rect(cornerRadius: 16))
            .frame(height: 60)
            
            // Legend
            VStack(spacing: 12) {
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
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Preview

#Preview {
    GlowProDashboardView()
}

//import SwiftUI
//import Charts
//
//// MARK: - Helper View for Legend
//struct LegendDot2: View {
//    let color: Color
//    let label: String
//    
//    var body: some View {
//        HStack(spacing: 4) {
//            Circle()
//                .fill(color)
//                .frame(width: 8, height: 8)
//            Text(label)
//        }
//    }
//}
//
//// MARK: - The Reusable Score Card
//struct MetricScoreCard: View {
//    let title: String
//    let subtitle: String
//    let description: String
//    let score: Double // 0-100
//    
//    // The visual configuration
//    let statusText: String
//    let statusColor: Color
//    let gradientColors: [Color]
//    let legendItems: [LegendDot2]
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            
//            // Header
//            HStack(alignment: .top) {
//                VStack(alignment: .leading, spacing: 5) {
//                    Text(title)
//                        .font(.headline)
//                        .fontWeight(.bold)
//                    
//                    HStack(spacing: 8) {
//                        // The Big Number
//                        Text(String(format: "%.0f%%", score))
//                            .font(.system(size: 34, weight: .bold, design: .rounded))
//                        
//                        // Subtext
//                        Text(subtitle)
//                            .foregroundColor(.gray)
//                            .font(.subheadline)
//                        
//                        // The Status Badge
//                        Text(statusText)
//                            .font(.caption)
//                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 4)
//                            .background(statusColor)
//                            .clipShape(Capsule())
//                    }
//                    
//                    Text(description)
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .fixedSize(horizontal: false, vertical: true)
//                }
//                Spacer()
//                Image(systemName: "questionmark.circle")
//                    .foregroundColor(.gray)
//            }
//            
//            // Gauge Chart
//            Chart {
//                // Background Gradient Bar
//                BarMark(
//                    xStart: .value("Start", 0),
//                    xEnd: .value("End", 100),
//                    y: .value("Y", "Bar")
//                )
//                .cornerRadius(10)
//                .foregroundStyle(
//                    LinearGradient(
//                        colors: gradientColors,
//                        startPoint: .leading,
//                        endPoint: .trailing
//                    )
//                )
//                
//                // The White "Needle" Dot
//                PointMark(
//                    x: .value("Score", score),
//                    y: .value("Y", "Bar")
//                )
//                .symbol(Circle())
//                .symbolSize(150)
//                .foregroundStyle(Color.white)
//                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 1)
//            }
//            .chartXAxis(.hidden)
//            .chartYAxis(.hidden)
//            .frame(height: 25)
//            
//            // Legend
//            HStack(spacing: 12) {
//                ForEach(0..<legendItems.count, id: \.self) { index in
//                    legendItems[index]
//                }
//            }
//            .font(.caption)
//            .foregroundColor(.gray)
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .padding(24)
//        .background(Color.white)
//        .cornerRadius(24)
//        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//    }
//}
//
//struct UntaggedContentCard: View {
//    let untaggedPercentage: Double // 0-100% (Percentage of items WITHOUT tags)
//    
//    // Logic: Lower is better (0% untagged is perfect)
//    private var status: (text: String, color: Color) {
//        switch untaggedPercentage {
//        case ..<15: return ("Optimized", .green)
//        case 15..<40: return ("Attention", .yellow)
//        default: return ("Critical", .red)
//        }
//    }
//    
//    var body: some View {
//        MetricScoreCard(
//            title: "Untagged Content",
//            subtitle: "Library is",
//            description: "Percentage of Collages & Photos missing search tags.",
//            score: untaggedPercentage,
//            statusText: status.text,
//            statusColor: status.color,
//            gradientColors: [
//                Color.green,  // Low % untagged (Good)
//                Color.yellow, // Medium
//                Color.red     // High % untagged (Bad)
//            ],
//            legendItems: [
//                LegendDot2(color: .green, label: "Tagged"),
//                LegendDot2(color: .yellow, label: "Missing some"),
//                LegendDot2(color: .red, label: "Untagged")
//            ]
//        )
//    }
//}
//
//struct DataQualityCard: View {
//    let dataQualityScore: Double // 0-100%
//    
//    // Logic: Higher is better
//    private var status: (text: String, color: Color) {
//        switch dataQualityScore {
//        case ..<50: return ("Needs Review", .orange)
//        case 50..<80: return ("Good", .blue)
//        default: return ("Excellent", .green)
//        }
//    }
//    
//    var body: some View {
//        MetricScoreCard(
//            title: "Client Data Quality",
//            subtitle: "Profiles are",
//            description: "Based on presence of Name, Email, Phone, and DOB.",
//            score: dataQualityScore,
//            statusText: status.text,
//            statusColor: status.color,
//            gradientColors: [
//                Color.orange, // Missing Data
//                Color.blue.opacity(0.6),
//                Color.green   // Complete Data
//            ],
//            legendItems: [
//                LegendDot2(color: .orange, label: "Incomplete"),
//                LegendDot2(color: .blue, label: "Good"),
//                LegendDot2(color: .green, label: "Complete")
//            ]
//        )
//    }
//}
//
//
//#Preview {
//    
//    VStack {
//        
//        DataQualityCard(dataQualityScore: 0.80)
//        UntaggedContentCard(untaggedPercentage: 0.50)
//        
//    }
//    .padding(.horizontal, 24)
//    
//}
