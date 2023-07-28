//
//  PhotoPickerView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/27/23.
//

import PhotosUI
import SwiftUI

struct PhotoPickerView<Content: View>: View {
    
    enum PhotoPickerError: Error {
        case decodeError
    }
    
    @State private var avatarItem: PhotosPickerItem?
    @Binding private var avatarImage: Image?
    
    private var mediaType: PHPickerFilter = .images
    private var onError: ((Error) -> ())
    
    
    let content: Content
    
    init(avatarImage: Binding<Image?>,
         mediaType: PHPickerFilter = .images,
         @ViewBuilder content: () -> Content,
         onError: @escaping ((Error) -> ())) {
        

        self._avatarImage = avatarImage
        self.mediaType = mediaType
        self.content = content()
        self.onError = onError
        
    }

    var body: some View {
        
        PhotosPicker(
            selection: $avatarItem,
            matching: self.mediaType) {
                
            self.content
                
        }
        .onChange(of: self.avatarItem) { _, _ in
            
            Task {
                
                if let data = try? await self.avatarItem?.loadTransferable(type: Data.self) {
                    
                    if let uiImage = UIImage(data: data) {
                        
                        self.avatarImage = Image(uiImage: uiImage)
                        return
                        
                    }
                    
                }

                onError(PhotoPickerError.decodeError)
                
            }
            
        }
        
    }
    
}

struct PhotoPickerTestView: View {
    
    @State private var selectedImage: Image?
    
    var body: some View {
        
        PhotoPickerView(avatarImage: self.$selectedImage,
                        content: {
            
            VStack(spacing: 8) {
                
                VStack {
                    Image(systemName: "heart.fill")
                }
                .padding(10)
                .background(in: Circle())
                .backgroundStyle(.green.gradient)
                .foregroundStyle(.white)
                
                Label("Select a photo", systemImage: "photo")
                    .frame(width: 250, height: 50)
                    .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                
                if let image = self.selectedImage {
                    
                    let _ = print("Image is selected")
                    
                    image
                        .resizable()
                        .frame(width: 300, height: 200)
                    
                }
                
            }

            
        }, onError: { error in
            print(error.localizedDescription)
        })
        
    }
    
}

#Preview {
    PhotoPickerTestView()
}
