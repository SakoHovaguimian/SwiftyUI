//
//  SequenceTest.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/31/25.
//

import SwiftUI

#Preview {
    
    ZStack {
        
    }
    .task {
        let urls = ["a.com", "b.com", "c.com", "d.com"]

        await urls.concurrentForEach { url in
            
            print("Fetching \(url)...")
            try? await Task.sleep(nanoseconds: UInt64.random(in: 10_000...1_000_000_000)) // Simulate network call
            print("Done \(url)")
            
        }
        
        let names = ["Alice", "Bob", "Charlie"]

        await names.asyncForEach { name in
            
            print("Processing \(name)...")
            try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate async work
            print("\(name) done.")
            
        }
        
    }
    
}

