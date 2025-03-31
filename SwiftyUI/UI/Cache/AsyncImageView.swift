//
//  AsyncImageView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/28/25.
//


import SwiftUI

struct AsyncImageView: View {
    
    @StateObject var viewModel = AsyncImageViewModel()
    
    let url: String
    
    var body: some View {
        
        Group {
            
            if let image = viewModel.image {
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                
            }
            else {
                
                placeholderImage()
                
            }
            
        }
        .task(id: url) {
            self.viewModel.loadImage(from: url)
        }
        
    }
    
    private func placeholderImage() -> some View {
        
        Rectangle()
            .fill(Color(uiColor: .systemGray6))
            .overlay {
                
                Image(systemName: "photo.on.rectangle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .foregroundStyle(.black)
                
            }

    }
    
}