//
//  LogChartData.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 10/23/24.
//

import SwiftUI
import Charts
import Foundation

struct LogChartData: Identifiable {
    
    var id = UUID()
    var logType: String
    var totalCount: Int

    init(id: UUID = UUID(),
         logType: String,
         totalCount: Int) {
        
        self.id = id
        self.logType = logType
        self.totalCount = totalCount
        
    }
    
}

struct LineChartView: View {
    @State private var logChartData: [LogChartData]

    init(logChartData: [LogChartData]) {
        self._logChartData = .init(wrappedValue: logChartData)
    }

    let linearGradient = LinearGradient(
        gradient: Gradient(
            colors: [
                Color.brandGreen.opacity(0.4),
                Color.brandGreen.opacity(0.06)
            ]
        ),
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        
        let enumeratedArray = Array(logChartData.enumerated())
        
        Chart {
            
            ForEach(enumeratedArray, id: \.element.id) { index, data in
                
                LineMark(
                    x: .value("Index", index),
                    y: .value("Total Count", data.totalCount)
                )

                PointMark(
                    x: .value("Index", index),
                    y: .value("Total Count", data.totalCount)
                )
                .opacity(0)
                .annotation(position: .overlay, alignment: .bottom, spacing: 24) {
                    Text("\(data.totalCount)")
                        .appFont(with: .body(.b1))
                }
                
            }
            .interpolationMethod(.cardinal)
            .foregroundStyle(.brandGreen)

            ForEach(enumeratedArray, id: \.element.id) { index, data in
                
                AreaMark(
                    x: .value("Index", index),
                    y: .value("Total Count", data.totalCount)
                )
                
            }
            .interpolationMethod(.cardinal)
            .foregroundStyle(linearGradient)
            
        }
        .chartLegend(.hidden)
        .aspectRatio(1, contentMode: .fit)
        .padding()
        
    }
    
}

#Preview {
    
    LineChartView(logChartData: [
        .init(logType: "Info", totalCount: 100),
        .init(logType: "Error", totalCount: 150),
        .init(logType: "Success", totalCount: 200),
        .init(logType: "Debug", totalCount: 250),
        .init(logType: "Fault", totalCount: 300),
        .init(logType: "Info", totalCount: 500)
    ])
    
}

struct BarChartView: View {
    
    @State private var logChartData: [LogChartData]
    
    init(logChartData: [LogChartData]) {
        self._logChartData = .init(wrappedValue: logChartData)
    }

    var body: some View {
        
        Chart {
            
            ForEach(logChartData) { data in
                
                BarMark(
                    x: .value("Log Type", data.logType),
                    y: .value("Total Count", data.totalCount)
                )
                .foregroundStyle(Color.brandGreen)
                .annotation(position: .overlay,
                            alignment: .top,
                            spacing: 4) {
                    
                    Text("\(data.totalCount)")
                        .appFont(with: .body(.b1))
                        .foregroundColor(.primary)
                }
            }
        }
        .chartLegend(.hidden)
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
    
}

#Preview {
    
    BarChartView(logChartData: [
        .init(logType: "Info", totalCount: 100),
        .init(logType: "Error", totalCount: 150),
        .init(logType: "Success", totalCount: 200),
        .init(logType: "Debug", totalCount: 250),
        .init(logType: "Fault", totalCount: 300),
        .init(logType: "Info", totalCount: 500)
    ])
}

struct PieChartView: View {
    
    @State private var selectedCount: Int?
    @State private var selectedSector: String?
    @State private var selectedLogChartData: LogChartData?
    @State private var logChartData: [LogChartData]
    
    init(logChartData: [LogChartData]) {
        self._logChartData = .init(wrappedValue: logChartData)
    }
    
