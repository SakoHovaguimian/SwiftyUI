//
//  DateTimeService.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/27/23.
//

import Foundation

class DateTimeHelper {
    
    enum DateFormat {
        
        /// January 1, 2020
        case monthDateYear
        
        /// Jan 1, 2020
        case shortMonthDateYear
        
        /// 1/1/20
        case numericMonthDateYear
        
        /// January, 2020
        case monthYear
        
        /// Jan, 2020
        case shortMonthYear
        
        /// 2023
        case year
        
        var formatString: String {

            switch self {
            case .monthDateYear: return "MMMM d, yyyy"
            case .shortMonthDateYear: return "MMM d, yyyy"
            case .numericMonthDateYear: return "M/d/yy"
            case .monthYear: return "MMMM, yyyy"
            case .shortMonthYear: return "MMM, yyyy"
            case .year: return "yyyy"
            }

        }
        
    }
    
    enum RelativeDateStyle {
        
        case extraShort
        case short
        case long
        
    }
    
    private static let calendar = Calendar.current
    
    static func formattedDateString(date: Date,
                                    format: DateFormat) -> String? {
        
        return formatter(for: format)
            .string(from: date)
        
    }
    
    static func formattedRelativeDateString(date: Date,
                                            displaySecondsAsNow: Bool,
                                            style: RelativeDateStyle) -> String {
        
        var formattedString = ""
        
        let dateComponent = relativeDateComponents(since: date)
        
        if dateComponent.years > 0 {
            
            switch style {
            case .extraShort: formattedString = dateComponent.years > 1 ? "yrs" : "yr"
            case .short: formattedString = dateComponent.years > 1 ? " yrs" : " yr"
            case .long: formattedString = dateComponent.years > 1 ? " years" : " year"
            }
            
            return "\(dateComponent.years)\(formattedString)"
            
        }

        if dateComponent.months > 0 {
            
            switch style {
            case .extraShort: formattedString = dateComponent.months > 1 ? "mons" : "mo"
            case .short: formattedString = dateComponent.months > 1 ? " mons" : " mon"
            case .long: formattedString = dateComponent.months > 1 ? " months" : " month"
            }
            
            return "\(dateComponent.months)\(formattedString)"
            
        }
        
        if dateComponent.weeks > 0 {
            
            switch style {
            case .extraShort: formattedString = dateComponent.weeks > 1 ? "wks" : "wk"
            case .short: formattedString = dateComponent.weeks > 1 ? " wks" : " wk"
            case .long: formattedString = dateComponent.weeks > 1 ? " weeks" : " week"
            }
            
            return "\(dateComponent.weeks)\(formattedString)"
            
        }
        
        if dateComponent.days > 0 {
            
            switch style {
            case .extraShort: formattedString = dateComponent.days > 1 ? "dys" : "dy"
            case .short: formattedString = dateComponent.days > 1 ? " dys" : " dy"
            case .long: formattedString = dateComponent.days > 1 ? " days" : " day"
            }
            
            return "\(dateComponent.days)\(formattedString)"
            
        }
        
        if dateComponent.hours > 0 {
            
            switch style {
            case .extraShort: formattedString = dateComponent.hours > 1 ? "hrs" : "hr"
            case .short: formattedString = dateComponent.hours > 1 ? " hrs" : " hr"
            case .long: formattedString = dateComponent.hours > 1 ? " hours" : " hour"
            }
            
            return "\(dateComponent.hours)\(formattedString)"
            
        }
        
        if dateComponent.minutes > 0 {
            
            switch style {
            case .extraShort: formattedString = dateComponent.minutes > 1 ? "mins" : "min"
            case .short: formattedString = dateComponent.minutes > 1 ? " mins" : " min"
            case .long: formattedString = dateComponent.minutes > 1 ? " minutes" : " minute"
            }
            
            return "\(dateComponent.minutes)\(formattedString)"
            
        }
        
        if dateComponent.seconds > 0 {
            
            if displaySecondsAsNow {
                return "now"
            }
            
            switch style {
            case .extraShort: formattedString = dateComponent.seconds > 1 ? "secs" : "sec"
            case .short: formattedString = dateComponent.seconds > 1 ? " secs" : " sec"
            case .long: formattedString = dateComponent.seconds > 1 ? " seconds" : " second"
            }
            
            return "\(dateComponent.seconds)\(formattedString)"
            
        }
        
        return "now"
        
    }
    
    // MARK: Private
    
    private static func formatter(for format: DateFormat) -> DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format.formatString
        return formatter
        
    }
    
    private static func relativeDateComponents(since: Date) -> (years: Int,
                                                                months: Int,
                                                                weeks: Int,
                                                                days: Int,
                                                                hours: Int,
                                                                minutes: Int,
                                                                seconds: Int) {
        
        let dateComponents = self.calendar.dateComponents(
            [
                .year,
                .month,
                .weekOfMonth,
                .day,
                .hour,
                .minute,
                .second
            ],
            from: since,
            to: Date()
        )
        
        return (dateComponents.year ?? 0,
                dateComponents.month ?? 0,
                dateComponents.weekOfMonth ?? 0,
                dateComponents.day ?? 0,
                dateComponents.hour ?? 0,
                dateComponents.minute ?? 0,
                dateComponents.second ?? 0)
        
    }
    
}
