//
//  DayContent.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/4/25.
//

import SwiftUI

// MARK: - Models

enum SelectionMode {
    case single
    case multi
    case range
}

enum DayContent: Equatable {
    
    case none
    case icon(String) // System Image Name
    case custom
    
}

struct Day: Identifiable, Equatable {
    
    // Performance: Use the date itself as ID to prevent list thrashing
    var id: Date { return self.date }
    let date: Date
    
    var isSelected: Bool = false
    var selectedBackgroundColor: Color = .clear
    var selectedTextColor: Color = .white
    
    // Performance: Store data, not Views
    var contentType: DayContent = .none
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self.date)
    }
    
    var isCurrentMonth: Bool = true
    
}

// MARK: - View Model

@Observable
class CalendarViewModel {
    
    var days: [Day] = []
    var selectedDays: [Day] = []
    var currentMonth: Date = Date()
    
    var selectionMode: SelectionMode = .single
    var readOnly: Bool = false
    var selectionColor: Color = .blue
    var selectionTextColor: Color = .white
    var selectionIconName: String? = nil
    
    var didTapDateAction: ((Day) -> ())?
    
    // Performance: Cache Calendar and Formatters
    private var calendar: Calendar = Calendar.autoupdatingCurrent
    
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var currentMonthTitle: String {
        return Self.monthYearFormatter.string(from: self.currentMonth)
    }
    
    @discardableResult
    func setup(mode: SelectionMode = .single,
               selectedDays: [Day] = [],
               readOnly: Bool = false,
               selectionColor: Color = .blue,
               selectionTextColor: Color = .white,
               selectionIconName: String? = nil,
               didTapDateAction: @escaping (Day) -> ()) -> Self {
        
        self.selectionMode = mode
        self.selectedDays = selectedDays
        self.readOnly = readOnly
        self.selectionColor = selectionColor
        self.selectionTextColor = selectionTextColor
        self.selectionIconName = selectionIconName
        self.didTapDateAction = didTapDateAction
        
        self.currentMonth = self.calendar.startOfDay(for: Date())
        
        setupCalendar()
        
        return self
        
    }
    
    func setupCalendar() {
        
        var newDays: [Day] = []
        
        // Get start of month
        let components = self.calendar.dateComponents([.year, .month], from: self.currentMonth)
        guard let firstDayOfMonth = self.calendar.date(from: components) else { return }
        
        let range = self.calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        let numDays = range.count
        
        let firstWeekday = self.calendar.component(.weekday, from: firstDayOfMonth)
        
        // Previous Month Padding
        let prevMonthDays = (firstWeekday - self.calendar.firstWeekday + 7) % 7
        if prevMonthDays > 0 {
            
            let prevMonthDate = self.calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth)!
            let prevMonthRange = self.calendar.range(of: .day, in: .month, for: prevMonthDate)!
            let prevMonthCount = prevMonthRange.count
            
            for i in (prevMonthCount - prevMonthDays + 1)...prevMonthCount {
                
                if let date = self.calendar.date(byAdding: .day, value: i - 1, to: self.calendar.date(from: self.calendar.dateComponents([.year, .month], from: prevMonthDate))!) {
                    
                    newDays.append(Day(date: date, isCurrentMonth: false))
                    
                }
                
            }
            
        }
        
        // Current Month
        for i in 0..<numDays {
            
            if let date = self.calendar.date(byAdding: .day, value: i, to: firstDayOfMonth) {
                
                newDays.append(Day(date: date, isCurrentMonth: true))
                
            }
            
        }
        
        // Next Month Padding (Maintain 6 rows for layout stability)
        let totalDays = newDays.count
        let additionalDays = 42 - totalDays
        
        if additionalDays > 0 {
            
            let nextMonthDate = self.calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth)!
            
            for i in 0..<additionalDays {
                
                if let date = self.calendar.date(byAdding: .day, value: i, to: nextMonthDate) {
                    
                    newDays.append(Day(date: date, isCurrentMonth: false))
                    
                }
                
            }
            
        }
        
        self.days = newDays
        applySelectionState()
        
    }
    
    func applySelectionState() {
        
        // Performance: Create a Set for O(1) lookups
        let selectedDates = Set(self.selectedDays.map { self.calendar.startOfDay(for: $0.date) })
        
        for index in self.days.indices {
            
            let dayDate = self.calendar.startOfDay(for: self.days[index].date)
            
            if selectedDates.contains(dayDate) {
                
                self.days[index].isSelected = true
                self.days[index].selectedBackgroundColor = self.selectionColor
                self.days[index].selectedTextColor = self.selectionTextColor
                
                if let iconName = self.selectionIconName {
                    self.days[index].contentType = .icon(iconName)
                }
                
            } else {
                
                self.days[index].isSelected = false
                self.days[index].selectedBackgroundColor = .clear
                self.days[index].contentType = .none
                
            }
            
        }
        
    }
    
    func toggleDaySelection(_ day: Day) {
        
        self.didTapDateAction?(day)
        guard !self.readOnly else { return }
        
        let tappedDate = self.calendar.startOfDay(for: day.date)
        
        switch self.selectionMode {
            
        case .single:
            
            self.selectedDays = [day]
            
        case .multi:
            
            if let index = self.selectedDays.firstIndex(where: { self.calendar.isDate($0.date, inSameDayAs: tappedDate) }) {
                self.selectedDays.remove(at: index)
            } else {
                self.selectedDays.append(day)
            }
            
        case .range:
            
            self.handleRangeSelection(tappedDate)
            
        }
        
        self.applySelectionState()
        
    }
    
    private func handleRangeSelection(_ tappedDate: Date) {
        
        if self.selectedDays.isEmpty || self.selectedDays.count > 1 {
            
            // Start fresh with one pick
            self.selectedDays = [Day(date: tappedDate)]
            
        } else {
            
            let firstPick = self.calendar.startOfDay(for: self.selectedDays[0].date)
            
            if tappedDate < firstPick {
                
                // Past date picked: this becomes the new lower bound pick
                self.selectedDays = [Day(date: tappedDate)]
                
            } else if tappedDate > firstPick {
                
                // Future picked: Create sequential range
                var rangeDays: [Day] = []
                var currentDate = firstPick
                
                while currentDate <= tappedDate {
                    
                    rangeDays.append(Day(date: currentDate))
                    guard let nextDate = self.calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                    currentDate = nextDate
                    
                }
                
                self.selectedDays = rangeDays
                
            } else {
                
                // Tapped the same date: Deselect
                self.selectedDays = []
                
            }
            
        }
        
    }
    
    func goToNextMonth() {
        
        if let next = self.calendar.date(byAdding: .month, value: 1, to: self.currentMonth) {
            
            self.currentMonth = next
            setupCalendar()
            
        }
        
    }
    
    func goToPreviousMonth() {
        
        if let prev = self.calendar.date(byAdding: .month, value: -1, to: self.currentMonth) {
            
            self.currentMonth = prev
            setupCalendar()
            
        }
        
    }
    
    func dayString(for day: Day) -> String {
        return Self.dayFormatter.string(from: day.date)
    }
    
}

