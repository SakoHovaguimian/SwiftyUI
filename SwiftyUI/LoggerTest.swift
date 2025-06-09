//
//  LoggerTest.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/8/25.
//

import SwiftUI
import OSLog

public protocol ServiceProtocol {
    
    var serviceName: String { get }
    var serviceEmoji: String { get }
    var logger: Logger { get }
    
}

public extension ServiceProtocol {
    
    var logger: Logger {
        
        Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "com.your.app",
            category: serviceName
        )
        
    }
    
    fileprivate func formattedString(title: String = "Log",
                                     message: String,
                                     osLogLevel: OSLogType,
                                     file: StaticString = #file,
                                     function: StaticString = #function,
                                     line: UInt = #line) -> String {
        
        let icons = String(repeating: serviceEmoji, count: 5)
        let header = "\(icons) \(serviceName.uppercased())"
                
        let formattedString = """
        \(header)
        [Title]: \(title)
        [Message]: \(message)
        [File]: \(file)
        [Function]: \(function)
        [Line]: \(line)
        """
        
        return formattedString
        
    }

    func logInit(file: StaticString = #file,
                 function: StaticString = #function,
                 line: UInt = #line) {
        
        let formattedString = formattedString(
            message: "INIT \(self.serviceName.uppercased())",
            osLogLevel: .debug
        )
        
        logger.log(
            level: .debug,
            "\(formattedString)"
        )
        
    }

    func logDeinit(file: StaticString = #file,
                   function: StaticString = #function,
                   line: UInt = #line) {
        
        let formattedString = formattedString(
            message: "DE-INIT \(self.serviceName.uppercased())",
            osLogLevel: .debug
        )
        
        logger.log(
            level: .debug,
            "\(formattedString)"
        )
        
    }

    func log(
        osType: OSLogType = .debug,
        message: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line) {
            
            let formattedString = formattedString(
                message: message,
                osLogLevel: .debug
            )
            
            logger.log(
                level: .debug,
                "\(formattedString)"
            )
            
    }

    /// Error log with optional title
    func error(_ message: String,
               title: String? = nil,
               file: StaticString = #file,
               function: StaticString = #function,
               line: UInt = #line) {
        
        let formattedString = formattedString(
            title: title ?? "Log",
            message: message,
            osLogLevel: .debug
        )
        
        logger.log(
            level: .debug,
            "\(formattedString)"
        )
        
    }
    
}

// ———————————————
// Example usage

public class MyService: ServiceProtocol {
    
    public let serviceName = "MY_SERVICE"
    public let serviceEmoji = "🔧"

    public init() {
        logInit()
    }

    deinit {
        logDeinit()
    }

}

public class MonkeyService: ServiceProtocol {
    
    public let serviceName = "MONKEY_SERVICE"
    public let serviceEmoji = "🦧"
    
    public init() {
        logInit()
    }
    
    deinit {
        logDeinit()
    }
    
}
