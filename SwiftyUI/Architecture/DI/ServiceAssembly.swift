//
//  ServiceAssembly.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import Swinject

final
class ServiceAssembly: Assembly {
    
    func assemble(container: Container) {
        
        // API
        
        container
            .register(APIServiceProtocol.self) { r in
                APIService(environmentService: r.resolve(EnvironmentServiceProtocol.self)!)
            }.inObjectScope(.container)
        
        // ENV
        
        container
            .register(EnvironmentServiceProtocol.self) { r in
                EnvironmentService()
            }.inObjectScope(.container)
        
    }
    
}
