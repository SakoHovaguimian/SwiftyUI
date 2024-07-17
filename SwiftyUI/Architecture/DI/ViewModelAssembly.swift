//
//  ViewModelAssembly.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import Foundation
import Swinject

class ViewModelAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container
            .register(DemoViewModel.self) { r in
                DemoViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
    }
    
}
