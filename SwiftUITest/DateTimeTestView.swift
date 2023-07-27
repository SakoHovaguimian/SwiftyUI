//
//  DateTimeTestView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/27/23.
//

import SwiftUI

struct DateTimeTestView: View {
    
    var body: some View {
        
        let dateExample = Date()
    
        VStack {
            
            Text(DateTimeHelper.formattedDateString(
                date: dateExample,
                format: .monthDateYear
            )!)
            
            Text(DateTimeHelper.formattedDateString(
                date: dateExample,
                format: .monthYear
            )!)
            
            Text(DateTimeHelper.formattedDateString(
                date: dateExample,
                format: .numericMonthDateYear
            )!)
            
            Text(DateTimeHelper.formattedDateString(
                date: dateExample,
                format: .shortMonthDateYear
            )!)
            
            Text(DateTimeHelper.formattedDateString(
                date: dateExample,
                format: .shortMonthYear
            )!)
            
            Text(DateTimeHelper.formattedDateString(
                date: dateExample,
                format: .year
            )!)
            
            let relativeDate = DateTimeHelper.formattedRelativeDateString(
                date: dateExample.addingTimeInterval(-12345678),
                displaySecondsAsNow: true,
                style: .long
            )
            
            let agoText = Text(" ago").font(.callout).fontWeight(.heavy).fontDesign(.rounded)
            Text(relativeDate) + agoText
            
        }
        
    }
    
}

#Preview {
    DateTimeTestView()
}
