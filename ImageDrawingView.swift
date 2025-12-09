//
//  ImageDrawingView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/7/25.
//

import SwiftUI
import PDFKit
import PencilKit
import UniformTypeIdentifiers
import Combine

// MARK: - 1. The SwiftUI Entry Point
struct ImageDrawingView: View {
    
    let imageURL: URL
    let controller = PDFController()
    
    @State private var pdfDocument: PDFDocument?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let document = pdfDocument {
                PDFEditor(pdfDocument: document, controller: controller)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        // Enable drawing by default for the photo editor feel
                        controller.setDrawingEnabled(true)
                    }
            } else if isLoading {
                ProgressView("Loading Image...")
            } else {
                Text("Failed to load image")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            await loadImageAndConvert(url: imageURL)
        }
    }
    
    // Logic: Fetch Image -> Convert to 1-Page PDF
    private func loadImageAndConvert(url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let image = UIImage(data: data),
                  let pdf = PDFDocument.create(from: image) else {
                self.isLoading = false
                return
            }
            
            await MainActor.run {
                self.pdfDocument = pdf
                self.isLoading = false
            }
        } catch {
            print("Error loading image: \(error)")
            self.isLoading = false
        }
    }
}

// MARK: - 2. Image to PDF Helper
extension PDFDocument {
    static func create(from image: UIImage) -> PDFDocument? {
        let pdfDocument = PDFDocument()
        
        // Create a PDF Page exactly the size of the image
        guard let page = PDFPage(image: image) else { return nil }
        
        pdfDocument.insert(page, at: 0)
        return pdfDocument
    }
}

// MARK: - 3. Existing (But Slightly Modified) Controller & Logic

//extension PDFAnnotationKey {
//    static let pencilKitData = PDFAnnotationKey(rawValue: "raw_pk_drawing_data")
//}

//class PDFController {
//
//    var captureSnapshot: (() -> Data)?
//    var toggleDrawing: ((Bool) -> Void)?
//    var performUndo: (() -> Void)?
//    var performRedo: (() -> Void)?
//    
//    // Callback for frame changes
//    var onToolPickerFrameChange: ((CGRect) -> Void)?
//
//    func snapshot() -> Data {
//        return self.captureSnapshot?() ?? Data()
//    }
//
//    func setDrawingEnabled(_ isEnabled: Bool) {
//        self.toggleDrawing?(isEnabled)
//    }
//
//    func undo() {
//        self.performUndo?()
//    }
//
//    func redo() {
//        self.performRedo?()
//    }
//
//    func updateToolPickerFrame(_ frame: CGRect) {
//        self.onToolPickerFrameChange?(frame)
//    }
//}

//struct PDFEditor: UIViewRepresentable {
//
//    let document: PDFDocument
//    let controller: PDFController
//
//    func makeUIView(context: Context) -> DrawingPDFView {
//
//        let pdfView = DrawingPDFView()
//        pdfView.document = self.document
//
//        // Setup Controller Actions
//        self.controller.captureSnapshot = { [weak pdfView] in
//            // When saving a photo, we usually want a flattened image, not a PDF
//            // This grabs the rendered view as data
//            return pdfView?.generateFlattenedImage() ?? Data()
//        }
//
//        self.controller.toggleDrawing = { [weak pdfView] isEnabled in
//            DispatchQueue.main.async {
//                pdfView?.setDrawingMode(isEnabled: isEnabled)
//            }
//        }
//
//        self.controller.performUndo = { [weak pdfView] in
//            pdfView?.triggerUndo()
//        }
//
//        self.controller.performRedo = { [weak pdfView] in
//            pdfView?.triggerRedo()
//        }
//
//        // Connect the frame update
//        pdfView.onToolPickerFrameChanged = { [weak controller] frame in
//            controller?.updateToolPickerFrame(frame)
//        }
//
//        return pdfView
//    }
//
//    func updateUIView(_ uiView: DrawingPDFView, context: Context) {
//        if uiView.document != self.document {
//            uiView.document = self.document
//            uiView.activeCanvas?.zoomScale = 1.0
//            uiView.scaleFactor = uiView.scaleFactorForSizeToFit
//            uiView.minScaleFactor = uiView.scaleFactorForSizeToFit
//        }
//    }
//}

