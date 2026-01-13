//
//  DayContent.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/4/25.
//

import SwiftUI

// MARK: - Selection Protocols & Policies

protocol SelectionPolicy {
    
    var mode: SelectionMode { get }
    var minStartDate: Date? { get }
    var maxEndDate: Date? { get }
    
    func processTap(at date: Date,
                    currentSelected: [Day],
                    calendar: Calendar) -> [Day]
    
}

extension SelectionPolicy {
    
    func normalized(_ date: Date, calendar: Calendar) -> Date {
        return calendar.startOfDay(for: date)
    }
    
    func isWithinBounds(_ date: Date, calendar: Calendar) -> Bool {
        
        let normalizedDate = self.normalized(date, calendar: calendar)
        
        if let minStart = self.minStartDate, normalizedDate < self.normalized(minStart, calendar: calendar) {
            return false
        }
        
        if let maxEnd = self.maxEndDate, normalizedDate > self.normalized(maxEnd, calendar: calendar) {
            return false
        }
        
        return true
        
    }
    
}

struct SingleSelectionPolicy: SelectionPolicy {
    
    let mode: SelectionMode = .single
    
    let minStartDate: Date?
    let maxEndDate: Date?
    
    init(minStartDate: Date? = nil,
         maxEndDate: Date? = nil) {
        
        self.minStartDate = minStartDate
        self.maxEndDate = maxEndDate
        
    }
    
    func processTap(at date: Date, currentSelected: [Day], calendar: Calendar) -> [Day] {
        
        guard self.isWithinBounds(date, calendar: calendar) else { return currentSelected }
        
        return [Day(date: self.normalized(date, calendar: calendar))]
        
    }
    
}

struct MultiSelectionPolicy: SelectionPolicy {
    
    let mode: SelectionMode = .multi
    let maxSelections: Int?
    
    let minStartDate: Date?
    let maxEndDate: Date?
    
    init(maxSelections: Int?,
         minStartDate: Date? = nil,
         maxEndDate: Date? = nil) {
        
        self.maxSelections = maxSelections
        self.minStartDate = minStartDate
        self.maxEndDate = maxEndDate
        
    }
    
    func processTap(at date: Date, currentSelected: [Day], calendar: Calendar) -> [Day] {
        
        guard self.isWithinBounds(date, calendar: calendar) else { return currentSelected }
        
        var newSelection = currentSelected
        let tappedDate = self.normalized(date, calendar: calendar)
        
        if let index = newSelection.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: tappedDate) }) {
            
            newSelection.remove(at: index)
            
        } else {
            
            if let max = self.maxSelections, newSelection.count >= max {
                return newSelection
            }
            
            newSelection.append(Day(date: tappedDate))
            
        }
        
        return newSelection
        
    }
    
}

struct RangeSelectionPolicy: SelectionPolicy {
    
    let mode: SelectionMode = .range
    let minRange: Int?
    let maxRange: Int?
    
    let minStartDate: Date?
    let maxEndDate: Date?
    
    init(minRange: Int?,
         maxRange: Int?,
         minStartDate: Date? = nil,
         maxEndDate: Date? = nil) {
        
        self.minRange = minRange
        self.maxRange = maxRange
        self.minStartDate = minStartDate
        self.maxEndDate = maxEndDate
        
    }
    
