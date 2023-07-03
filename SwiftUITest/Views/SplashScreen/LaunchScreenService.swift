//
//  LaunchScreenService.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/2/23.
//

import SwiftUI
import Observation

@Observable
class LaunchScreenService {

    private(set) var didFinishLaunching: Bool = false
    
    func setDidCompleteLaunching(_ didComplete: Bool) {
        self.didFinishLaunching = didComplete
    }
    
}
