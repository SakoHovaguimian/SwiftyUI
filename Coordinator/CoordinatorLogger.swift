//
//  CoordinatorLogger.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 1/15/26.
//

import Foundation
import os.log

/// Centralized logging for Coordinator navigation operations.
/// Uses OSLog for efficient, structured logging that can be filtered in Console.app
public enum CoordinatorLogger {

    private static let subsystem = "com.swiftyui.coordinator"
    private static let navigationLog = OSLog(subsystem: subsystem, category: "Navigation")
    private static let lifecycleLog = OSLog(subsystem: subsystem, category: "Lifecycle")
    private static let errorLog = OSLog(subsystem: subsystem, category: "Error")

    // MARK: - Navigation Logging

    public static func navigation(_ coordinator: String, _ operation: String, _ details: String = "") {
        let message = details.isEmpty ? operation : "\(operation) - \(details)"
        print(message)
        os_log("%{public}@: %{public}@", log: navigationLog, type: .info, coordinator, message)
    }

    // MARK: - Lifecycle Logging

    public static func lifecycle(_ coordinator: String, _ event: String) {
        print("\(coordinator): \(event)")
        os_log("%{public}@: %{public}@", log: lifecycleLog, type: .info, coordinator, event)
    }

    // MARK: - Error Logging

    public static func error(_ coordinator: String, _ operation: String, _ reason: String) {
        print("\(coordinator): \(operation) - \(reason)")
        os_log("ERROR [%{public}@] %{public}@: %{public}@", log: errorLog, type: .error, coordinator, operation, reason)
    }

    // MARK: - Debug Logging (only in debug builds)

    public static func debug(_ coordinator: String, _ message: String) {
        print("\(coordinator): \(message)")
        #if DEBUG
        os_log("DEBUG [%{public}@] %{public}@", log: navigationLog, type: .debug, coordinator, message)
        #endif
    }
}
