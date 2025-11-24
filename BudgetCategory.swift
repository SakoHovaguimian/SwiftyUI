
import SwiftUI

struct BudgetSummaryView: View {
    // MARK: - Configuration
    var chartHeight: CGFloat = 300
    
    // I changed the first item to 50 (very small) to demonstrate the 10% rule working
    let data: [BudgetCategory] = [
        BudgetCategory(name: "Savings Goals", value: 5, color: Color(red: 1, green: 0.1, blue: 1.0)), // This is tiny, but will force to 10%
        BudgetCategory(name: "Debt Payments", value: 3, color: Color(red: 0.0, green: 0.48, blue: 1.0)),
        BudgetCategory(name: "Personal Taxes", value: 1000, color: Color(red: 0.0, green: 0.3, blue: 0.8)),
        BudgetCategory(name: "Living Expenses", value: 3525, color: Color(red: 0.0, green: 0.2, blue: 0.6))
    ]
    
    var textColor: Color = .blue
    var barWidth: CGFloat = 60
    var cornerRadius: CGFloat = 12
    
    var body: some View {
        // Use our computed, normalized data instead of raw data
        let segments = getNormalizedSegments()
        
        VStack(spacing: 0) {
            ForEach(segments) { segment in
                ZStack(alignment: .bottomTrailing) {
                    
                    // 1. The Color Bar Segment
                    Rectangle()
                        .fill(segment.category.color)
                        .frame(width: barWidth)
                        .frame(height: segment.height) // Use calculated height
                        // Apply rounding only to the very first item in the list
                        .clipShape(
                            RoundedCornerShape(
                                radius: segment.isFirst ? cornerRadius : 0,
                                corners: [.topLeft, .topRight]
                            )
                        )
                    
                    // 2. The Text Row
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .bottom) {
                            Text(segment.category.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(segment.category.color)
                                .fixedSize(horizontal: true, vertical: false)
                            
                            Spacer()
                            
                            Text("$\(Int(segment.category.value))")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(segment.category.color)
                        }
                        .padding(.trailing, barWidth + 12) // Push text left of the bar
                        
                        // Dashed Line
                        DashedLine()
                            .stroke(.gray, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                            .frame(height: 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: segment.height) // Force the stack to the normalized height
            }
        }
        .frame(height: chartHeight)
        .padding()
        .background(.white)
        .cornerRadius(12)
        .padding()
        .shadow(radius: 6)
    }
    
    // MARK: - The "Minimum 10%" Logic
    
    /// A helper struct to hold the calculated height for the view loop
    struct RenderSegment: Identifiable {
        let id = UUID()
        let category: BudgetCategory
        let height: CGFloat
        let isFirst: Bool
    }
    
    func getNormalizedSegments() -> [RenderSegment] {
        let sortedData = data.sorted { $0.value < $1.value }
        let totalValue = sortedData.reduce(0) { $0 + $1.value }
        let thresholdPct: Double = 0.10 // 10% minimum
        
        // 1. Identify "Small" vs "Large" items
        var smallItems: [Double] = [] // values of small items
        var largeItems: [Double] = [] // values of large items
        
        // Pre-check percentages
        for item in sortedData {
            let pct = item.value / totalValue
            if pct < thresholdPct {
                smallItems.append(item.value)
            } else {
                largeItems.append(item.value)
            }
        }
        
        // 2. Calculate Space Allocation
        // Fixed space taken by forced 10% items
        let heightPerSmall = chartHeight * thresholdPct
        let totalSmallHeight = heightPerSmall * CGFloat(smallItems.count)
        
        // Remaining space for the large items
        let remainingHeight = chartHeight - totalSmallHeight
        let totalLargeValue = largeItems.reduce(0, +)
        
        // 3. Build the final array
        var results: [RenderSegment] = []
        
        for (index, item) in sortedData.enumerated() {
            let pct = item.value / totalValue
            var finalSegmentHeight: CGFloat = 0
            
            if pct < thresholdPct {
                // FORCE to 10% height
                finalSegmentHeight = heightPerSmall
            } else {
                // Scale proportionally into remaining space
                // Share = (MyValue / TotalValueOfBigItems) * RemainingSpace
                let share = item.value / totalLargeValue
                finalSegmentHeight = CGFloat(share) * remainingHeight
            }
            
            results.append(RenderSegment(category: item, height: finalSegmentHeight, isFirst: index == 0))
        }
        
        return results
    }
}

// MARK: - Supporting Models & Shapes

struct BudgetCategory: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
}

struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#Preview {
    BudgetSummaryView(chartHeight: 300)
}
