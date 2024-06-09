//
//  AppImageView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 9/26/23.
//

import SwiftUI
import Kingfisher

struct AppImageView: View {
    
    private let remoteURL: URL?
    private let image: UIImage?
    
    @Binding var loadedRemoteURL: UIImage?
    
    init(remoteURL: URL?,
         image: UIImage?,
         loadedRemoteURL: Binding<UIImage?>? = nil) {
        
        self.remoteURL = remoteURL
        self.image = image
        
        if let loadedRemoteURL = loadedRemoteURL {
            self._loadedRemoteURL = loadedRemoteURL
        }
        else {
            self._loadedRemoteURL = .constant(nil)
        }
        
    }
    
    var body: some View {
        
        if let remoteURL {
            
            KFImage(remoteURL)
                .resizable()
                .onSuccess { image in
                    self.loadedRemoteURL = image.image
                }
            
        }
        else if let image {
            
            Image(uiImage: image)
                .resizable()
            
        }
        
    }
    
}

#Preview {
    
    AppImageView(remoteURL: nil, image: UIImage.checkmark)
        .frame(width: 350, height: 200)
        .clipShape(.rect(cornerRadius: 12))
    
}

#Preview {
    
    AppImageView(remoteURL: URL(string: "https://fastly.picsum.photos/id/391/200/300.jpg?hmac=3xP-y2PRN2E0__aPOCp1sja7XrimKgLQAMiSaNd0Cko"), image: nil)
        .frame(width: 300, height: 300)
        .clipShape(.circle)
    
}
