//
//  Snowfall.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/31/24.
//

import SwiftUI

struct Snowflake: Identifiable {
    
    let id = UUID()
    var x: Double
    var y: Double
    var scale: Double
    var speed: Double
    
}

struct SnowfallAnimationView: View {
    
    @State private var snowflakes: [Snowflake] = []
    @State private var timer: Timer?

    var body: some View {
        
        ZStack {
            
            backgroundGradient()
            snowflakeView()
            
            PieChartView(logChartData: [
                .init(logType: "1", totalCount: 10),
                .init(logType: "4", totalCount: 7),
                .init(logType: "5", totalCount: 6),
                .init(logType: "3", totalCount: 5),
                .init(logType: "6", totalCount: 4),
                .init(logType: "2", totalCount: 1)
            ])
            
            
        }
        .onAppear {
            startSnowfall()
        }
        .onDisappear {
            self.timer?.invalidate()
        }
        
    }
    
    private func backgroundGradient() -> some View {
        
        LinearGradient(
            gradient: Gradient(colors: [.blue, .indigo]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
    }
    
    private func snowflakeView() -> some View {
        
        Canvas { context, size in
            
            for snowflake in snowflakes {
                
                context.draw(
                    Text("❄️")
                        .font(.system(size: 10 * snowflake.scale)),
                    at: CGPoint(
                        x: snowflake.x * size.width,
                        y: snowflake.y * size.height
                    )
                    
                )
                
            }
            
        }
        .ignoresSafeArea()
        
    }
    
    func startSnowfall() {
        
        for _ in 0..<25 {
            
            let snowflake = Snowflake(
                x: Double.random(in: 0...1),
                y: Double.random(in: -0.2...0),
                scale: Double.random(in: 0.5...1.5),
                speed: Double.random(in: 0.001...0.003)
            )
            
            self.snowflakes.append(snowflake)
            
        }

        self.timer = Timer.scheduledTimer(
            withTimeInterval: 0.016,
            repeats: true
        ) { _ in
            
            for i in self.snowflakes.indices {
                
                self.snowflakes[i].y += self.snowflakes[i].speed
                
                if self.snowflakes[i].y > 1.0 {
                    
                    self.snowflakes[i].y = -0.2
                    self.snowflakes[i].x = Double.random(in: 0...1)
                    
                }
                
            }
            
        }
        
    }
    
}

#Preview {
    SnowfallAnimationView()
}
