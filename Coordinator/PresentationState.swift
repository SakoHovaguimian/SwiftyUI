//
//  PresentationState.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/26.
//

import SwiftUI
import Observation

@Observable
public final class PresentationState {
    
    public var sheet: (any Routable)?
    public var fullScreenCover: (any Routable)?
    
    public init() {}
    
    public func dismiss() {
        
        self.sheet = nil
        self.fullScreenCover = nil
        
    }
    
}
