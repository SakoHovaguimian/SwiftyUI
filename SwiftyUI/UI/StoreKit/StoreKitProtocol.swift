//
//  StoreKit.swift
//  
//
//  Created by Sako Hovaguimian on 3/11/25.
//

import Combine
import Foundation
import StoreKit
import OSLog

protocol AppStoreSubscriptionServiceProtocol: AnyObject {
    
    var subscriptionStatusPublisher: AnyPublisher<SubscriptionStatus, Never> { get }
    var logger: Logger { get }

    func configure() async throws
    func fetchProductOfferings() async throws -> [SubscriptionProduct]
    func subscribe(to product: SubscriptionProduct) async throws -> SubscriptionStatus
    func checkSubscriptionStatus() async throws -> SubscriptionStatus
    func restoreSubscriptions() async throws -> SubscriptionStatus
    func currentSubscriptionProduct() -> SubscriptionProduct?
    
}
