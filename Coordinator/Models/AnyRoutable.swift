////
////  AnyRoutable.swift
////  AsyncStreamDemo
////
////  Created by Sako Hovaguimian on 1/18/26.
////
//
//import Foundation
//
//@MainActor
//public struct AnyRoutable: @MainActor Routable {
//    
//    public let id: String
//    private let _base: AnyHashable
//    
//    public init<T: Routable>(_ base: T) {
//        
//        self.id = base.id
//        self._base = AnyHashable(base)
//        
//    }
//    
//    public func hash(into hasher: inout Hasher) {
//        self._base.hash(into: &hasher)
//    }
//    
//    public static func == (lhs: AnyRoutable,
//                           rhs: AnyRoutable) -> Bool {
//        
//        return lhs._base == rhs._base
//        
//    }
//    
//    public func `as`<T: Routable>(_ type: T.Type) -> T? {
//        return self._base as? T
//    }
//    
//}
