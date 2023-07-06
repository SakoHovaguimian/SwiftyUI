//
//  TimeManager.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/6/23.
//

import SwiftUI
import Observation

@Observable
class TimerManager {
    
    var displayedValue = 0.0
    var shouldIncrement = false
    var value = 0.75
    
    func startTimer() {
        
        Timer.scheduledTimer(
            withTimeInterval: 0.01,
            repeats: true) { [self] timer in
                
                if self.shouldIncrement {
                    
                    if self.displayedValue < self.value {
                        self.displayedValue += 0.01
                    }
                    else {
                        timer.invalidate()
                    }
                }
                else {
                    if self.displayedValue > self.value {
                        self.displayedValue -= 0.01
                    } else {
                        timer.invalidate()
                    }
                }
            }
    }
    
    func setValue(_ value: Double) {
        
        self.shouldIncrement = value > self.value
        self.value = value
        
    }
    
}
