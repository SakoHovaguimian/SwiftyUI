//
//  ParentCoordinator.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/26.
//

import SwiftUI

@MainActor
public protocol ParentCoordinatorProtocol: AnyObject {
    
    var id: UUID { get }
    var router: Router { get }
    
    func removeChild(_ childId: UUID)
    
}
