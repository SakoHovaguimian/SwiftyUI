//
//  ChartTestView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 8/2/23.
//

import SwiftUI
import Charts

struct SelectionExample: View {
    
    @State private var selectedIndex: Int?
    @State private var numbers: [Double] = []
    
    var body: some View {
        
        ZStack {
            
            Color(uiColor: .systemGray6)
                .ignoresSafeArea()
            
            Chart(Array(zip(numbers.indices, numbers)), id: \.1) { index, number in
                
                BarMark(
                    x: .value("Index", index),
                    y: .value("Number", number)
                )
                
                BarMark(
                    x: .value("Index", index),
                    y: .value("Number", number + 2)
                )
                
//                if let selectedIndex {
//                    RuleMark(x: .value("Index", selectedIndex))
//                        .annotation(position: .automatic) {
//                            Text("j")
//                        }
//                }
            }
            .chartLegend(.hidden)
            .chartXAxis(.hidden)
            .chartYAxis {
               AxisMarks() {
                   AxisGridLine().foregroundStyle(.white)
//                   AxisTick()
                   let value = $0.as(Int.self)!
                   AxisValueLabel {
                       Text("\(value)")
                           .foregroundStyle(.white)
                   }
               }
            }
            .chartXSelection(value: self.$selectedIndex)
            .padding(48)
            .frame(height: 300)
            .background(AppColor.charcoal)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal, 48)
            
        }
        .onAppear(perform: {
        
            self.numbers = [
                1,
                2,
                3,
                4,
                5,
                6,
                7
            ]
            
        })
    }
}

#Preview {
    SelectionExample()
}

struct RangeSelectionExample: View {
    @State private var selectedRange: ClosedRange<Int>?
    @State private var numbers = (0..<10)
        .map { _ in Double.random(in: 0...10) }
    
    var body: some View {
        Chart(Array(zip(numbers.indices, numbers)), id: \.1) { index, number in
            LineMark(
                x: .value("Index", index),
                y: .value("Number", number)
            )
            
            if let selectedRange {
                RectangleMark(
                    xStart: .value("Index", selectedRange.lowerBound),
                    xEnd: .value("Index", selectedRange.upperBound),
                    yStart: .value("Number", 0),
                    yEnd: .value("Number", 10)
                )
                .foregroundStyle(.blue.opacity(0.03 ))
            }
        }
        .chartXSelection(range: $selectedRange)
        .chartGesture { chart in
            DragGesture(minimumDistance: 16)
                .onChanged {
                    chart.selectXRange(
                        from: $0.startLocation.x,
                        to: $0.location.x
                    )
                }
                .onEnded { _ in selectedRange = nil }
        }
    }
}


#Preview {
    RangeSelectionExample()
}

struct DemoChartTest: View {
    
    let markColors: [LinearGradient] = [
        
        LinearGradient(colors: [.pink, .green], startPoint: .leading, endPoint: .trailing),
        LinearGradient(colors: [.blue, .green], startPoint: .leading, endPoint: .trailing),
        LinearGradient(colors: [.orange, .green], startPoint: .leading, endPoint: .trailing),
        LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing),
        LinearGradient(colors: [.cyan, .green], startPoint: .leading, endPoint: .trailing),
        LinearGradient(colors: [.purple, .green], startPoint: .leading, endPoint: .trailing),
        LinearGradient(colors: [.indigo, .green], startPoint: .leading, endPoint: .trailing)
        
    ]
    
    var body: some View {
        
        VStack {
            
            Text("Sako Hovaguimian")
                .font(.largeTitle)
            
            Chart(Pokemon.allPokemon) { pokemon in
                BarMark(
                    x: .value("Type", pokemon.type),
                    y: .value("HP", pokemon.hp)
                )
                .foregroundStyle(by: .value("Name", pokemon.name))
                .annotation(position: .top) {
//                    Text(pokemon.name)
                }
            }
//            .chartForegroundStyleScale(domain: Pokemon.allPokemon.compactMap({ workout in
//                workout.name
//            }), range: self.markColors)
            
            .frame(height: 400)
            
        }
        .frame(height: 300)
//        .background(AppColor.charcoal)
//        .clipShape(RoundedRectangle(cornerRadius: 22))
//        .padding(.horizontal, 48)
        
    }
    
}

#Preview {
    DemoChartTest()
}

struct Workout: Identifiable {
    
    var id = UUID()
    var day: String
    var minutes: Double
    
}

struct Pokemon: Identifiable {
    
    var id = UUID()
    var name: String
    var type: String
    var hp: Double
    
    static let allPokemon: [Pokemon] = [
        
        .init(name: "Charmander", type: "Fire", hp: 100),
        .init(name: "Blastoise", type: "Water", hp: 10),
        .init(name: "Bulbasaur", type: "Grass", hp: 40),
        .init(name: "Squirtle", type: "Water", hp: 40),
        .init(name: "Charzard", type: "Fire", hp: 30),
        .init(name: "Groundon", type: "Ground", hp: 200),
        .init(name: "Steelix", type: "Steel", hp: 300)
    
    ]
    
}

extension Workout {
    
    static let workouts: [Workout] = [
        
        Workout(day: "Mon", minutes: 32),
        Workout(day: "Tue", minutes: 45),
        Workout(day: "Wed", minutes: 56),
        Workout(day: "Thu", minutes: 15),
        Workout(day: "Fri", minutes: 65),
        Workout(day: "Sat", minutes: 8),
        Workout(day: "Sun", minutes: 10)
        
    ]
    
}