    func processTap(at date: Date, currentSelected: [Day], calendar: Calendar) -> [Day] {
        
        guard self.isWithinBounds(date, calendar: calendar) else { return currentSelected }
        
        let tappedDate = self.normalized(date, calendar: calendar)
        
        // If empty or already a full range, start a new anchor
        if currentSelected.isEmpty || currentSelected.count > 1 {
            return [Day(date: tappedDate)]
        }
        
        let anchorDate = self.normalized(currentSelected[0].date, calendar: calendar)
        
        // Logic: Whatever you select first is valid.
        // If a past date was picked, the new lower range becomes the new pick.
        if tappedDate < anchorDate {
            
            return [Day(date: tappedDate)]
            
        } else if tappedDate == anchorDate {
            
            return [] // Deselect
            
        } else {
            
            // Enforce maxEndDate on range end explicitly (even though tapped was validated)
            if let maxEnd = self.maxEndDate, tappedDate > self.normalized(maxEnd, calendar: calendar) {
                return currentSelected
            }
            
            // Future picked: Calculate range
            let components = calendar.dateComponents([.day], from: anchorDate, to: tappedDate)
            let dayDiff = (components.day ?? 0) + 1
            
            // Apply Max Range Constraint
            if let max = self.maxRange, dayDiff > max {
                return [Day(date: tappedDate)]
            }
            
            // Apply Min Range Constraint
            if let min = self.minRange, dayDiff < min {
                return currentSelected
            }
            
            var range: [Day] = []
            var runner = anchorDate
            
            while runner <= tappedDate {
                
                range.append(Day(date: runner))
                guard let next = calendar.date(byAdding: .day, value: 1, to: runner) else { break }
                runner = next
                
            }
            
            return range
            
        }
        
    }
    
}

// MARK: - Models

enum SelectionMode {
    
    case single
    case multi
    case range
    
}

enum DayContent: Equatable {
    
    case none
    case icon(String)
    case custom
    
}

struct Day: Identifiable, Equatable {
    
    var id: Date { return self.date }
    let date: Date
    
    var isSelected: Bool = false
    var selectedBackgroundColor: Color = .clear
    var selectedTextColor: Color = .white
    
    var contentType: DayContent = .none
    var isCurrentMonth: Bool = true
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self.date)
    }
    
}

// MARK: - View Model

@Observable
class CalendarViewModel {
    
    var days: [Day] = []
    var selectedDays: [Day] = []
    var currentMonth: Date = Date()
    
    private(set) var selectionPolicy: SelectionPolicy = SingleSelectionPolicy()
    
    var selectionColor: Color = .blue
    var selectionTextColor: Color = .white
    var selectionIconName: String? = nil
    
    var didTapDateAction: ((Day) -> ())?
    
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
    func setup(policy: SelectionPolicy,
               selectionColor: Color = .blue,
               selectionTextColor: Color = .white,
               selectionIconName: String? = nil,
               didTapDateAction: @escaping (Day) -> ()) -> Self {
        
        self.selectionPolicy = policy
        self.selectionColor = selectionColor
        self.selectionTextColor = selectionTextColor
        self.selectionIconName = selectionIconName
        self.didTapDateAction = didTapDateAction
        
        self.currentMonth = self.calendar.startOfDay(for: Date())
        
        self.setupCalendar()
        
        return self
        
    }
    
    func setupCalendar() {
        
        var newDays: [Day] = []
        
        let components = self.calendar.dateComponents([.year, .month], from: self.currentMonth)
        guard let firstDayOfMonth = self.calendar.date(from: components) else { return }
        
        let range = self.calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        let firstWeekday = self.calendar.component(.weekday, from: firstDayOfMonth)
        
        let prevMonthDays = (firstWeekday - self.calendar.firstWeekday + 7) % 7
        if prevMonthDays > 0 {
            
            let prevMonthDate = self.calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth)!
            let prevMonthRange = self.calendar.range(of: .day, in: .month, for: prevMonthDate)!
            
            for i in (prevMonthRange.count - prevMonthDays + 1)...prevMonthRange.count {
                if let date = self.calendar.date(byAdding: .day, value: i - 1, to: self.calendar.date(from: self.calendar.dateComponents([.year, .month], from: prevMonthDate))!) {
                    newDays.append(Day(date: date, isCurrentMonth: false))
                }
            }
            
        }
        
        for i in 0..<range.count {
            if let date = self.calendar.date(byAdding: .day, value: i, to: firstDayOfMonth) {
                newDays.append(Day(date: date, isCurrentMonth: true))
            }
        }
        
