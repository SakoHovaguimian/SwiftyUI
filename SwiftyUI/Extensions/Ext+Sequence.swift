
//
//  Ext+Sequence.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/31/25.
//

extension Sequence {
    
    func asyncForEach(_ operation: @escaping (Element) async -> Void) async {
        
        for element in self {
            await operation(element)
        }
        
    }
    
    func withThrowingAsyncForEach(_ operation: @escaping (Element) throws -> Void) rethrows {
        
        for element in self {
            try operation(element)
        }
        
    }
    
    func concurrentForEach(maxConcurrentTasks: Int = .max,
                           _ operation: @escaping (Element) async -> Void) async {
        
        await withTaskGroup(of: Void.self) { group in
            
            var taskCount = 0
            
            for element in self {
                
                if taskCount >= maxConcurrentTasks {
                    
                    // Wait for one task to complete before adding another
                    await group.next()
                    taskCount -= 1
                    
                }
                
                group.addTask {
                    await operation(element)
                }
                
                taskCount += 1
                
            }
            
            // Wait for all remaining tasks
            while let _ = await group.next() {
                taskCount -= 1
            }
            
        }
        
    }
    
    func withThrowingConcurrentForEach(maxConcurrentTasks: Int = .max,
                           _ operation: @escaping (Element) async throws -> Void) async throws {
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            
            var taskCount = 0
            
            for element in self {
                
                if taskCount >= maxConcurrentTasks {
                    
                    // Wait for one task to complete before adding another
                    try await group.next()
                    taskCount -= 1
                    
                }
                
                group.addTask {
                    try await operation(element)
                }
                
                taskCount += 1
                
            }
            
            // Wait for all remaining tasks
            while let _ = try await group.next() {
                taskCount -= 1
            }
            
        }
        
    }
    
}
