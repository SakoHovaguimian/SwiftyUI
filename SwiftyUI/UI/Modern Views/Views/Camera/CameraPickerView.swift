//
//  CameraView.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/24/24.
//

import SwiftUI

struct CameraPickerView: UIViewControllerRepresentable {
    
    private let sourceType: UIImagePickerController.SourceType
    private let didSelectImage: (UIImage) -> Void
    private let onDismiss: (() -> (Void))?
    
    @Environment(\.presentationMode) private var presentationMode
    
    public init(sourceType: UIImagePickerController.SourceType = .camera,
                onImagePicked: @escaping (UIImage) -> Void,
                onDismiss: (() -> (Void))? = nil) {
        
        self.sourceType = sourceType
        self.didSelectImage = onImagePicked
        self.onDismiss = onDismiss
        
    }
    
    internal func makeUIViewController(context: Context) -> UIImagePickerController {
        
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.delegate = context.coordinator
        return picker
        
    }
    
    internal func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    internal func makeCoordinator() -> Coordinator {
        
        Coordinator(
            didSelectImage: self.didSelectImage,
            onDismiss: {
                
                self.onDismiss?()
                self.presentationMode.wrappedValue.dismiss()
                
            }
        )
        
    }
    
    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        private let didSelectImage: (UIImage) -> Void
        private let onDismiss: () -> Void
        
        init(didSelectImage: @escaping (UIImage) -> Void,
             onDismiss: @escaping () -> Void) {
            
            self.onDismiss = onDismiss
            self.didSelectImage = didSelectImage
            
        }
        
        internal func imagePickerController(_ picker: UIImagePickerController,
                                            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            
            if let image = info[.originalImage] as? UIImage {
                self.didSelectImage(image)
            }
            self.onDismiss()
            
        }
        
        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }
        
    }
    
}

// TESTS

internal struct CameraViewTestView: View {
    
    @State private var selectedImage: UIImage?
    @State private var shouldShowCameraView: Bool = false
    
    var body: some View {
        
        ZStack {
            
            Color.blue.opacity(0.4)
                .ignoresSafeArea()
            
            if let selectedImage {
                
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: 300,
                        height: 400
                    )
                    .clipShape(.rect(cornerRadius: 13))
                    .transition(.scale.combined(with: .opacity))
                
            }
            
        }
        .safeAreaInset(edge: .bottom) {
            
            AppButton(title: "Camera") {
                self.shouldShowCameraView = true
            }
            .padding(.horizontal, 64)
            
        }
        .fullScreenCover(isPresented: self.$shouldShowCameraView) {
            
            CameraPickerView { selectedImage in
                withAnimation {
                    self.selectedImage = selectedImage
                }
            } onDismiss: {
                print("DISMISSED")
            }
            .ignoresSafeArea()
            
        }
        
    }
    
}

#Preview {
    CameraViewTestView()
}
