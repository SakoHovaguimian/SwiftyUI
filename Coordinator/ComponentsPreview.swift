import SwiftUI
import Charts

// MARK: - Main Preview
#Preview {
    ComponentsPreview()
}

struct ComponentsPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("New: Sports & Finance")
                        .font(.title2).bold()
                        .padding(.horizontal)
                    SportsPsychologyCard()
                        .padding(.horizontal)
                    
                    FinanceDashboardView()
                        .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Original Cards")
                        .font(.title2).bold()
                        .padding(.horizontal)
                    ProfileCardView()
                    BouncingShowcaseCardView()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Texture Gallery")
                        .font(.title2).bold()
                        .padding(.horizontal)
                    RectangleTextureCard()
                    DashTextureCard()
                    DashArcTextureCard()
                    ConcentricRingsTextureCard()
                    DotGridTextureCard()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Original Dashboard")
                        .font(.title2).bold()
                        .padding(.horizontal)
                    OriginalDashboardView()
                }
            }
            .padding(.vertical, 24)
        }
        .background(Color(white: 0.95).edgesIgnoringSafeArea(.all))
    }
}

// MARK: - 1. Base Pattern System (Circles)
struct PatternConfig {
    let size: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
}

struct PatternCard<Content: View>: View {
    let colors: [Color]
    let patterns: [PatternConfig]
    let content: Content
    
    init(colors: [Color], patterns: [PatternConfig], @ViewBuilder content: () -> Content) {
        self.colors = colors
        self.patterns = patterns
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            
            ForEach(0..<patterns.count, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: patterns[index].size, height: patterns[index].size)
                    .offset(x: patterns[index].offsetX, y: patterns[index].offsetY)
            }
            
            content.padding(24)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct BouncingPatternCard<Content: View>: View {
    let colors: [Color]
    let patterns: [PatternConfig]
    let content: Content
    
    @State private var isAnimating = false
    
    init(colors: [Color], patterns: [PatternConfig], @ViewBuilder content: () -> Content) {
        self.colors = colors
        self.patterns = patterns
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            
            ForEach(0..<patterns.count, id: \.self) { index in
                let driftX: CGFloat = index % 2 == 0 ? 40 : -30
                let driftY: CGFloat = index % 2 == 0 ? -40 : 50
                
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: patterns[index].size, height: patterns[index].size)
                    .offset(
                        x: patterns[index].offsetX + (isAnimating ? driftX : 0),
                        y: patterns[index].offsetY + (isAnimating ? driftY : 0)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 4...7))
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            
            content.padding(24)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - 2. NEW: Sports Psychology Card (Interlocking Rings & Glassmorphism)
struct SportsPsychologyCard: View {
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [Color(red: 0.53, green: 0.61, blue: 0.96), Color(red: 0.44, green: 0.52, blue: 0.94)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Interlocking Rings Texture
            GeometryReader { geo in
                Canvas { context, size in
                    let radius: CGFloat = 35
                    let step = radius * 1.5 // Distance between centers
                    
                    // Draw a grid of overlapping circles
                    for x in stride(from: -radius, to: size.width + radius, by: step) {
                        for y in stride(from: -radius, to: size.height + radius, by: step) {
                            // Offset every other row to interlock them
                            let rowOffset = (Int(y / step) % 2 == 0) ? 0 : (step / 2)
                            let path = Path(ellipseIn: CGRect(x: x + rowOffset, y: y, width: radius * 2, height: radius * 2))
                            context.stroke(path, with: .color(.white.opacity(0.15)), lineWidth: 1.5)
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text("PROGRESS")
                        .font(.system(size: 10, weight: .bold))
                    Text("18%")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(.white)
                .opacity(0.9)
                .padding(.top, 8)
                
                Text("The Psychology of\nSports Victories")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Spacer()
                
                // Glassmorphic Author Pill
                HStack(spacing: 12) {
                    // Safe Avatar Placeholder (Prevents layout breaking)
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.yellow)
                        .background(Color.white)
                        .clipShape(Circle())
                    
                    Text("N. Hardman")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("4.8")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                // Fallback tint for older OS or specific contrast needs
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
            }
            .padding(24)
        }
        .frame(height: 380)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}


// MARK: - 3. NEW: Finance Dashboard (Bar & Donut)
struct FinanceDashboardView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5)
                }
                
                Spacer()
                
                // Top Custom Segment
                HStack(spacing: 0) {
                    Text("Overview")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                    Text("This Month")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                }
                .padding(4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(24)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5)
                }
            }
            
