//
//  DayContent.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/4/25.
//


//
//  MultiCalendarChartView2.swift
//  Rival
//
//  Refactored for Performance
//

import SwiftUI

// MARK: - Models

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
    
    var readOnly: Bool = false
    var selectionColor: Color = .blue
    var selectionTextColor: Color = .white
    var selectionIconName: String? = nil
    
    var didTapDateAction: ((Day) -> ())?
    
    // Performance: Cache Calendar and Formatters
    private var calendar: Calendar = Calendar.autoupdatingCurrent
    
    // Performance: Static formatters prevent allocation on every View refresh
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
    func setup(selectedDays: [Day],
               readOnly: Bool = false,
               selectionColor: Color = .blue,
               selectionTextColor: Color = .white,
               selectionIconName: String? = nil,
               didTapDateAction: @escaping (Day) -> ()) -> Self {
        
        self.selectedDays = selectedDays
        self.readOnly = readOnly
        self.selectionColor = selectionColor
        self.selectionTextColor = selectionTextColor
        self.selectionIconName = selectionIconName
        self.didTapDateAction = didTapDateAction
        
        self.currentMonth = self.calendar.startOfDay(for: Date())
        
        // Normalize selected days to start of day for comparison
        self.selectedDays = self.selectedDays.map {
            var day = $0
            day = Day(
                date: self.calendar.startOfDay(for: $0.date),
                isSelected: $0.isSelected,
                selectedBackgroundColor: $0.selectedBackgroundColor,
                selectedTextColor: $0.selectedTextColor,
                contentType: $0.contentType
            )
            return day
        }
        
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
        let prevMonthDays = firstWeekday - self.calendar.firstWeekday
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
        
        // Next Month Padding
        let totalDays = newDays.count
        let additionalDays = 7 - (totalDays % 7)
        
        if additionalDays < 7 {
            
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
        let selectedDates = Set(self.selectedDays.map { $0.date })
        
        for index in self.days.indices {
            
            let dayDate = self.days[index].date
            
            if selectedDates.contains(dayDate) {
                
                // Find original config
                if let config = self.selectedDays.first(where: { $0.date == dayDate }) {
                    
                    self.days[index].isSelected = true
                    self.days[index].selectedBackgroundColor = config.selectedBackgroundColor
                    self.days[index].selectedTextColor = config.selectedTextColor
                    self.days[index].contentType = config.contentType
                    
                }
                
            } else {
                
                self.days[index].isSelected = false
                self.days[index].selectedBackgroundColor = .clear
                self.days[index].contentType = .none
                
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
    
    func toggleDaySelection(_ day: Day) {
        
        self.didTapDateAction?(day)
        guard !self.readOnly else { return }
        
        if let index = self.days.firstIndex(where: { $0.id == day.id }) {
            
            let isSelected = self.days[index].isSelected
            self.days[index].isSelected.toggle()
            
            if isSelected {
                
                // Deselect
                self.days[index].selectedBackgroundColor = .clear
                self.days[index].contentType = .none
                self.selectedDays.removeAll(where: { $0.date == day.date })
                
            } else {
                
                // Select
                self.days[index].selectedBackgroundColor = self.selectionColor
                self.days[index].selectedTextColor = self.selectionTextColor
                
                if let iconName = self.selectionIconName {
                    self.days[index].contentType = .icon(iconName)
                }
                
                self.selectedDays.append(self.days[index])
                
            }
            
        }
        
    }
    
    // Helper to keep View clean
    func dayString(for day: Day) -> String {
        return Self.dayFormatter.string(from: day.date)
    }
    
}

// MARK: - Views

struct CustomCalendarView: View {
    
    @State var viewModel = CalendarViewModel()
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
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
                    .contentTransition(.numericText()) // iOS 17 Performance
                    .animation(.snappy, value: self.viewModel.currentMonth)
                
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
            LazyVGrid(columns: self.columns, spacing: 15) {
                
                ForEach(self.weekDays, id: \.self) { weekday in
                    
                    Text(weekday)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    
                }
                
                ForEach(self.viewModel.days) { day in
                    
                    dayCell(day: day)
                    
                }
                
            }
            .geometryGroup()
            .compositingGroup()
            .transaction { t in
                t.animation = nil
            }
            
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(Color.white) // Replaced AppColor for compilation
        .animation(.smooth, value: self.viewModel.currentMonth)
        
    }
    
    // Performance: @ViewBuilder extracts logic, keeps "body" clean
    @ViewBuilder
    private func dayCell(day: Day) -> some View {
        
        ZStack {
            
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
        .frame(width: 30, height: 30)
        .background(day.isSelected ? day.selectedBackgroundColor : Color.clear)
        .cornerRadius(8) // Replaced .medium for compilation
        .opacity(day.isCurrentMonth ? 1.0 : 0.3)
        .onTapGesture {
            
            self.viewModel.toggleDaySelection(day)
            
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

#Preview {
    
    let viewModel = CalendarViewModel()
    
    viewModel.setup(
        selectedDays: [],
        readOnly: false,
        selectionColor: .purple,
        selectionTextColor: .white,
        selectionIconName: nil
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

#Preview {
    
    // Icons
    
    let viewModel = CalendarViewModel()
    
    viewModel.setup(
        selectedDays: [],
        readOnly: false,
        selectionColor: .blue,
        selectionTextColor: .white,
        selectionIconName: "person.fill"
    ) { day in
        print("Tapped")
    }
    
    return ZStack {
        Color(.systemGray5).ignoresSafeArea()
        CustomCalendarView(viewModel: viewModel)
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal, 16)
    }
    
}
