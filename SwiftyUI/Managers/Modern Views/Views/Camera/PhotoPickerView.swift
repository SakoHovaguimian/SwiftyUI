//
//  PhotoPickerView.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/24/24.
//

import PhotosUI
import SwiftUI

struct PhotoPickerView<Content: View>: View {
    
    enum PhotoPickerError: Error {
        case decodeError
    }
    
    @State private var avatarItem: PhotosPickerItem?
    @Binding private var avatarImage: UIImage?
    
    private var mediaType: PHPickerFilter = .images
    private var onError: ((Error) -> ())
    
    let content: Content
    
    init(avatarImage: Binding<UIImage?>,
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
            selection: self.$avatarItem,
            matching: self.mediaType) {
                
            self.content
                
            }
            .onChange(of: self.avatarImage, { oldValue, newValue in
                
                if newValue == nil {
                    self.avatarItem = nil
                }
                
            })
            .onChange(of: self.avatarItem) { _, _ in
                
                guard self.avatarItem != nil else { return }
                
                Task {
                    
                    if let data = try? await self.avatarItem?.loadTransferable(type: Data.self) {
                        
                        if let uiImage = UIImage(data: data) {
                            
                            self.avatarImage = uiImage
                            return
                            
                        }
                        
                    }
                    
                    onError(PhotoPickerError.decodeError)
                    
                }
                
            }
        
    }
    
}


#Preview {
    
    PhotoPickerView(
        avatarImage: .constant(nil),
        mediaType: .images
    ) {
        Text("Button")
    } onError: { error in
        print(error)
    }
    
}