            // Spending Bar Chart Card
            VStack(alignment: .leading, spacing: 16) {
                Text("Total Spending")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$440").font(.system(size: 28, weight: .bold))
                    Text(".00").font(.system(size: 20, weight: .semibold)).foregroundColor(.gray)
                }
                
                FinanceBarChart()
                    .frame(height: 180)
                    .padding(.top, 10)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(24)
            
            // Categories Donut Chart Card
            VStack(spacing: 24) {
                // Segmented Picker Native
                Picker("", selection: $selectedTab) {
                    Text("Category").tag(0)
                    Text("Account").tag(1)
                    Text("Merchant").tag(2)
                }
                .pickerStyle(.segmented)
                
                FinanceDonutChart()
                    .frame(height: 220)
                
                // Donut Legend
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        LegendItemView(color: Color(red: 0.45, green: 0.7, blue: 0.54), text: "Food & Groceries")
                        LegendItemView(color: Color(red: 0.89, green: 0.51, blue: 0.63), text: "Health & Wellness")
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        LegendItemView(color: Color(red: 0.42, green: 0.63, blue: 0.91), text: "Transportation")
                        LegendItemView(color: Color.yellow, text: "Eating Out")
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        LegendItemView(color: Color(red: 0.65, green: 0.35, blue: 0.9), text: "Subscriptions")
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(24)
        }
    }
}

// MARK: - Finance Bar Chart
struct SpendingData: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
    let isCurrent: Bool
}

