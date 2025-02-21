//
//  CommonImageView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/20/25.
//

import UIKit
import SwiftUI
import Kingfisher

enum AppImage {
    
    case image(Image)
    
    case remote(url: URL,
                placeholder: AnyView? = nil,
                onSuccess: ((RetrieveImageResult) -> Void)? = nil,
                onFailure: ((Error) -> Void)? = nil)
    
    @ViewBuilder
    func view() -> some View {
        
        switch self {
            
        case .image(let image):
            
            image
                .resizable()
            
        case .remote(let url, let placeholder, let onSuccess, let onFailure):
            
            KFImage(url)
                .resizable()
                .placeholder {
                    placeholder
                }
                .onSuccess { result in
                    onSuccess?(result)
                }
                .onFailure { error in
                    onFailure?(error)
                }
            
        }
        
    }
    
}

struct CommonImageView: View {
    
    let style: AppImage
    
    var body: some View {
        style.view()
    }
    
}

#Preview("Circle System Image") {
    
    CommonImageView(style: .image(Image(systemName: "person.circle")))
        .aspectRatio(contentMode: .fit)
        .frame(height: 200)
        .foregroundStyle(.indigo)
        .padding(Spacing.xLarge.value)
        .background(.indigo.opacity(0.2))
        .clipShape(.circle)
    
}

#Preview("Card Image") {
    
    CommonImageView(style: .image(Image(.image3)))
        .aspectRatio(contentMode: .fill)
        .frame(height: 200)
        .clipShape(.rect(cornerRadius: .appLarge))
        .padding(.horizontal, .large)
    
}

#Preview("Remote URL") {
    
    let url = URL(string: "https://fastly.picsum.photos/id/391/200/300.jpg?hmac=3xP-y2PRN2E0__aPOCp1sja7XrimKgLQAMiSaNd0Cko")!
    let placeholder = Image(systemName: "photo.on.rectangle.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 150, height: 150)
    
    CommonImageView(style: .remote(
        url: url,
        placeholder: placeholder.asAnyView()
    ))
    .frame(width: 300, height: 300)
    .clipShape(.circle)
    
}

#Preview("Remote Success") {
    
    @Previewable @State var didLoadSuccessfully: Bool = false
    
    let url = URL(string: "https://fastly.picsum.photos/id/391/200/300.jpg?hmac=3xP-y2PRN2E0__aPOCp1sja7XrimKgLQAMiSaNd0Cko")!
    
    VStack(spacing: .appLarge) {
        
        if didLoadSuccessfully {
            
            AppCardView {
                
                Text("Did Load Correctly!")
                    .appFont(with: .header(.h5))
                
            }
            .transition(.slide)
            .padding(.horizontal, .xLarge)
            
        }
        
        CommonImageView(style: .remote(
            url: url,
            onSuccess: { _ in
                
                withAnimation(.spring.delay(1)) {
                    didLoadSuccessfully = true
                }
                
            }
        ))
        .frame(width: 300, height: 300)
        .clipShape(.circle)
        
    }
    
}

#Preview("Remote Failure") {
    
    @Previewable @State var error: Error? = nil
    
    let url = URL(string: "hasdasdas")!
    
    VStack {
        
        if let error {
            
            AppCardView {
                
                Text(error.localizedDescription)
                    .transition(.slide)
                    .appFont(with: .header(.h5))
                
            }
            .padding(.horizontal, .xLarge)
            .transition(.slide)
            
        }
        
        CommonImageView(style: .remote(
            url: url,
            onFailure: { remoteError in
                
                withAnimation(.spring.delay(1)) {
                    error = remoteError
                }
                
            }
        ))
        .frame(width: 300, height: 300)
        .clipShape(.circle)
        
    }
    
}
