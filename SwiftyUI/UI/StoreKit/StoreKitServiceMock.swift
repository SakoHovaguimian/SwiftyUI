//
//  StoreKitServiceMock.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/11/25.
//

import Foundation
import OSLog
import Combine

final class AppStoreSubscriptionServiceMock: AppStoreSubscriptionServiceProtocol {
    
    internal var logger = Logger()
    
    @Published private var subscriptionStatus: SubscriptionStatus = .none
    var subscriptionStatusPublisher: AnyPublisher<SubscriptionStatus, Never> {
        return self.$subscriptionStatus.eraseToAnyPublisher()
    }
    
    func configure() async throws {
        self.subscriptionStatus = .none
    }
    
    func fetchProductOfferings() async throws -> [SubscriptionProduct] {
        
        return [
            
            SubscriptionProduct(
                id: "mock.subscription.monthly",
                title: "Monthly Membership",
                description: "Enjoy premium features every month.",
                price: 3.00
            ),
            SubscriptionProduct(
                id: "mock.subscription.yearly",
                title: "Yearly Membership",
                description: "Enjoy premium features for the whole year.",
                price: 24.00
            )
            
        ]
        
    }
    
    func subscribe(to product: SubscriptionProduct) async throws -> SubscriptionStatus {
        
        if product.id == "mock.subscription.monthly" {
            
            let expiry = Calendar.current.date(
                byAdding: .month,
                value: 1,
                to: Date()
            )!
            
            self.subscriptionStatus = .active(expiryDate: expiry)
            
        } else if product.id == "mock.subscription.yearly" {
            
            let expiry = Calendar.current.date(
                byAdding: .year,
                value: 1,
                to: Date()
            )!
            
            self.subscriptionStatus = .active(expiryDate: expiry)
            
        }
        
        return self.subscriptionStatus
        
    }
    
    func checkSubscriptionStatus() async throws -> SubscriptionStatus {
        return self.subscriptionStatus
    }
    
    func restoreSubscriptions() async throws -> SubscriptionStatus {
        
        let expiry = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: Date()
        )!
        
        self.subscriptionStatus = .active(expiryDate: expiry)
        return self.subscriptionStatus
        
    }
    
    func currentSubscriptionProduct() -> SubscriptionProduct? {
        
        if case .active = self.subscriptionStatus {
            
            return SubscriptionProduct(
                id: "mock.subscription.monthly",
                title: "Monthly Membership",
                description: "Enjoy premium features every month.",
                price: 3.00
            )
            
        }
        
        return nil
        
    }
    
}
