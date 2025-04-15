// TODOs:
/// How to support any numnber of months?
/// Style enum for month(totalMonthsBack) / year
/// No Force unwraps
/// 

import SwiftUI

public struct ContributionChartView: View {
    
    private let contributionData: [String: Int]
    private let cellSize: CGFloat = 32
    private let spacing: CGFloat = 2
    
    public init(contributionData: [String: Int]) {
        self.contributionData = contributionData
    }
    
    public var body: some View {

        let columns = [GridItem(.adaptive(minimum: cellSize), spacing: spacing)]
        let totalDays = getDaysInMonth()
        
        LazyVGrid(columns: columns, spacing: spacing) {
            
            ForEach(0..<totalDays, id: \.self) { dayIndex in
                
                let dateString = getDate(forDayIndex: dayIndex)
                let contributionCount = contributionData[dateString] ?? 0
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(colorForContribution(contributionCount))
                    .frame(width: cellSize, height: cellSize)
                
            }
            
        }
        .padding()
        
    }
    
    // Formats dates into a string like "yyyy-MM-dd"
    private func getFormattedDate(from date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
        
    }
    
    // Instead of counting back from today, we calculate the date by starting from the first day of the current month.
    private func getDate(forDayIndex dayIndex: Int) -> String {
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        let firstDayOfMonth = calendar.date(from: components)!
        let date = calendar.date(byAdding: .day, value: dayIndex, to: firstDayOfMonth)!
        return getFormattedDate(from: date)
        
    }
    
    private func getDaysInMonth() -> Int {
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        let firstDayOfMonth = calendar.date(from: components)!
        return calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count
        
    }
    
    // Returns a different shade of green based on the number of contributions.
    private func colorForContribution(_ count: Int) -> Color {
        
        switch count {
        case _ where count <= 0: return Color(uiColor: .systemGray4)
        case 1...2: return Color.green.opacity(0.3)
        case 3...5: return Color.green.opacity(0.5)
        case _ where count > 5: return Color.green
        default: return Color.green
        }

    }
    
}

#Preview {

    ContributionChartView(contributionData: [
        "2025-04-01": 1,
        "2025-04-05": 1,
        "2025-04-06": 2,
        "2025-04-07": 9,
        "2025-04-08": 1,
        "2025-04-09": 2,
        "2025-04-10": 9,
        "2025-04-11": 4,
        "2025-04-12": 2,
        "2025-04-13": 9,
        "2025-04-14": 4,
        "2025-04-15": 2,
        "2025-04-16": 9
    ])
    .frame(maxWidth: .infinity)
    
}