        let additionalDays = 42 - newDays.count
        if additionalDays > 0 {
            
            let nextMonthDate = self.calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth)!
            for i in 0..<additionalDays {
                if let date = self.calendar.date(byAdding: .day, value: i, to: nextMonthDate) {
                    newDays.append(Day(date: date, isCurrentMonth: false))
                }
            }
            
        }
        
        self.days = newDays
        self.applySelectionState()
        
    }
    
    func applySelectionState() {
        
        let selectedDates = Set(self.selectedDays.map { self.calendar.startOfDay(for: $0.date) })
        
        for index in self.days.indices {
            
            let dayDate = self.calendar.startOfDay(for: self.days[index].date)
            let isSelected = selectedDates.contains(dayDate)
            
            self.days[index].isSelected = isSelected
            self.days[index].selectedBackgroundColor = isSelected ? self.selectionColor : .clear
            self.days[index].selectedTextColor = self.selectionTextColor
            
            if isSelected, let icon = self.selectionIconName {
                self.days[index].contentType = .icon(icon)
            } else {
                self.days[index].contentType = .none
            }
            
        }
        
    }
    
    func toggleDaySelection(_ day: Day) {
        
        self.didTapDateAction?(day)
        
        self.selectedDays = self.selectionPolicy.processTap(
            at: day.date,
            currentSelected: self.selectedDays,
            calendar: self.calendar
        )
        
        self.applySelectionState()
        
    }
    
    func goToNextMonth() {
        if let next = self.calendar.date(byAdding: .month, value: 1, to: self.currentMonth) {
            self.currentMonth = next
            self.setupCalendar()
        }
    }
    
    func goToPreviousMonth() {
        if let prev = self.calendar.date(byAdding: .month, value: -1, to: self.currentMonth) {
            self.currentMonth = prev
            self.setupCalendar()
        }
    }
    
    func getRangePosition(for day: Day) -> RangePosition {
        
        guard self.selectionPolicy.mode == .range, self.selectedDays.count >= 2 else { return .none }
        
        let sorted = self.selectedDays.map { $0.date }.sorted()
        
        if self.calendar.isDate(day.date, inSameDayAs: sorted.first!) { return .start }
        if self.calendar.isDate(day.date, inSameDayAs: sorted.last!) { return .end }
        if day.date > sorted.first! && day.date < sorted.last! { return .middle }
        
        return .none
        
    }
    
    enum RangePosition { case start, middle, end, none }
    
}

// MARK: - Views

struct CustomCalendarView: View {
    
    @State var viewModel = CalendarViewModel()
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 7)
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var cornerRadius: CGFloat = 12
    var dateSelectionStampInset: CGFloat = 4
    
    var body: some View {
        
        VStack(spacing: 15) {
            
            HStack {
                
                Button {
                    self.viewModel.goToPreviousMonth()
                } label: { Image(systemName: "chevron.left").transaction { t in
                    t.animation = nil
                } }
                
                Spacer()
                
                Text(self.viewModel.currentMonthTitle)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button {
                    self.viewModel.goToNextMonth()
                } label: { Image(systemName: "chevron.right").transaction { t in
                    t.animation = nil
                } }
                
            }
            .foregroundStyle(.black)
            .padding(.vertical)
            
            LazyVGrid(columns: self.columns, spacing: 5) {
                
                ForEach(self.weekDays, id: \.self) { weekday in
                    Text(weekday).font(.caption).bold().foregroundStyle(.gray)
                }
                
                ForEach(self.viewModel.days) { day in
                    dayCell(day: day)
                }
                
            }
            .id(self.viewModel.currentMonthTitle)
            
        }
        .padding()
        .background(Color.white)
        
    }

    @ViewBuilder
    private func dayCell(day: Day) -> some View {
        
        let position = self.viewModel.getRangePosition(for: day)
        let policy = self.viewModel.selectionPolicy
        
        let isRange = self.viewModel.selectionPolicy.mode == .range
        let clipShape = isRange ? 0 : self.cornerRadius
        
        var foregroundColor: Color {
            
            if day.isSelected {
               return .white
            }

            if let minStartDate = policy.minStartDate {
                
                if day.date.dateAtStartOf(.day) < minStartDate.date.dateAtStartOf(.day) {
                    return .red.opacity(0.2)
                }
                
            }
            
            if let maxEndDate = policy.maxEndDate {
                
                if day.date.dateAtStartOf(.day) > maxEndDate.dateAtStartOf(.day) {
                    return .red.opacity(0.8)
                }
                
            }
            
            if day.isCurrentMonth {
                return .black
            }

            return .gray.opacity(0.5)
            
        }
        
        ZStack {
            
            if day.isSelected {
                
                selectionShape(for: position)
                    .padding(!isRange ? self.dateSelectionStampInset : 0)
                    .foregroundStyle(self.viewModel.selectionColor)
                    .clipShape(self.cornerRadius > 24 ? AnyShape(.circle) : AnyShape(.rect(cornerRadius: clipShape)))
                
            }
            
            if case .icon(let name) = day.contentType {
                Image(systemName: name).foregroundStyle(day.selectedTextColor)
            } else {
                Text("\(Calendar.current.component(.day, from: day.date))")
                    .foregroundStyle(foregroundColor)
            }
            
        }
        .frame(height: 40)
        .onTapGesture {
            withAnimation(.snappy(duration: 0.2)) {
                self.viewModel.toggleDaySelection(day)
            }
        }
        
    }
    
    @ViewBuilder
    private func selectionShape(for position: CalendarViewModel.RangePosition) -> some View {
        
        switch position {
        case .start:
            UnevenRoundedRectangle(topLeadingRadius: self.cornerRadius, bottomLeadingRadius: self.cornerRadius)
        case .end:
            UnevenRoundedRectangle(bottomTrailingRadius: self.cornerRadius, topTrailingRadius: self.cornerRadius)
        case .middle:
            Rectangle()
        case .none:
            RoundedRectangle(cornerRadius: self.cornerRadius)
        }
        
    }
    
}

