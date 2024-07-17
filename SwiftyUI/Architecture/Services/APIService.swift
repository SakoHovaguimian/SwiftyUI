//
//  APIService.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import Foundation
import Combine

protocol APIServiceProtocol: AnyObject {
        
    func getString() -> String
    func getValueFromEnvService() -> AppEnvironment
    
}

final
class APIService: APIServiceProtocol {
    
    private let environmentService: EnvironmentServiceProtocol
    private var cancelBag = CancelBag()
    
    init(environmentService: EnvironmentServiceProtocol) {
        
        self.environmentService = environmentService
        setupSubscribers()
        
    }
    
    func getString() -> String {
        return "THIS IS SOME VALUE"
    }
    
    func getValueFromEnvService() -> AppEnvironment {
        return self.environmentService.environment.value
    }
    
    private func setupSubscribers() {
        
        self.environmentService
            .environment
            .receiveOnMain()
            .sink { [weak self] env in
                
                let env = self?.getValueFromEnvService()
                print("🕸️🕸️🕸️🕸️🕸️ \(env!)")
                
            }
            .store(in: &self.cancelBag)
        
    }
    
}
