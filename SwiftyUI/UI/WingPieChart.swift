//
//  WingPieChart.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/3/25.
//

import SwiftUI
import Charts

// TODO: -
// BE gives us data based on schema

struct WingChartData: Identifiable {
    
    var id = UUID()
    var color: String
    var title: String
    var percentage: CGFloat
    var amount: Int
    
    init(id: UUID = UUID(),
         color: String,
         title: String,
         percentage: CGFloat,
         amount: Int) {
        
        self.id = id
        self.color = color
        self.title = title
        self.percentage = percentage
        self.amount = amount
        
    }
    
}

struct WingPieChartView: View {
    
    var wingChartData: [WingChartData]
    
    var body: some View {
        
        HStack {
            
            WingPieChart(wingChartData: wingChartData)
            legendView()
            
        }
        
    }

    func legendView() -> some View {
        
        VStack(spacing: 4) {
            
            ForEach(self.wingChartData) { data in
                legendItemView(data)
            }
            
        }
        
    }
    
    func legendItemView(_ data: WingChartData) -> some View {
        
        HStack(spacing: 8) {
            
            HStack(spacing: 4) {
                
                Circle()
                    .fill(Color(hex: data.color))
                
                Text(data.percentage, format: .percent)
                    .font(.caption)
                    .fontWeight(.bold)
                
            }
            .frame(maxHeight: 12)
            
            Text(data.title)
                .font(.caption)
                .foregroundStyle(.gray)
            
            Text(data.amount, format: .currency(code: "USD"))
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
        }
        
    }
}
 
struct WingPieChart: View {
    
    @State private var wingChartData: [WingChartData]
    
    init(wingChartData: [WingChartData]) {
        self._wingChartData = .init(wrappedValue: wingChartData)
    }
    
    var body: some View {
        
        Chart {
            
            ForEach(wingChartData) { data in
                                
                SectorMark(
                    angle: .value("Total Count", data.amount),
                    innerRadius: .automatic,
                    angularInset: 0
                )
                .foregroundStyle(Color(hex: data.color))
                
            }
            
        }
        .chartLegend(.hidden)
        .frame(width: 92, height: 92)
        
    }
    
}

#Preview {
    
    WingPieChartView(wingChartData: [
        .init(color: "#52ffb8", title: "Money", percentage: 0.5, amount: 100),
        .init(color: "#ff3864", title: "Cash", percentage: 0.77, amount: 300),
        .init(color: "#020887", title: "Bonds", percentage: 0.22, amount: 500),
        .init(color: "#0d5d56", title: "Equities", percentage: 0.32, amount: 200),
    ])
    
}
