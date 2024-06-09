//
//  Ext+Date.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import Foundation
import SwiftDate

extension Date {
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self.convertTo(region: .local).date)
    }
    
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self.convertTo(region: .local).date)
    }
    
    func isTomorrow() -> Bool {
        return Calendar.current.isDateInTomorrow(self.convertTo(region: .local).date)
    }
    
    func isInWeekend() -> Bool {
        return Calendar.current.isDateInWeekend(self.convertTo(region: .local).date)
    }
    
    static func devBirthday() -> Self {
        
        let calendar = Calendar.current

        var dateComponents = DateComponents()
        dateComponents.year = 2023
        dateComponents.month = 8
        dateComponents.day = 24

        return calendar.date(from: dateComponents)!
        
    }
    
}

extension Date: RawRepresentable {
    
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
    
}
