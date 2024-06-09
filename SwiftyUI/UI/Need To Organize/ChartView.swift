//
//  ChartView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/22/23.
//

import SwiftUI
import Charts

struct ChartData: Identifiable {
    
    let type: String
    let count: Int
    
    var id: String {
        return self.type
    }
    
}

struct BarChartExampleView: View {
    
    let data = [ChartData(type: "Sako H", count: 100),
                ChartData(type: "Michael C", count: 100),
                ChartData(type: "KC G", count: 111),
                ChartData(type: "Shaun P", count: 40),
                ChartData (type: "Jorge G", count: 65)]
    
    var body: some View {
        
        let sortedData = data.sorted(by: { $0.count > $1.count })
        
        Chart(sortedData) { data in

            BarMark(
                x: .value("Type", data.type),
                y: .value("Population", data.count)
            )
            .foregroundStyle(by: .value("Type", data.type))
            .annotation(position: .top) {
                
                AvatarView(name: data.type)
                    .shadow(radius: 3)
                
            }
            
        }
//        .chartLegend (.hidden)
//        .chartXAxis (.hidden)
        .aspectRatio(1, contentMode: .fit)
        .padding ()
        
    }
    
}

#Preview {
    BarChartExampleView()
}
