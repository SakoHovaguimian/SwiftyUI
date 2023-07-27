//
//  PhotoPickerView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/27/23.
//

import PhotosUI
import SwiftUI

// TODO: - Turn this into a service view
    /// By making this take in bindings of avatarImage this will update the parent when a view is selected...
    /// Also should support an array of items: .any(of: [.images, .videos]) default: .any(of: [.images])

struct PhotoPickerView: View {
    
    @State private var avatarItem: PhotosPickerItem?
    @Binding var avatarImage: Image?

    var body: some View {
        
        VStack(spacing: 0) {
            
            PhotosPicker(selection: $avatarItem, matching: .images) {
                Label("Select a photo", systemImage: "photo")
            }
            .tint(.indigo)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)

            if let avatarImage {
                avatarImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)

            }
            
        }
        .onChange(of: self.avatarItem) { _, _ in
            
            Task {
                
                if let data = try? await self.avatarItem?.loadTransferable(type: Data.self) {
                    
                    if let uiImage = UIImage(data: data) {
                        
                        self.avatarImage = Image(uiImage: uiImage)
                        return
                        
                    }
                    
                }

                print("Failed")
                
            }
            
        }
        
    }
    
}

#Preview {
    PhotoPickerView(avatarImage: .constant(nil))
}
