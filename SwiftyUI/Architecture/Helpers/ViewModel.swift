//
//  ViewModel.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import Foundation

protocol Trackable {
    
    func track()
    
}

typealias ViewModelDefinition = (AnyObject & Identifiable & Hashable & Trackable)

protocol ViewModel: ViewModelDefinition {}

extension ViewModel {
  static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs === rhs
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
}