    var body: some View {
        
        Chart {
            
            ForEach(logChartData) { data in
                
                let ratio = selectedSector == data.logType ? 0.3 : 0.65
                
                SectorMark(
                    angle: .value("Total Count", data.totalCount),
                    innerRadius: .ratio(ratio),
                    angularInset: 2.0
                )
                .foregroundStyle(by: .value("Log Type", data.logType))
                .annotation(position: .overlay) {
                    Text("\(data.totalCount)")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .opacity(selectedSector == nil ? 1.0 : (selectedSector == data.logType ? 1.0 : 0.5))
                .cornerRadius((selectedSector == data.logType) ? 300 : 10)
            }
        }
        .frame(height: 500)
        .padding(.horizontal, 24)
        .chartLegend(.visible)
        .chartLegend(position: .bottom, spacing: 0)
        .chartAngleSelection(value: $selectedCount)
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                let frame = geometry[chartProxy.plotFrame!]
                let visibleSize = min(frame.width, frame.height)
                contentOverlay(visibleSize: visibleSize, frame: frame)
            }
        }
        .onChange(of: selectedCount) { oldValue, newValue in
            withAnimation(.bouncy) {
                if let newValue {
                    selectedSector = findSelectedSector(value: newValue)
                } else {
                    selectedSector = nil
                }
            }
        }
    }
    
    private func findSelectedSector(value: Int) -> String? {
        
        var accumulatedCount = 0
        
        let selected = logChartData.first { data in
            accumulatedCount += data.totalCount
            return value <= accumulatedCount
        }
        
        self.selectedLogChartData = selected
        return selected?.logType
        
    }
    
        @ViewBuilder
        private func contentOverlay(visibleSize: CGFloat, frame: CGRect) -> some View {
            
            VStack {
                
                if let selectedSector {
                    
                    Text(selectedSector)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .contentTransition(.numericText())
                    
                    Text("\(selectedLogChartData?.totalCount ?? 0)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    
                } else {
                    
                    let totalSum = logChartData.reduce(0) { $0 + $1.totalCount }
                    
                    Text("\(totalSum)")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    
                }
                     
            }
            .animation(.spring, value: self.selectedSector)
            .frame(maxWidth: visibleSize * 0.618, maxHeight: visibleSize * 0.618)
            .position(x: frame.midX, y: frame.midY)
                     
        }
                     
}

#Preview {
    
    PieChartView(logChartData: [
        .init(logType: "Info", totalCount: 100),
        .init(logType: "Error", totalCount: 150),
        .init(logType: "Success", totalCount: 200),
        .init(logType: "Debug", totalCount: 250),
        .init(logType: "Fault", totalCount: 300),
    ])
    
}

//struct PieChartView: View {
//    
//    @State private var selectedCount: Int?
//    @State private var selectedSector: String?
//    
//    var body: some View {
//        
//        Chart {
//            
//            ForEach(coffeeSales, id: \.name) { coffee in
//                
//                let ratio = selectedSector == coffee.name ? 0.3 : 0.65
//
//                SectorMark(
//                    angle: .value("Cup", coffee.amount),
//                    innerRadius: .ratio(ratio),
//                    angularInset: 2.0
//                )
//                .foregroundStyle(by: .value("Type", coffee.name))
//                .annotation(position: .overlay) {
//                    
//                    Text("\(coffee.amount)")
//                        .font(.headline)
//                        .foregroundStyle(.white)
//                }
//                .opacity(selectedSector == nil ? 1.0 : (selectedSector == coffee.name ? 1.0 : 0.5))
//                .cornerRadius((selectedSector == coffee.name) ? 300 : 10)
//            }
//        }
//        .frame(height: 500)
//        .padding(.horizontal, .xLarge)
//        .chartLegend(.visible)
//        .chartBackground { proxy in
//            
//            Text("☕️")
//                .font(.system(size: 80))
//            
//        }
//        .chartLegend(position: .bottom, spacing: 20)
//        .chartBackground { chartProxy in
//            GeometryReader { geometry in
//                let frame = geometry[chartProxy.plotFrame!]
//                let visibleSize = min(frame.width, frame.height)
//                contentOverlay(visibleSize: visibleSize, frame: frame)
//            }
//        }
//        .chartAngleSelection(value: $selectedCount)
//        .onChange(of: selectedCount) { oldValue, newValue in
//            
//            withAnimation(.bouncy) {
//                if let newValue {
//                    selectedSector = findSelectedSector(value: newValue)
//                } else {
//                    selectedSector = nil
//                }
//            }
//        }
//        
//    }
//    
//    private func findSelectedSector(value: Int) -> String? {
//
//        var accumulatedCount = 0
//
//        let coffee = coffeeSales.first { coffee in
//            accumulatedCount += coffee.amount
//            return value <= accumulatedCount
//        }
//
//        return coffee?.name
//        
//    }
//    
//    @ViewBuilder
//    private func contentOverlay(visibleSize: CGFloat, frame: CGRect) -> some View {
////        if let bestSellingCategory = bestSellingCategory {
//            VStack {
//                Text("Most Sold Category")
//                    .font(.callout)
//                    .foregroundStyle(.secondary)
//
////                Text(bestSellingCategory.displayName)
////                    .font(.title2.bold())
////                    .foregroundColor(.primary)
//
//                Text("1000 sold")
//                    .font(.callout)
//                    .foregroundStyle(.secondary)
//            }
//            .frame(maxWidth: visibleSize * 0.618, maxHeight: visibleSize * 0.618)
//            .position(x: frame.midX, y: frame.midY)
////        }
//    }
//    
//}
//
//#Preview {
//    
//    PieChartView()
//    
//}