// MARK: - Previews

// TODO:
/// When selection is too far range up to the max

#Preview("Range (Min 2, Max 7)") {
    
    let vm = CalendarViewModel()
    let policy = RangeSelectionPolicy(minRange: 2, maxRange: 10)
    
    vm.setup(policy: policy, selectionColor: .orange) { _ in }
    
    return ZStack {
        Color(.systemGray6).ignoresSafeArea()
        CustomCalendarView(viewModel: vm, cornerRadius: 12 , dateSelectionStampInset: 0)
            .clipShape(.rect(cornerRadius: 20))
            .padding()
    }
    
}

#Preview("Multi (Max 3)") {
    
    let vm = CalendarViewModel()
    let policy = MultiSelectionPolicy(maxSelections: 3)
    
    vm.setup(policy: policy, selectionColor: .purple, selectionIconName: "star.fill") { _ in }
    
    return ZStack {
        Color(.systemGray6).ignoresSafeArea()
        CustomCalendarView(viewModel: vm)
            .clipShape(.rect(cornerRadius: 20))
            .padding()
    }
    
}

#Preview("Single Selection") {
    
    let vm = CalendarViewModel()
    let policy = SingleSelectionPolicy()
    
    vm.setup(policy: policy, selectionColor: .blue) { _ in }
    
    return ZStack {
        Color(.systemGray6).ignoresSafeArea()
        CustomCalendarView(viewModel: vm)
            .clipShape(.rect(cornerRadius: 20))
            .padding()
    }
    
}

#Preview("Single Selection Min / Max Date") {
    
    let vm = CalendarViewModel()
    let calendar = Calendar.autoupdatingCurrent

    let policy = SingleSelectionPolicy(
        minStartDate: calendar.date(byAdding: .day, value: -3, to: .now),
        maxEndDate: calendar.date(byAdding: .day, value: 3, to: .now)
    )
    
    vm.setup(policy: policy, selectionColor: .blue) { _ in }
    
    return ZStack {
        
        Color(.systemGray6).ignoresSafeArea()
        
        CustomCalendarView(viewModel: vm)
            .clipShape(.rect(cornerRadius: 20))
            .padding()
        
    }
    
}

#Preview("Corner Radius") {
    
    let vm = CalendarViewModel()
    let policy = MultiSelectionPolicy(maxSelections: 3)
    
    vm.setup(policy: policy, selectionColor: .purple, selectionIconName: "star.fill") { _ in }
    
    return ZStack {
        Color(.systemGray6).ignoresSafeArea()
        CustomCalendarView(
            viewModel: vm,
            cornerRadius: 20,
            dateSelectionStampInset: 4
        )
        .clipShape(.rect(cornerRadius: 20))
        .padding()
    }
    
}
