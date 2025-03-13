//
//  StoreKitService.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/11/25.
//

import Combine
import StoreKit
import OSLog

enum LogType {
    
    case info
    case debug
    case error
    
}

// TODO: - REPLACE LOGGER WITH GP_LOGGER WHEN IN REAL PROJECT
// TODO: - Pass in product identifiers as init

final class AppStoreSubscriptionServiceLive: AppStoreSubscriptionServiceProtocol {
    
    @Published private var subscriptionStatus: SubscriptionStatus = .none
    var subscriptionStatusPublisher: AnyPublisher<SubscriptionStatus, Never> {
        return self.$subscriptionStatus.eraseToAnyPublisher()
    }
    
    internal var logger = Logger()
    
    private var products: [Product] = []
    private var subscriptions: [Product] = []
    private var transactionListenerTask: Task<Void, Never>?
    
    private let productIdentifiers: Set<String> = [
        "gentle_path_monthly_subscription",
        "gentle_path_yearly_subscription"
    ]
    
    init() {
        configure()
    }
    
    deinit {
        
        transactionListenerTask?
            .cancel()
        
    }
        
    internal func configure() {
        
        Task {
            
            do {
                
                self.log(message: "Configuring")
                
                transactionListenerTask = Task {
                    await self.listenForTransactions()
                }
                
                try await fetchProducts()
                try await updateSubscriptionStatus()
                
            }
            catch {
                self.log(message: error.localizedDescription)
            }
            
        }
        
    }
    
    // MARK: - PUBLIC METHODS
    
    func fetchProductOfferings() async throws -> [SubscriptionProduct] {
        
        let offerings: [SubscriptionProduct] = self.products.map { product in
            SubscriptionProduct(
                id: product.id,
                title: product.displayName,
                description: product.description,
                price: product.price
            )
        }
        
        return offerings
        
    }
        
    func subscribe(to product: SubscriptionProduct) async throws -> SubscriptionStatus {
        
        guard let storeProduct = self.products.first(where: { $0.id == product.id }) else {
            throw AppStoreSubscriptionError.productNotFound
        }
        
        let result = try await storeProduct.purchase()
        
        switch result {
            
        case .success(let verification):
            
            let transaction = try verify(verification)
            try await updateSubscriptionStatus()
            await transaction.finish()
            
            log(message: "Subscribe Success")
            
            return self.subscriptionStatus
            
        case .userCancelled: throw AppStoreSubscriptionError.userCancelled
        case .pending: throw AppStoreSubscriptionError.purchasePending
        @unknown default: throw AppStoreSubscriptionError.unknownPurchaseResult
        }
        
    }
        
    func restoreSubscriptions() async throws -> SubscriptionStatus {
        
        try await AppStore.sync()
        try await updateSubscriptionStatus()
        
        log(message: "Restored StoreKit Subscriptions; Status: \(self.subscriptionStatus)")
        
        return self.subscriptionStatus
        
    }
        
    func checkSubscriptionStatus() async throws -> SubscriptionStatus {
        
        try await updateSubscriptionStatus()
        log(message: "Receive Subscription Status: \(self.subscriptionStatus)")
        return self.subscriptionStatus
        
    }
        
    func currentSubscriptionProduct() -> SubscriptionProduct? {
        
        if case .active = self.subscriptionStatus,
           let sub = self.subscriptions.first {
            
            return SubscriptionProduct(
                id: sub.id,
                title: sub.displayName,
                description: sub.description,
                price: sub.price
            )
            
        }
        
        return nil
        
    }
    
    // MARK: - PRIVATE METHODS
    
    private func fetchProducts() async throws {
        
        let fetchedProducts = try await Product.products(for: Array(productIdentifiers))
        
        self.products = fetchedProducts
        
        let productNames = fetchedProducts.map({ $0.displayName }).joined(separator: ", ")
        self.log(message: "Fetched Products: \(productNames)")
        
        self.subscriptions = fetchedProducts.filter {
            if case .autoRenewable = $0.type { return true }
            return false
        }
        
    }
        
    private func listenForTransactions() async {
        
        for await result in Transaction.updates {
            
            do {
                
                let transaction = try verify(result)
                try await updateSubscriptionStatus()
                await transaction.finish()
                
            } catch {
                log(.error, message: "Transaction verification failed: \(error.localizedDescription)")
            }
            
        }
        
    }
        
    private func updateSubscriptionStatus() async throws {
        
        var hasActiveSubscription = false
        
        for await result in Transaction.currentEntitlements {
            
            do {
                
                let transaction = try verify(result)
                
                if transaction.productType == .autoRenewable,
                   let expirationDate = transaction.expirationDate,
                   Date() < expirationDate {
                    
                    hasActiveSubscription = true
                    
                    await MainActor.run {
                        self.subscriptionStatus = .active(expiryDate: expirationDate)
                    }
                    
                    break
                    
                }
                
            } catch {
                log(message: "Failed to verify transaction during entitlement check: \(error)")
            }
            
        }
        
        if !hasActiveSubscription {
            
            await MainActor.run {
                self.subscriptionStatus = .none
            }
            
        }
        
    }
        
    private func verify<T>(_ result: VerificationResult<T>) throws -> T {
        
        switch result {
        case .verified(let safe): return safe
        case .unverified: throw AppStoreSubscriptionError.failedVerification
        }
        
    }
    
    private func log(_ logType: LogType = .debug,
                     message: String) {
        
        let prefix = "🛍️🛍️🛍️🛍️🛍️🛍️ [APP_STORE_SUBSCRIPTION_SERVICE]: "
        switch logType {
        case .info: self.logger.info("\(prefix)\(message)")
        case .debug: self.logger.debug("\(prefix)\(message)")
        case .error: self.logger.error("\(prefix)\(message)")
        }
        
    }
    
}