//@MainActor
//@preconcurrency
//class DrawingPDFView: PDFView,
//                      PKToolPickerObserver,
//                      PKCanvasViewDelegate {
//
//    let toolPicker = PKToolPicker()
//    
//    var onToolPickerFrameChanged: ((CGRect) -> Void)?
//    private var cancellables = Set<AnyCancellable>()
//
//    weak var activeCanvas: PKCanvasView?
//
//    lazy var overlayProvider: CanvasOverlayProvider = {
//        return CanvasOverlayProvider(toolPicker: self.toolPicker,
//                                     delegate: self)
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configureView()
//        setupFrameObservers()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func configureView() {
//        // Tweak: Use .singlePage to fit the image tightly like a photo viewer
//        self.displayMode = .singlePage 
//        self.autoScales = true
//        
//        // Visuals
//        self.backgroundColor = .systemBackground // Or .black for immersive feel
//        self.usePageViewController(false)
//        self.pageOverlayViewProvider = self.overlayProvider
//        
//        // Critical for allowing touch to pass to PencilKit
//        self.isInMarkupMode = true
//        self.isUserInteractionEnabled = true
//        
//        // Remove standard PDF shadows for a cleaner "Image" look
//        if let scrollView = self.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
//            scrollView.showsVerticalScrollIndicator = false
//            scrollView.showsHorizontalScrollIndicator = false
//        }
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        // Ensure the image fits initially
//        if self.scaleFactor < self.scaleFactorForSizeToFit {
//            self.minScaleFactor = self.scaleFactorForSizeToFit
//            self.scaleFactor = self.scaleFactorForSizeToFit
//        }
//    }
//    
//    // MARK: - Frame Observation Logic
//    private func setupFrameObservers() {
//        
//        if UIDevice.current.userInterfaceIdiom == .pad { return }
//
//        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
//            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification))
//            .sink { [weak self] notification in
//                self?.handleKeyboardChange(notification: notification)
//            }
//            .store(in: &cancellables)
//
//        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
//            .sink { [weak self] _ in
//                self?.onToolPickerFrameChanged?(.zero)
//            }
//            .store(in: &cancellables)
//    }
//    
//    private func handleKeyboardChange(notification: Notification) {
//        guard let userInfo = notification.userInfo,
//              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
//
//        let convertedFrame = self.convert(keyboardFrame, from: nil)
//        let intersection = convertedFrame.intersection(self.bounds)
//        
//        self.onToolPickerFrameChanged?(intersection)
//    }
//
//    override func didMoveToWindow() {
//        super.didMoveToWindow()
//
//        guard self.window != nil else {
//            self.toolPicker.setVisible(false, forFirstResponder: self)
//            self.toolPicker.removeObserver(self)
//            return
//        }
//
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            self.toolPicker.addObserver(self)
//            // Automatically start drawing mode if preferred
//             self.becomeFirstResponder()
//        }
//    }
//
//    override var canBecomeFirstResponder: Bool { return true }
//
//    func setDrawingMode(isEnabled: Bool) {
//        self.toolPicker.setVisible(isEnabled, forFirstResponder: self)
//
//        for canvas in self.overlayProvider.pageCanvasMap.values {
//            canvas.isUserInteractionEnabled = isEnabled
//        }
//
//        self.overlayProvider.isDrawingEnabled = isEnabled
//        
//        if isEnabled {
//            self.becomeFirstResponder()
//        } else {
//            self.resignFirstResponder()
//        }
//    }
//
//    func triggerUndo() {
//        self.activeCanvas?.undoManager?.undo()
//    }
//
//    func triggerRedo() {
//        self.activeCanvas?.undoManager?.redo()
//    }
//
//    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
//        self.activeCanvas = canvasView
//    }
//    
//    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {}
//
//    // MARK: - Snapshotting for Images
//    // This generates a flattened JPEG/PNG Data instead of a PDF
//    func generateFlattenedImage() -> Data {
//        
//        // Save drawings to PDF annotation first so they render
//        _ = self.saveDrawingsToPDF()
//        
//        guard let page = self.document?.page(at: 0) else { return Data() }
//        
//        let pageBounds = page.bounds(for: .mediaBox)
//        let renderer = UIGraphicsImageRenderer(size: pageBounds.size)
//        
//        let image = renderer.image { ctx in
//            // Draw white background (optional, if transparency is an issue)
//            UIColor.white.setFill()
//            ctx.fill(pageBounds)
//            
//            // Draw the PDF Page (which includes the base image + annotations)
//            ctx.cgContext.saveGState()
//            ctx.cgContext.translateBy(x: 0.0, y: pageBounds.size.height)
//            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
//            
//            page.draw(with: .mediaBox, to: ctx.cgContext)
//            
//            ctx.cgContext.restoreGState()
//        }
//        
//        return image.jpegData(compressionQuality: 0.8) ?? Data()
//    }
//
//    // Helper to burn PKDrawing into PDFAnnotations
//    func saveDrawingsToPDF() -> PDFDocument? {
//        guard let document = self.document else { return nil }
//        
//        for (page, canvas) in self.overlayProvider.pageCanvasMap {
//            let drawing = canvas.drawing
//            guard !drawing.bounds.isEmpty else { continue }
//            
//            // Remove old annotations to prevent duplicates on multiple saves
//            page.annotations.forEach {
//                if $0.value(forAnnotationKey: .pencilKitData) != nil {
//                    page.removeAnnotation($0)
//                }
//            }
//
//            let bounds = page.bounds(for: .mediaBox)
//            let newAnnotation = PencilKitAnnotation(bounds: bounds, forType: .stamp, withProperties: nil)
//            
//            newAnnotation.drawing = drawing
//            newAnnotation.pageBounds = bounds
//            
//            let data = drawing.dataRepresentation()
//            newAnnotation.setValue(data, forAnnotationKey: .pencilKitData)
//            
//            page.addAnnotation(newAnnotation)
//        }
//        
//        return document
//    }
//}
//
//// MARK: - 4. Overlay & Annotation Logic (Unchanged)
//
//@MainActor
//@preconcurrency
//class CanvasOverlayProvider: NSObject, @preconcurrency PDFPageOverlayViewProvider {
//
//    var pageCanvasMap: [PDFPage: PKCanvasView] = [:]
//    weak var toolPicker: PKToolPicker?
//    weak var delegate: PKCanvasViewDelegate?
//    var isDrawingEnabled: Bool = true
//
//    init(toolPicker: PKToolPicker, delegate: PKCanvasViewDelegate) {
//        self.toolPicker = toolPicker
//        self.delegate = delegate
//    }
//
//    func pdfView(_ view: PDFView, overlayViewFor page: PDFPage) -> UIView? {
//        if let existingCanvas = pageCanvasMap[page] {
//            return existingCanvas
//        }
//
//        let canvas = PKCanvasView(frame: .zero)
//        canvas.drawingPolicy = .anyInput
//        canvas.backgroundColor = .clear
//        canvas.isOpaque = false
//        canvas.isUserInteractionEnabled = self.isDrawingEnabled
//        canvas.delegate = self.delegate
//        
//        // Load existing drawings if we edited this before
//        for annotation in page.annotations {
//            if let data = annotation.value(forAnnotationKey: .pencilKitData) as? Data {
//                try? canvas.drawing = PKDrawing(data: data)
//                // We keep the annotation in the PDF, but load it into the canvas
//                // Optional: remove annotation to prevent double rendering while editing
//                 page.removeAnnotation(annotation)
//            }
//        }
//
//        self.toolPicker?.addObserver(canvas)
//        self.pageCanvasMap[page] = canvas
//        return canvas
//    }
//
//    func pdfView(_ pdfView: PDFView, willEndDisplayingOverlayView overlayView: UIView, for page: PDFPage) {}
//}
//
//class PencilKitAnnotation: PDFAnnotation {
//
//    var drawing: PKDrawing?
//    var pageBounds: CGRect = .zero
//
//    override func draw(with box: PDFDisplayBox, in context: CGContext) {
//        guard let drawing = self.drawing else { return }
//        
//        let image = drawing.image(from: self.pageBounds, scale: 1.0)
//        guard let cgImage = image.cgImage else { return }
//
//        context.saveGState()
//        
//        // Flip context for PDF coordinate system
//        let flipRect = CGRect(
//            x: bounds.origin.x,
//            y: bounds.origin.y + bounds.height,
//            width: bounds.width,
//            height: -bounds.height
//        )
//
//        context.draw(cgImage, in: flipRect)
//        context.restoreGState()
//    }
//}
