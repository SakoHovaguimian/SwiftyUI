//
//  TimePickerView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 11/18/25.
//

import SwiftUI

public struct WheelTime: Equatable, Hashable {
    
    public enum Period: String, CaseIterable, Identifiable, Hashable {
        case am = "AM"
        case pm = "PM"
        
        public var id: String {
            self.rawValue
        }
    }
    
    public var hour: Int       // 1...12
    public var minute: Int     // 0...59
    public var period: Period
    
    public init(hour: Int,
                minute: Int,
                period: Period) {
        
        self.hour = hour
        self.minute = minute
        self.period = period
        
    }
    
}

public struct WheelTimePicker: View {
    
    // MARK: - Internal Models
    
    public struct HourOption: Identifiable, Hashable {
        
        public let value: Int
        
        public var id: Int {
            self.value
        }
        
        public init(_ value: Int) {
            self.value = value
        }
        
    }
    
    public struct MinuteOption: Identifiable, Hashable {
        
        public let value: Int
        
        public var id: Int {
            self.value
        }
        
        public init(_ value: Int) {
            self.value = value
        }
        
    }
    
    public struct PeriodOption: Identifiable, Hashable {
        
        public let value: WheelTime.Period
        
        public var id: WheelTime.Period {
            self.value
        }
        
        public init(_ value: WheelTime.Period) {
            self.value = value
        }
        
    }
    
    // MARK: - Properties
    
    @Binding private var time: WheelTime
    
    @State private var selectedHour: HourOption?
    @State private var selectedMinute: MinuteOption?
    @State private var selectedPeriod: PeriodOption?
    
    private let hours: [HourOption]
    private let minutes: [MinuteOption]
    private let periods: [PeriodOption]
    
    // MARK: - Init
    
    public init(time: Binding<WheelTime>) {
        
        self._time = time
        
        let allHours = (1...12).map { HourOption($0) }
        let allMinutes = (0..<60).map { MinuteOption($0) }
        let allPeriods = WheelTime.Period.allCases.map { PeriodOption($0) }
        
        self.hours = allHours
        self.minutes = allMinutes
        self.periods = allPeriods
        
        let initialHour = allHours.first(where: { $0.value == time.wrappedValue.hour }) ?? allHours.first
        let initialMinute = allMinutes.first(where: { $0.value == time.wrappedValue.minute }) ?? allMinutes.first
        let initialPeriod = allPeriods.first(where: { $0.value == time.wrappedValue.period }) ?? allPeriods.first
        
        self._selectedHour = State(initialValue: initialHour)
        self._selectedMinute = State(initialValue: initialMinute)
        self._selectedPeriod = State(initialValue: initialPeriod)
        
    }
    
    // MARK: - Body
    
    public var body: some View {
        
        HStack(spacing: 8) {
            
            hourWheel()
            minuteWheel()
            periodWheel()
            
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
        .cornerRadius(.large)
        .onChange(of: self.selectedHour) { _, newValue in
            
            guard let newValue else { return }
            self.time.hour = newValue.value
            
        }
        .onChange(of: self.selectedMinute) { _, newValue in
            
            guard let newValue else { return }
            self.time.minute = newValue.value
            
        }
        .onChange(of: self.selectedPeriod) { _, newValue in
            
            guard let newValue else { return }
            self.time.period = newValue.value
            
        }
        
    }
    
    // MARK: - Wheels
    
    @ViewBuilder
    private func hourWheel() -> some View {
        
        WheelPickerView(
            selectedOption: self.$selectedHour,
            options: self.hours,
            sizingStyle: .automatic,
            visibleRows: 4,
            interitemSpacing: 12,
            overlayConfig: .init(strokeColor: Color.mint)
        ) { option, isSelected in
            
            Text("\(option.value)")
                .foregroundStyle(isSelected ? .mint : .gray)
                .font(isSelected ? .title3 : .body)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .animation(.smooth, value: self.hours)
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
    @ViewBuilder
    private func minuteWheel() -> some View {
        
        WheelPickerView(
            selectedOption: self.$selectedMinute,
            options: self.minutes,
            sizingStyle: .automatic,
            visibleRows: 4,
            interitemSpacing: 12,
            overlayConfig: .init(strokeColor: Color.mint)
        ) { option, isSelected in
            
            Text(String(format: "%02d", option.value))
                .foregroundStyle(isSelected ? .mint : .gray)
                .font(isSelected ? .title3 : .body)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .animation(.smooth, value: self.minutes)
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
    @ViewBuilder
    private func periodWheel() -> some View {
        
        WheelPickerView(
            selectedOption: self.$selectedPeriod,
            options: self.periods,
            sizingStyle: .automatic,
            visibleRows: 4,
            interitemSpacing: 12,
            overlayConfig: .init(strokeColor: Color.mint)
        ) { option, isSelected in
            
            Text(option.value.rawValue)
                .foregroundStyle(isSelected ? .mint : .gray)
                .font(isSelected ? .title3 : .body)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .animation(.smooth, value: self.periods)
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
}

fileprivate struct WheelTimePickerDemo: View {
    
    @State private var time = WheelTime(
        hour: 1,
        minute: 00,
        period: .am
    )
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            WheelTimePicker(time: self.$time)
            
            Text("Selected: \(time.hour):\(String(format: "%02d", time.minute)) \(time.period.rawValue)")
                .font(.subheadline)
            
        }
        .padding()
        
    }
    
}

#Preview {
    
    WheelTimePickerDemo()
    
}
