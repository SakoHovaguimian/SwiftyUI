//
//  AsyncImageViewModel.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/28/25.
//


import UIKit

class AsyncImageViewModel: ObservableObject {
    
    private let apiService: APIServiceProtocol!
    private let imageCacheService: ImageCacheServiceProtocol!
    
    init(apiService: APIServiceProtocol,
         imageCacheService: ImageCacheServiceProtocol) {
        
        self.apiService = apiService
        self.imageCacheService = imageCacheService
        
    }
    
    init() {
        
        self.apiService = APIService(environmentService: EnvironmentService())
        self.imageCacheService = ImageCacheService()
        
    }
    
    @Published var image: UIImage?
    
    func loadImage(from url: String) {
        
        Task { [weak self] in
            
            guard let self = self else { return }
            
            do {
                
                let image = try await self._loadImage(from: url)
                
                await MainActor.run { [weak self] in
                    self?.image = image
                }
                
            }
            catch {
                print("ERROR: \(error.localizedDescription)")
            }
            
        }
        
    }
    
    private func _loadImage(from url: String) async throws -> UIImage? {
        
        if let validURL = URL(string: url) {
            
            if let image = self.imageCacheService.image(for: url) {
                
                print("FETCHED FROM CACHE: \(url)")
                return image
                
            }
            
            let imageData = try await apiService.getImage(url: validURL)
            
            self.imageCacheService.insertImage(imageData, for: url)
            print("SAVED TO CACHE: \(url)")
            
            let image = UIImage(data: imageData ?? Data())
            return image
            
        }
        
        return nil
        
    }
    
}