struct FinanceBarChart: View {
    let data: [SpendingData] = [
        SpendingData(month: "Apr'25", amount: 480, isCurrent: false),
        SpendingData(month: "May'25", amount: 680, isCurrent: false),
        SpendingData(month: "Jun'25", amount: 600, isCurrent: false),
        SpendingData(month: "Jul'25", amount: 820, isCurrent: false),
        SpendingData(month: "Aug'25", amount: 650, isCurrent: false),
        SpendingData(month: "Sep'25", amount: 480, isCurrent: true)
    ]
    let average: Double = 500
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Month", item.month),
                    y: .value("Amount", item.amount),
                    width: .fixed(16)
                )
                .clipShape(Capsule())
                .foregroundStyle(item.isCurrent ? Color(red: 0.25, green: 0.4, blue: 0.28) : Color(red: 0.45, green: 0.7, blue: 0.54))
            }
            
            // Average Line
            RuleMark(y: .value("Average", average))
                .lineStyle(StrokeStyle(lineWidth: 2))
                .foregroundStyle(Color.yellow.opacity(0.8))
                .annotation(position: .leading, alignment: .center) {
                    Text("Avg 6 month")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.yellow)
                        .cornerRadius(6)
                        .offset(x: 30, y: -12)
                }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [200, 400, 600, 800]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let intVal = value.as(Int.self) {
                        Text("$\(intVal)")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let strVal = value.as(String.self) {
                        Text(strVal)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

// MARK: - Finance Custom Donut Chart
// Built custom to guarantee precise overlap, gaps, and tooltip placement
struct FinanceDonutChart: View {
    let lineWidth: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Food (Green) - ~40%
            Circle()
                .trim(from: 0.0, to: 0.38)
                .stroke(Color(red: 0.45, green: 0.7, blue: 0.54), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            // Subscriptions (Purple) - ~2%
            Circle()
                .trim(from: 0.40, to: 0.42)
                .stroke(Color(red: 0.65, green: 0.35, blue: 0.9), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            // Health (Pink) - ~7%
            Circle()
                .trim(from: 0.44, to: 0.51)
                .stroke(Color(red: 0.89, green: 0.51, blue: 0.63), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            // Eating Out (Red) - ~3%
            Circle()
                .trim(from: 0.53, to: 0.56)
                .stroke(Color(red: 0.8, green: 0.3, blue: 0.3), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            // Transportation (Blue) - ~42%
            Circle()
                .trim(from: 0.58, to: 0.98)
                .stroke(Color(red: 0.42, green: 0.63, blue: 0.91), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            // Inner Details
            VStack(spacing: 4) {
                Text("Total Spending")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$440").font(.system(size: 24, weight: .bold))
                    Text(".00").font(.system(size: 16, weight: .semibold)).foregroundColor(.gray)
                }
            }
            
            // Tooltip Overlay for Transportation
            VStack {
                Spacer()
                Text("Transportation 42%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                    .cornerRadius(4)
                    .offset(y: -10)
            }
        }
        .padding(20)
    }
}

struct LegendItemView: View {
    let color: Color
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(text)
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
}

// MARK: - 4. Original Cards (With robust image frames)
struct ProfileCardView: View {
    var body: some View {
        PatternCard(
            colors: [Color(red: 0.64, green: 0.74, blue: 0.96), Color(red: 0.55, green: 0.62, blue: 0.94)],
            patterns: [PatternConfig(size: 250, offsetX: 120, offsetY: -60)]
        ) {
            HStack(alignment: .center) {
                HStack(spacing: 16) {
                    // Stricly constrained image placeholder
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color(red: 0.94, green: 0.8, blue: 0.84))
                        .background(Color.white)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("David Borg")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("Title: Flying wings")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.9))
                        
                        HStack(spacing: 16) {
                            StatItem(value: "2342", label: "Popularity")
                            StatItem(value: "4736", label: "Like")
                            StatItem(value: "136", label: "followed")
                        }
                        .padding(.top, 12)
                    }
                }
                Spacer()
                VStack(spacing: 4) {
                    Text("•••")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 4)
                    Text("1")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("Ranking")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
    }
    
    struct StatItem: View {
        let value: String
        let label: String
        var body: some View {
            VStack(alignment: .center, spacing: 2) {
                Text(value).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Text(label).font(.system(size: 11)).foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct BouncingShowcaseCardView: View {
    var body: some View {
        BouncingPatternCard(
            colors: [Color(red: 0.42, green: 0.50, blue: 0.97), Color(red: 0.33, green: 0.40, blue: 0.96)],
            patterns: [
                PatternConfig(size: 300, offsetX: 100, offsetY: -100),
                PatternConfig(size: 200, offsetX: -120, offsetY: 120)
            ]
        ) {
            VStack(alignment: .leading, spacing: 20) {
                // Fixed Image modifiers
                Image(systemName: "book.pages")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                
                Text("Showcase Your\nClient Results")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "plus")
                        Text("New Book")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.33, green: 0.40, blue: 0.96))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - 5. Texture Cards Gallery
struct RectangleTextureCard: View {
    @State private var isAnimating = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.orange, Color.red], startPoint: .topLeading, endPoint: .bottomTrailing)
            GeometryReader { geo in
                ForEach(0..<6, id: \.self) { i in
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: CGFloat.random(in: 60...150), height: CGFloat.random(in: 60...150))
                        .cornerRadius(16)
                        .rotationEffect(.degrees(isAnimating ? Double.random(in: 45...180) : 0))
                        .position(
                            x: isAnimating ? CGFloat.random(in: 0...geo.size.width) : CGFloat.random(in: 0...geo.size.width),
                            y: isAnimating ? CGFloat.random(in: 0...geo.size.height) : CGFloat.random(in: 0...geo.size.height)
                        )
                        .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: isAnimating)
                }
            }
            VStack(alignment: .leading) {
                Toggle("Animate Rectangles", isOn: $isAnimating)
                    .font(.headline)
                    .foregroundColor(.white)
                    .tint(.white)
                Spacer()
                Text("Floating Geometry").font(.title2.bold()).foregroundColor(.white)
            }
            .padding(24)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct DashTextureCard: View {
    @State private var isAnimating = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.purple, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(spacing: 16) {
                ForEach(0..<8, id: \.self) { i in
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: i % 2 == 0 ? 120 : 200, height: 8)
                        .frame(maxWidth: .infinity, alignment: i % 2 == 0 ? .leading : .trailing)
                        .offset(x: isAnimating ? (i % 2 == 0 ? 50 : -50) : 0)
                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
                }
            }
            .padding()
            VStack(alignment: .leading) {
                Toggle("Animate Dashes", isOn: $isAnimating)
                    .font(.headline).foregroundColor(.white).tint(.white)
                Spacer()
                Text("Sliding Dashes").font(.title2.bold()).foregroundColor(.white)
            }
            .padding(24)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct DashArcTextureCard: View {
    @State private var isAnimating = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.teal, Color.cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
            ZStack {
                HStack(spacing: 20) {
                    ForEach(0..<5) { _ in
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 8, height: 250)
                            .rotationEffect(.degrees(isAnimating ? 10 : -10))
                    }
                }
                Circle()
                    .trim(from: 0.1, to: 0.5)
                    .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 16, lineCap: .round, dash: [30, 20]))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .offset(x: 100, y: -50)
            }
            .animation(.linear(duration: 15).repeatForever(autoreverses: false), value: isAnimating)
            VStack(alignment: .leading) {
                Toggle("Animate Arcs & Lines", isOn: $isAnimating)
                    .font(.headline).foregroundColor(.white).tint(.white)
                Spacer()
                Text("Dashes & Arcs").font(.title2.bold()).foregroundColor(.white)
            }
            .padding(24)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct ConcentricRingsTextureCard: View {
    @State private var isAnimating = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.pink, Color.red.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
            ZStack {
                ForEach(1..<6, id: \.self) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: 2, dash: [CGFloat(i * 10), 10]))
                        .frame(width: CGFloat(i * 80), height: CGFloat(i * 80))
                        .rotationEffect(.degrees(isAnimating ? (i % 2 == 0 ? 360 : -360) : 0))
                        .animation(.linear(duration: Double(10 + i * 5)).repeatForever(autoreverses: false), value: isAnimating)
                }
            }
            .offset(x: -80, y: 80)
            VStack(alignment: .leading) {
                Toggle("Animate Rings", isOn: $isAnimating)
                    .font(.headline).foregroundColor(.white).tint(.white)
                Spacer()
                Text("Radar Rings").font(.title2.bold()).foregroundColor(.white)
            }
            .padding(24)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct DotGridTextureCard: View {
    @State private var isAnimating = false
    
    // The grid is inherently very wide due to fixed columns
    let columns = Array(repeating: GridItem(.fixed(20), spacing: 20), count: 12)
    
    var body: some View {
        ZStack {
            // 1. The flexible background dictates the actual bounds now
            LinearGradient(colors: [Color.green, Color.mint], startPoint: .topLeading, endPoint: .bottomTrailing)
            
            // 2. GeometryReader prevents the huge grid from blowing up the ZStack's width
            GeometryReader { geo in
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<60, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimating ? (i % 3 == 0 ? 1.5 : 0.5) : 1.0)
                            .opacity(isAnimating ? (i % 2 == 0 ? 0.8 : 0.2) : 0.5)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .delay(Double(i) * 0.02)
                                .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                }
                .rotationEffect(.degrees(-15))
                .scaleEffect(1.5)
                // 3. Keep the grid centered inside the GeometryReader
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            
            VStack(alignment: .leading) {
                Toggle("Animate Grid", isOn: $isAnimating)
                    .font(.headline).foregroundColor(.white).tint(.white)
                Spacer()
                Text("Pulsing Grid").font(.title2.bold()).foregroundColor(.white)
            }
            .padding(24)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - 6. Original Dashboard View
struct OriginalDashboardView: View {
    let savedColor = Color(red: 0.45, green: 0.70, blue: 0.54)
    let spentColor = Color(red: 0.92, green: 0.80, blue: 0.90)
    @State private var showData = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Dashboard")
                    .font(.headline)
                Spacer()
                Toggle(isOn: $showData) {
                    Text("Animate Chart")
                        .font(.caption)
                }
                .labelsHidden()
            }
            .padding(.horizontal, 4)
            
            HStack(spacing: 16) {
                StatCard(title: "Total Spent", value: "3,430.75", prefix: "$", badgeText: "▼ 8%", isPositive: false)
                StatCard(title: "Saved", value: "2,500", prefix: "+ $", prefixColor: savedColor, badgeText: "▲ 20%", isPositive: true)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Monthly Budget").font(.system(size: 14, weight: .bold)).foregroundColor(.gray)
                    Spacer()
                    Text("$3,430.75 ").font(.system(size: 14, weight: .bold))
                    + Text("/$4,000").font(.system(size: 14, weight: .semibold)).foregroundColor(.gray)
                }
                HStack(spacing: 4) {
                    Text("85%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 24)
                        .background(LinearGradient(colors: [Color(red: 0.89, green: 0.74, blue: 0.77), Color(red: 0.83, green: 0.55, blue: 0.60)], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                    HStack(spacing: 4) {
                        ForEach(0..<6, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.2)).frame(width: 6, height: 24)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Progress").font(.system(size: 14, weight: .bold)).foregroundColor(.gray)
                    Spacer()
                    HStack(spacing: 12) {
                        LegendView24(color: spentColor, label: "Spent")
                        LegendView24(color: savedColor, label: "Saved")
                    }
                }
                AnimatedSteppedChart(showData: $showData, savedColor: savedColor, spentColor: spentColor)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .padding(.horizontal)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showData = true
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let prefix: String
    var prefixColor: Color = .gray
    let badgeText: String
    let isPositive: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(.gray)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(prefix).font(.system(size: 16, weight: .semibold)).foregroundColor(prefixColor)
                Text(value).font(.system(size: 24, weight: .bold))
            }
            Text(badgeText)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isPositive ? .green : .red)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(isPositive ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(white: 0.98))
        .cornerRadius(16)
    }
}

struct LegendView24: View {
    let color: Color
    let label: String
    var body: some View {
        HStack(spacing: 4) {
            Rectangle().fill(color).frame(width: 8, height: 8).cornerRadius(2)
            Text(label).font(.system(size: 12, weight: .bold)).foregroundColor(.gray)
        }
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let dayIndex: Int
    let amount: Double
    let category: String
}

struct AnimatedSteppedChart: View {
    @Binding var showData: Bool
    let savedColor: Color
    let spentColor: Color
    @State private var endFraction: CGFloat = 0.0
    @State private var plotSize: CGSize = .zero
    
    let data: [ChartDataPoint] = [
        ChartDataPoint(dayIndex: 0, amount: 20, category: "Saved"), ChartDataPoint(dayIndex: 0, amount: 50, category: "Spent"),
        ChartDataPoint(dayIndex: 3, amount: 30, category: "Saved"), ChartDataPoint(dayIndex: 3, amount: 60, category: "Spent"),
        ChartDataPoint(dayIndex: 6, amount: 50, category: "Saved"), ChartDataPoint(dayIndex: 6, amount: 100, category: "Spent"),
        ChartDataPoint(dayIndex: 9, amount: 80, category: "Saved"), ChartDataPoint(dayIndex: 9, amount: 150, category: "Spent"),
        ChartDataPoint(dayIndex: 12, amount: 100, category: "Saved"), ChartDataPoint(dayIndex: 12, amount: 180, category: "Spent"),
        ChartDataPoint(dayIndex: 15, amount: 120, category: "Saved"), ChartDataPoint(dayIndex: 15, amount: 200, category: "Spent"),
        ChartDataPoint(dayIndex: 18, amount: 150, category: "Saved"), ChartDataPoint(dayIndex: 18, amount: 250, category: "Spent"),
        ChartDataPoint(dayIndex: 21, amount: 200, category: "Saved"), ChartDataPoint(dayIndex: 21, amount: 300, category: "Spent"),
        ChartDataPoint(dayIndex: 24, amount: 250, category: "Saved"), ChartDataPoint(dayIndex: 24, amount: 350, category: "Spent"),
        ChartDataPoint(dayIndex: 27, amount: 350, category: "Saved"), ChartDataPoint(dayIndex: 27, amount: 420, category: "Spent"),
        ChartDataPoint(dayIndex: 30, amount: 500, category: "Saved"), ChartDataPoint(dayIndex: 30, amount: 450, category: "Spent")
    ]
    let xLabels = ["21", "26", "1", "6", "11", "16", "21"]
    
    var body: some View {
        Chart {
            ForEach(data) { point in
                AreaMark(
                    x: .value("Day", point.dayIndex),
                    y: .value("Amount", point.amount)
                )
                .interpolationMethod(.stepEnd)
                .foregroundStyle(by: .value("Category", point.category))
            }
        }
        .chartForegroundStyleScale(["Spent": spentColor, "Saved": savedColor])
        .chartXScale(domain: 0...30)
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: [0, 5, 10, 15, 20, 25, 30]) { value in
                AxisValueLabel {
                    if let index = value.as(Int.self), index / 5 < xLabels.count {
                        Text(xLabels[index / 5]).font(.system(size: 12)).foregroundColor(.gray)
                    }
                }
            }
        }
        .chartLegend(.hidden)
        .frame(height: 140)
        .overlay(content: {
            GeometryReader { proxy in
                DispatchQueue.main.async { self.plotSize = proxy.size }
                return Color.clear
            }
        })
        .mask(Rectangle().fill(Color.white).padding(.trailing, (1 - endFraction) * self.plotSize.width))
        .onChange(of: showData) { newValue in
            if newValue {
                withAnimation(.linear(duration: 1.5)) { endFraction = 1.0 }
            } else {
                endFraction = 0.0
            }
        }
    }
}
