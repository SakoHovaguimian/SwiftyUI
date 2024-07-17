//
//  EnvironmentService.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import Foundation
import Combine

enum AppEnvironment: String, CaseIterable {
    
    case dev
    case stg
    case prod
    
}

protocol EnvironmentServiceProtocol: AnyObject {
    
    var environment: AnyPublisher<AppEnvironment, Never> { get }
    func setEnvironment(_ environment: AppEnvironment)
    
}

final
class EnvironmentService: EnvironmentServiceProtocol {
    
    private var _environment: CurrentValueSubject<AppEnvironment, Never> = CurrentValueSubject(.dev)
    var environment: AnyPublisher<AppEnvironment, Never> { self._environment.eraseToAnyPublisher() }
    
    func setEnvironment(_ environment: AppEnvironment) {
        self._environment.send(environment)
    }
    
}
