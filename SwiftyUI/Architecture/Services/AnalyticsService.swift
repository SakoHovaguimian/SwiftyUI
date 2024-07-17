//
//  AnalyticsService.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine
import Observation
import Amplitude
import OSLog
import AdSupport

struct EventData {
    
}

protocol AnalyticsServiceProtocol: AnyObject {
    
    var amplitude: Amplitude? { get }
    var currentUserId: String? { get }
    
    var sessionEvents: PassthroughSubject<[EventData], Never> { get }
    
}

@Observable
class AnalyticsService {
 
    private var amplitude: Amplitude?
    
    private(set) var currentUserId: String?
    private var currentIdfa: String = "00000000-0000-0000-0000-000000000000"
    
    private(set) var sessionEvents = PassthroughSubject<[EventData], Never>()
    
    private var environmentService: EnvironmentService?
    private var permissionService: PermissionService?
    private var cancellables = Set<AnyCancellable>()
    
    private let logger = Logger.analytics
    
    init() {
        
        self.logger.info("Starting Analytics Service")
        self.sessionEvents.send([])
        
    }
    
    func setup(environmentService: EnvironmentService,
               permissionService: PermissionService) {
        
        self.environmentService = environmentService
        self.permissionService = permissionService
        
        self.permissionService?
            .appTrackingPermissionService
            .$attStatus
            .sink { status in
                self.updateAdvertisingIdentifierAndStatus(status ?? .notDetermined)
        }
        .store(in: &self.cancellables)
        
        guard environmentService.environment == .production else { return }
        setupAmplitude()
        
    }
    
    private func setupAmplitude() {

        self.amplitude = Amplitude.instance()
        self.amplitude?.initializeApiKey(Constants.Analytics.AMPLITUDE_KEY)
        self.amplitude?.defaultTracking = .initWithSessions(
            true,
            appLifecycles: true,
            deepLinks: true,
            screenViews: false
        )
        self.amplitude?.adSupportBlock = {
            return self.currentIdfa
        }

    }
    
    // MARK: Public
    
    func identifyUser(_ userId: String?) {
                
        self.logger.info("identify: \(userId ?? "nil")")

        self.currentUserId = userId
        
        // Amplitude

        self.amplitude?.setUserId(userId)
        
        // Logging
        
        self.logger.info("USER_ID: \(userId ?? "NIL")")
        
        let loggingEvent = EventData(
            name: "identify",
            properties: ["user_id": (userId != nil) ? userId! : "nil"]
        )
        
        var events = self.sessionEvents.value(or: [])
        events.append(loggingEvent)
        self.sessionEvents.send(events)
        
    }
    
    func setUserProperty(_ key: String,
                         value: String) {
        
        self.logger.info("user_property: [\(key): \(value)]")
        
        // Amplitude

        let identify = AMPIdentify()
        identify.set(key, value: value as NSString)
        self.amplitude?.identify(identify)

        // Logging
        
        self.logger.info("User property: \(key)\n METADATA:\nkey: \(key),\nvalue: \(value)")
    
        let loggingEvent = EventData(
            name: "user_property",
            properties: [key: value]
        )
        
        guard self.environmentService?.environment == .production else { return }

        var events = self.sessionEvents.value(or: [])
        events.append(loggingEvent)
        self.sessionEvents.send(events)

    }
    
    func track(_ app: AppEvent) {
        track(event: app)
    }
    
    func track(screen: ScreenEvent) {
        track(event: screen)
    }
    
    func track(error: ErrorEvent) {
        track(event: error)
    }
    
    private func track(event: AnalyticsEvent) {
        
        let type = event.eventType
        let data = event.eventData
                
        let message = (data.properties != nil) ?
            "\(data.name): \(data.properties!)" :
            data.name
        
        var debugLogMessage = "Analytics event"
        
        switch type {
        case .app:
            
            debugLogMessage = "App: \(data.name)"
            
        case .screen:
            
            if let screenName = data.properties?["screen"] as? String {
                debugLogMessage = "Screen: \(screenName)"
            }
            else {
                debugLogMessage = "Screen event"
            }
            
        case .error:
            
            if let errorName = data.properties?["name"] as? String {
                debugLogMessage = "Error: \(errorName)"
            }
            else {
                debugLogMessage = "Error event"
            }
            
        }

        self.logger
            .info("\(type.displayName.uppercased()):\n\(message)\n\(debugLogMessage)")
        
        guard self.environmentService?.environment == .production else { return }
        
        self.amplitude?.logEvent(
            data.name,
            withEventProperties: data.properties
        )
        
        var events = self.sessionEvents.value(or: [])
        events.append(data)
        self.sessionEvents.send(events)
        
    }
    
    func logout() {
        
        self.logger.info("logout")
        self.currentUserId = nil
        identifyUser(nil)
        
    }
    
    // MARK: Private
    
    private func updateAdvertisingIdentifierAndStatus(_ status: ATTStatus) {
                
        self.currentIdfa = ASIdentifierManager
            .shared()
            .advertisingIdentifier
            .uuidString
        
        // Amplitude: handled via `adSupportBlock` passed
        // in during SDK initialization
        
    }
    
}
