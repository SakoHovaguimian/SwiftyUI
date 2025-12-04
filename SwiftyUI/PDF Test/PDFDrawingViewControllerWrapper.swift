//
//  PDFDrawingViewControllerWrapper.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/2/25.
//


import SwiftUI
import PDFKit
import PencilKit

// MARK: - SwiftUI Wrapper

struct PDFDrawingViewControllerWrapper: UIViewControllerRepresentable {

    // If you later want to pass config (file name, urls, etc),
    // add stored properties here and push them into the VC in makeUIViewController.

    func makeUIViewController(context: Context) -> ViewController {
        let controller = ViewController()
        // Example if you add config properties on ViewController later:
        // controller.initialPDFURL = initialPDFURL
        // controller.outputFileName = outputFileName
        return controller
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // No-op for now.
        // If you add @Binding vars (isDrawing, etc.), push changes here.
    }
}

// MARK: - Example SwiftUI Usage

struct PDFDrawingContainerView: View {

    var body: some View {
        PDFDrawingViewControllerWrapper()
            .ignoresSafeArea()   // full-screen PDF editor
    }
}

#Preview {
    PDFDrawingContainerView()
}
