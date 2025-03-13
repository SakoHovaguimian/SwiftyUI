//
//  StoreKitModels.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/11/25.
//

import Foundation

enum SubscriptionStatus: Equatable {
    
    case active(expiryDate: Date)
    case expired
    case none
    
}

struct SubscriptionProduct: Identifiable, Codable, Equatable {
    
    let id: String
    let title: String
    let description: String
    let price: Decimal
    
}

enum AppStoreSubscriptionError: LocalizedError {
    
    case productNotFound
    case userCancelled
    case purchasePending
    case unknownPurchaseResult
    case failedVerification
    
    var errorDescription: String? {
        switch self {
        case .productNotFound: return "Product not found."
        case .userCancelled: return "User cancelled purchase."
        case .purchasePending: return "Purchase is pending approval."
        case .unknownPurchaseResult: return "Unknown purchase result."
        case .failedVerification: return "Failed to verify the transaction."
        }
    }
    
}
