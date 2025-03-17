//
//  StoreKitTestImplementation.swift
//
//
//  Created by Sako Hovaguimian on 3/11/25.
//

import SwiftUI
import Combine

final class SubscriptionViewModel: ObservableObject {
    
    @Published var subscriptionStatus: SubscriptionStatus = .none
    @Published var offerings: [SubscriptionProduct] = []
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    let subscriptionService: AppStoreSubscriptionServiceProtocol
    
    init(subscriptionService: AppStoreSubscriptionServiceProtocol = AppStoreSubscriptionServiceMock()) {
        
        self.subscriptionService = subscriptionService
        
        subscriptionService.subscriptionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.subscriptionStatus = status
            }
            .store(in: &cancellables)
        
    }
    
    func configure() {
        
        Task {
            
            do {
                
                try await fetchOfferings()
                try await updateStatus()
                
            } catch {
                
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
                
            }
            
        }
        
    }
    
    func fetchOfferings() async throws {
        
        let products = try await subscriptionService.fetchProductOfferings()
        
        await MainActor.run {
            self.offerings = products
        }
        
    }
    
    func purchase(product: SubscriptionProduct) {
        
        Task {
            
            do {
                _ = try await subscriptionService.subscribe(to: product)
            } catch {
                
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
                
            }
            
        }
        
    }
    
    func updateStatus() async throws {
        
        let status = try await subscriptionService.checkSubscriptionStatus()
        
        await MainActor.run {
            self.subscriptionStatus = status
        }
        
    }
    
    func restore() {
        
        Task {
            
            do {
                _ = try await subscriptionService.restoreSubscriptions()
            } catch {
                
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
                
            }
            
        }
        
    }
    
}


// ******************************
// MARK: - Subscription View
// ******************************

struct SubscriptionView: View {
    
    @StateObject private var viewModel = SubscriptionViewModel()
    
    var body: some View {
        
        NavigationView {
            
            VStack(spacing: 16) {
                
                // Error Message
                if let error = viewModel.errorMessage {
                    
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                    
                }
                
                Group {
                    
                    // Subscription Status
                    
                    var string: String {
                        switch viewModel.subscriptionStatus {
                        case .active(let expiryDate):
                            
                            return "Subscription active until \(expiryDate.formatted(date: .abbreviated, time: .omitted))"
                            
                        case .expired: return "Subscription expired"
                        case .none: return "Not Subscribed"
                        }
                    }

                    Text(string)
                        .font(.headline)
                        .contentTransition(.numericText())
                    
                }
                .animation(.spring, value: self.viewModel.subscriptionStatus)
                                
                ForEach(viewModel.offerings, id: \.id) { product in
                    
                    AppCardView {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            
                            Text(product.title)
                                .font(.title3)
                            
                            Text(product.description)
                                .font(.subheadline)
                            
                            Text(product.price, format: .currency(code: "USD"))
                                .font(.headline)
                            
                            Button(action: {
                                viewModel.purchase(product: product)
                            }) {
                                Text("Subscribe")
                                    .font(.body)
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Restore Purchases") {
                                viewModel.restore()
                            }
                            .padding()
                        }
                        .padding(.vertical, 8)
                        
                    }
                    .padding(.horizontal, .large)
                    
                }
                
            }
            .navigationTitle("Subscriptions")
            .onAppear {
                viewModel.configure()
            }
            
        }
        
    }
    
}


// ******************************
// MARK: - Preview
// ******************************

#Preview {
    SubscriptionView()
}
