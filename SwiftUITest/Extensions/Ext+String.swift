//
//  Ext+String.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/11/23.
//

import Foundation

extension String {
    
    subscript(_ index: Int) -> Character? {
        
        guard index >= 0, index < self.count else {
            return nil
        }

        return self[self.index(self.startIndex, offsetBy: index)]
    }
    
}
