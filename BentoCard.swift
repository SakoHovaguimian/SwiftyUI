import SwiftUI
import Charts // REQUIRED for professional graphs

// MARK: - 1. Theme & Data Models
extension Color {
    static let deepCharcoal = Color(hex: "1C1C1E")
    static let cardBg = Color(hex: "2C2C2E")
    
    // Vivid Pastels
    static let neonSalmon = Color(hex: "FF6B6B")
    static let neonYellow = Color(hex: "FFE66D")
    static let neonBlue = Color(hex: "4D96FF")
    static let neonPurple = Color(hex: "A9DEF9") // Periwinkle
}

struct HeartData: Identifiable {
    let id = UUID()
    let time: String
    let bpm: Int
}

struct CalorieData: Identifiable {
    let id = UUID()
    let type: String
    let amount: Int
    let color: Color
}

// MARK: - 2. Dashboard View
struct HighFidelityHealthView: View {
    // Mock Data
    let heartRateData: [HeartData] = [
        .init(time: "10AM", bpm: 72),
        .init(time: "11AM", bpm: 85),
        .init(time: "12PM", bpm: 68),
        .init(time: "1PM", bpm: 95), // Spike
        .init(time: "2PM", bpm: 78),
        .init(time: "3PM", bpm: 74),
        .init(time: "4PM", bpm: 65)
    ]
    
    let calorieData: [CalorieData] = [
        .init(type: "Intake", amount: 1450, color: .gray),
        .init(type: "Burn", amount: 2100, color: .neonYellow)
    ]

    var body: some View {
        ZStack {
            Color.deepCharcoal.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("WEDNESDAY")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.gray)
                            Text("RECOVERY OS")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.black)
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(Image(systemName: "person.fill").foregroundStyle(.white))
                    }
                    .padding(.horizontal)
                    
                    // --- BENTO GRID ---
                    
                    // ROW 1: Activity (Square) + Stacked Info
                    HStack(spacing: 12) {
                        // Activity Rings
                        VStack {
                            HeaderIcon(title: "ACTIVITY", icon: "figure.run", color: .neonSalmon)
                            Spacer()
                            ZStack {
                                ActivityRing(progress: 0.75, color: .neonSalmon, size: 130, thickness: 15)
                                ActivityRing(progress: 0.55, color: .neonBlue, size: 90, thickness: 15)
                                VStack {
                                    Text("75%")
                                        .font(.system(.title2, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundStyle(.white)
                                    Text("MOVE")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundStyle(.gray)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(height: 220)
                        .background(Color.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        
                        // Vertical Stack
                        VStack(spacing: 12) {
                            // Recovery Battery
                            VStack(alignment: .leading) {
                                HeaderIcon(title: "BATTERY", icon: "battery.100.bolt", color: .neonYellow)
                                Spacer()
                                Text("92%")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundStyle(.white)
                                ProgressView(value: 0.92)
                                    .tint(.neonYellow)
                                    .scaleEffect(x: 1, y: 2, anchor: .center)
                            }
                            .padding()
                            .frame(height: 104)
                            .background(Color.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            
                            // Hydration
                            VStack(alignment: .leading) {
                                HeaderIcon(title: "WATER", icon: "drop.fill", color: .neonBlue)
                                Spacer()
                                HStack(alignment: .bottom) {
                                    Text("2.1L")
                                        .font(.system(.title, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    // Visual Water Level
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.neonBlue)
                                        .frame(width: 20, height: 40)
                                }
                            }
                            .padding()
                            .frame(height: 104)
                            .background(Color.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                    }
                    .padding(.horizontal)
                    
                    // ROW 2: Heart Rate Graph (The Big Fix)
                    VStack(alignment: .leading) {
                        HStack {
                            HeaderIcon(title: "HEART RATE", icon: "waveform.path.ecg", color: .neonSalmon)
                            Spacer()
                            Text("72 BPM")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        
                        Chart {
                            ForEach(heartRateData) { data in
                                // Gradient Area under the line
                                AreaMark(
                                    x: .value("Time", data.time),
                                    y: .value("BPM", data.bpm)
                                )
                                .interpolationMethod(.catmullRom) // SMOOTH CURVES
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.neonSalmon.opacity(0.15), Color.neonSalmon.opacity(0.1), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                
                                // The Line itself
                                LineMark(
                                    x: .value("Time", data.time),
                                    y: .value("BPM", data.bpm)
                                )
                                .interpolationMethod(.catmullRom) // SMOOTH CURVES
                                .lineStyle(StrokeStyle(lineWidth: 8, lineCap: .round))
                                .foregroundStyle(Color.neonSalmon)
                            }
                        }
                        .chartYScale(domain: 50...110) // Fixed scale so it doesn't look jumpy
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .frame(height: 100)
                    }
                    .padding()
                    .frame(height: 180)
                    .background(Color.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal)
                    
                    // ROW 3: Sleep & Calories
                    HStack(spacing: 12) {
                        // Sleep
                        VStack(alignment: .leading) {
                            HeaderIcon(title: "SLEEP", icon: "moon.fill", color: .neonPurple)
                            Spacer()
                            Text("8h 12m")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.black)
                                .foregroundStyle(.white)
                            Text("Deep Sleep +12%")
                                .font(.caption)
                                .foregroundStyle(Color.neonPurple)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .background(Color.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        
//                         Calories Chart (Bar Chart)
                        VStack(alignment: .leading) {
                            HeaderIcon(title: "KCAL", icon: "flame.fill", color: .neonYellow)
                            
                            Chart(calorieData) { item in
                                BarMark(
                                    x: .value("Type", item.type),
                                    y: .value("Amount", item.amount)
                                )
                                .foregroundStyle(item.color)
                                .cornerRadius(6)
                                .annotation(position: .top) {
                                    Text("\(item.amount)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.gray)
                                }
                            }
                            .chartXAxis(.hidden)
                            .chartYAxis(.hidden)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .background(Color.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
        }
    }
}

// MARK: - 3. Components

struct HeaderIcon: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 12, design: .monospaced))
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
    }
}

struct ActivityRing: View {
    var progress: Double
    var color: Color
    var size: CGFloat
    var thickness: CGFloat
    
    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: thickness)
                .frame(width: size, height: size)
            
            // Progress
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: thickness, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.5), radius: 5)
        }
    }
}

// MARK: - Preview
struct HighFidelityHealthView_Previews: PreviewProvider {
    static var previews: some View {
        HighFidelityHealthView()
            .preferredColorScheme(.dark)
    }
}
