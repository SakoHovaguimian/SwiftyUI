//
//  UserDefaultsKeyProtocol.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/17/25.
//


import Foundation

public protocol UserDefaultsKeyProtocol: RawRepresentable where RawValue == String { }

public enum HomeUserDefaults: String, UserDefaultsKeyProtocol {
    
    case favorites
    case didShowSomething
    
}

public enum SearchUserDefaults: String, UserDefaultsKeyProtocol {
    
    case favoriteList
    case testList
    
}

public class UserDefaultsService: ObservableObject {
    
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(defaults: UserDefaults = .standard,
         encoder: JSONEncoder = JSONEncoder(),
         decoder: JSONDecoder = JSONDecoder()) {
        
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
        
    }
    
    // MARK: - Single Value Support
    
    public func get<T: Codable, K: UserDefaultsKeyProtocol>(key: K, as type: T.Type = T.self) -> T? {
        
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            
            print("Failed to decode \(T.self) for key \(key.rawValue): \(error)")
            return nil
            
        }
        
    }
    
    public func set<T: Codable, K: UserDefaultsKeyProtocol>(key: K, value: T) {
        
        do {
            
            let encoded = try encoder.encode(value)
            defaults.set(encoded, forKey: key.rawValue)
            
        } catch {
            print("Failed to encode \(T.self) for key \(key.rawValue): \(error)")
        }
        
        objectWillChange.send()
        
    }
    
    public func remove<K: UserDefaultsKeyProtocol>(key: K) {
        
        defaults.removeObject(forKey: key.rawValue)
        objectWillChange.send()
        
    }
    
    // MARK: - Collection Support
    
    public func getCollection<C: Collection, K: UserDefaultsKeyProtocol>(key: K, as type: C.Type = C.self) -> C? where C: Codable {
        
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        
        do {
            return try decoder.decode(C.self, from: data)
        } catch {
            
            print("Failed to decode collection for key \(key.rawValue): \(error)")
            return nil
            
        }
        
    }
    
}
