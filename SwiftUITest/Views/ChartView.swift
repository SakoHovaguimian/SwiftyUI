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
    
    let data = [ChartData(type: "fish", count: 10),
                ChartData(type: "reptils", count: 21),
                ChartData(type: "bird", count: 18), ChartData(type: "dog", count: 40),
                ChartData (type: "cat", count: 65)]
    var body: some View {
        
        Chart(self.data) { data in
            
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
