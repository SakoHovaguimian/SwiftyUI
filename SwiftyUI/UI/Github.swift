// TODOs:
/// No Force unwraps
/// 

import SwiftUI

public enum ContributionStyle {
    
    case currentMonth
    case month(numberOfPastMonths: Int, numberOfFutureMonths: Int)
    case year
    
}

public struct ContributionChartView: View {
    
    private let contributionData: [String: Int]
    private let cellSize: CGFloat
    private let spacing: CGFloat
    
    private var startDate: Date?
    private var endDate: Date?
    
    public init(contributionData: [String: Int],
                style: ContributionStyle = .currentMonth,
                cellSize: CGFloat = 32,
                spacing: CGFloat = 2) {
        
        self.contributionData = contributionData
        self.cellSize = cellSize
        self.spacing = spacing
        
        let startEndDates = getStartAndEndDates(for: style)
        
        self.startDate = startEndDates.startDate
        self.endDate = startEndDates.endDate
        
    }
    
    public var body: some View {
        
        let columns = [GridItem(.adaptive(minimum: cellSize), spacing: spacing)]
        
        let totalDays = daysBetween(
            start: startDate ?? .now,
            end: endDate ?? .now
        )
        
        ScrollView {
            
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
        .scrollBounceBehavior(.basedOnSize)
        
    }
    
    /// Formats a Date into a string ("yyyy-MM-dd").
    private func getFormattedDate(from date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: date)
        
    }
    
    /// Returns the date for a given day offset from the startDate.
    private func getDate(forDayIndex dayIndex: Int) -> String {
        
        let notValidDate = "NOT A VALID DATE"
        guard let startDate else { return notValidDate }
        
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: dayIndex, to: startDate)
        
        if let date {
            return getFormattedDate(from: date)
        } else {
            return notValidDate
        }
        
    }
    
    /// Returns the total number of days in the given range (inclusive).
    private func daysBetween(start: Date, end: Date) -> Int {
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        
        return (components.day ?? 0) + 1
        
    }
    
    private func getStartAndEndDates(for style: ContributionStyle) -> (startDate: Date, endDate: Date) {
        
        let calendar = Calendar.current
        let now = Date()
        
        switch style {
        case .currentMonth:
            
            let components = calendar.dateComponents([.year, .month], from: .now)
            
            guard let firstDayOfMonth = calendar.date(from: components),
                  let addedMonthStart = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth),
                  let lastDayOfMonth = calendar.date(byAdding: .day, value: -1, to: addedMonthStart),
                  let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
                
                return (now, now)
                
            }
            
            return (
                calendar.startOfDay(for: firstDayOfMonth),
                calendar.startOfDay(for: lastDayOfMonth)
            )
            
        case .month(let numberOfPastMonths, let numberOfFutureMonths):
            
            guard let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
                  let start = calendar.date(byAdding: .month, value: -numberOfPastMonths, to: currentMonthStart),
                  let futureDate = calendar.date(byAdding: .month, value: numberOfFutureMonths, to: currentMonthStart),
                  let range = calendar.range(of: .day, in: .month, for: futureDate),
                  let end = calendar.date(byAdding: .day, value: range.count - 1, to: futureDate) else {
                
                return (now, now)
                
            }
            
            return (start, end)
            
        case .year:
            
            guard let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)),
                  let end = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startOfYear) else {

                return (now, now)
                
            }
            
            return (startOfYear, end)
        }
        
    }
    
    private func colorForContribution(_ count: Int) -> Color {
        
        switch count {
        case _ where count <= 0: return Color(uiColor: .systemGray5)
        case 1...2: return Color.green.opacity(0.3)
        case 3...5: return Color.green.opacity(0.5)
        case _ where count > 5: return Color.green
        default: return Color.green
        }
        
    }
    
}

#Preview {
    
    return ContributionChartView(
        contributionData: [
            "2025-01-01": 1,
            "2025-02-01": 1,
            "2025-03-01": 1,
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
            "2025-04-16": 9,
            "2025-05-16": 9,
            "2025-06-16": 9,
            "2025-07-16": 9,
            "2025-12-31": 1
        ],
        style: .year,
        cellSize: 28
    )
    .frame(maxWidth: .infinity)
    
}
