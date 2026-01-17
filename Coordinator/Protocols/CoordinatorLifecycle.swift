//
//  CoordinatorLifecycle.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/26.
//

import SwiftUI

/// Protocol for coordinators that need to respond to lifecycle events.
/// Implement this protocol to track coordinator appearance, disappearance, and completion.
@MainActor
public protocol CoordinatorLifecycle {

    /// Called when the coordinator's root view appears in the view hierarchy.
    func coordinatorDidAppear()

    /// Called when the coordinator's root view is about to disappear from the view hierarchy.
    func coordinatorWillDisappear()

    /// Called when the coordinator finishes and is being cleaned up.
    func coordinatorDidFinish()
}
