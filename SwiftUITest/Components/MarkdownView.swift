//
//  MarkdownView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/19/23.
//

import SwiftUI

struct PlaygroundView: View {
    var body: some View {
        
        VStack {
            
            Text("`Welcome` to the **Jungle**")
            Text(Date(), style: .date)
            Text(Date(), style: .offset)
            Text(Date(), style: .relative)
            Text(Date(), style: .time)
            Text(Date(), style: .timer)
            
            Text(Date().formatted(
                
                .dateTime.day(.defaultDigits)
                .month(.defaultDigits)
                .year(.defaultDigits)
                
                      
            ) + " and \(Date().formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.defaultDigits))) is the time")
            
            let double: Double = 2.23456.round(to: 2)
            let double1: Double = 2.23456.round(to: 4)
            let truncate: Double = 1.234567.truncate(to: 2)
            
            let _ = print(double)
            let _ = print(double1)
            let _ = print(truncate)
            
            
            Text("\(double, specifier: "%.3f")")
            Text("\(double1, specifier: "%.5f")")
            Text("\(truncate, specifier: "%.2f")")
            
        }
        
    }
}

struct MarkdownView_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundView()
    }
}

extension Double {
    
    func round(to places: Int) -> Double {
        
        let multiplier = Int(pow(10, Double(places)))
        return (self * Double(multiplier)).rounded() / Double(multiplier)
        
    }

    func truncate(to places: Int) -> Double {
        
        let multiplier = Int(pow(10, Double(places)))
        return Double(Int(self * Double(multiplier))) / Double(multiplier)
        
    }
    
}
