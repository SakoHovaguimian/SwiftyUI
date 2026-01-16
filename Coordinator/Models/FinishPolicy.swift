//
//  FinishPolicy.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/26.
//

public enum FinishPolicy: Hashable {
    
    case detach(isAnimated: Bool = false)
    case dismissModal
    case popToRoot
    case popToSelf
    case popCount(Int)
    
}
