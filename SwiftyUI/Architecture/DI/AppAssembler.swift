//
//  AppAssembler.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import Foundation
import Swinject

/// For fun; not actually keeping
var globalResolver: Resolver!

class AppAssembler {
    
  private let assembler: Assembler
  
  var resolver: Resolver { self.assembler.resolver }
  
  init() {
      
    self.assembler = Assembler([
      ServiceAssembly(),
      ViewModelAssembly(),
    ])
      
    globalResolver = resolver
      
  }
    
}
