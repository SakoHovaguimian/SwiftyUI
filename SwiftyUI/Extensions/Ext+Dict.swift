//
//  Ext+Dict.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import Foundation

extension Dictionary where Key == String, Value == Any? {

    func compact() -> [String : Any] {
        self.compactMapValues { $0 }
    }

}

extension Dictionary where Key == String, Value == String? {

    func compact() -> [String : String] {
        self.compactMapValues { $0 }
    }

}