// MARK: - Views

struct CustomCalendarView: View {
    
    @State var viewModel = CalendarViewModel()
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 7)
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        
        VStack(spacing: 15) {
            
            // Header
            HStack {
                
                Button {
                    
//                    withAnimation {
                        self.viewModel.goToPreviousMonth()
//                    }
                    
                } label: {
                    Image(systemName: "chevron.left")
                }
                .foregroundStyle(self.viewModel.selectionColor)
                
                Spacer()
                
                Text(self.viewModel.currentMonthTitle)
                    .font(.title2)
                    .foregroundStyle(.black)
                
                Spacer()
                
                Button {
                    
//                    withAnimation {
                        self.viewModel.goToNextMonth()
//                    }
                    
                } label: {
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(self.viewModel.selectionColor)
                
            }
            .padding(.vertical)
            
            // Calendar Grid
            LazyVGrid(columns: self.columns, spacing: 5) {
                
                ForEach(self.weekDays, id: \.self) { weekday in
                    
                    Text(weekday)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    
                }
                
                ForEach(self.viewModel.days, id: \.id) { day in
                    
                    dayCell(day: day)
                    
                }
                
            }
            .id(self.viewModel.currentMonthTitle)
            
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(Color.white)
        
    }

    @ViewBuilder
    private func dayCell(day: Day) -> some View {
        
        ZStack {
            
            if day.isSelected {
                
                selectionBackground(for: day)
                    .padding(self.viewModel.selectionMode != .range ? 4 : 0)
                    .foregroundStyle(self.viewModel.selectionColor)
                
            }
            
            if case .icon(let name) = day.contentType {
                
                Image(systemName: name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(day.selectedTextColor)
                
            } else {
                
                Text(self.viewModel.dayString(for: day))
                    .foregroundStyle(getTextColor(for: day))
                
            }
            
        }
        .frame(height: 40)
        .contentShape(Rectangle())
        .opacity(day.isCurrentMonth ? 1.0 : 0.3)
        .onTapGesture {
            
            self.viewModel.toggleDaySelection(day)
            
        }
        
    }
    
    @ViewBuilder
    private func selectionBackground(for day: Day) -> some View {
        
        let isRange = self.viewModel.selectionMode == .range && self.viewModel.selectedDays.count >= 2
        
        if isRange {
            
            let sorted = self.viewModel.selectedDays.map { $0.date }.sorted()
            let isStart = Calendar.current.isDate(day.date, inSameDayAs: sorted.first!)
            let isEnd = Calendar.current.isDate(day.date, inSameDayAs: sorted.last!)
            
            if isStart {
                UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 12)
            } else if isEnd {
                UnevenRoundedRectangle(bottomTrailingRadius: 12, topTrailingRadius: 12)
            } else {
                Rectangle()
            }

        } else {
            
            // Default appearance for single selection or incomplete range
            RoundedRectangle(cornerRadius: 12)
            
        }
        
    }
    
    private func getTextColor(for day: Day) -> Color {
        
        if day.isSelected {
            return day.selectedTextColor
        }
        
        return day.isToday ? self.viewModel.selectionColor : .black
        
    }
    
}

// MARK: - Previews

#Preview("Single Selection") {
    
    let viewModel = CalendarViewModel()
    
    viewModel.setup(
        mode: .single,
        selectionColor: .blue
    ) { day in
        print("Tapped: \(day.date)")
    }
    
    return ZStack {
        Color(.systemGray5).ignoresSafeArea()
        CustomCalendarView(viewModel: viewModel)
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal, 16)
    }
    
}

#Preview("Range Selection") {
    
    let viewModel = CalendarViewModel()
    
    viewModel.setup(
        mode: .range,
        selectionColor: .orange
    ) { day in
        print("Tapped: \(day.date)")
    }
    
    return ZStack {
        Color(.systemGray5).ignoresSafeArea()
        CustomCalendarView(viewModel: viewModel)
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal, 16)
    }
    
}

#Preview("Multi Selection") {
    
    let viewModel = CalendarViewModel()
    
    viewModel.setup(
        mode: .multi,
        selectionColor: .purple,
        selectionIconName: "checkmark"
    ) { day in
        print("Tapped: \(day.date)")
    }
    
    return ZStack {
        Color(.systemGray5).ignoresSafeArea()
        CustomCalendarView(viewModel: viewModel)
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal, 16)
    }
    
}
