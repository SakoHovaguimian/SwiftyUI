import SwiftUI
import PDFKit
import PencilKit

// MARK: - 1. The Controller
class PDFController {
    
    var captureSnapshot: (() -> PDFDocument)?
    var toggleDrawing: ((Bool) -> Void)?
    var performUndo: (() -> Void)?
    var performRedo: (() -> Void)?
    
    func snapshot() -> PDFDocument {
        return self.captureSnapshot?() ?? PDFDocument()
    }
    
    func setDrawingEnabled(_ isEnabled: Bool) {
        self.toggleDrawing?(isEnabled)
    }
    
    func undo() {
        self.performUndo?()
    }
    
    func redo() {
        self.performRedo?()
    }
    
}

// MARK: - 2. SwiftUI Wrapper
struct PDFEditor: UIViewRepresentable {
    
    let pdfDocument: PDFDocument
    let controller: PDFController
    
    func makeUIView(context: Context) -> DrawingPDFView {
        
        let pdfView = DrawingPDFView()
        pdfView.load(url: .init(string: "https://www.google.com")!)
                
        self.controller.captureSnapshot = { [weak pdfView] in
            return pdfView?.generateSnapshot() ?? PDFDocument()
        }
        
        self.controller.toggleDrawing = { [weak pdfView] isEnabled in
            pdfView?.setDrawingMode(isEnabled: isEnabled)
        }
        
        self.controller.performUndo = { [weak pdfView] in
            pdfView?.triggerUndo()
        }
        
        self.controller.performRedo = { [weak pdfView] in
            pdfView?.triggerRedo()
        }
        
        return pdfView
        
    }
    
    func updateUIView(_ uiView: DrawingPDFView,
                      context: Context) {
        
        // If the URL changed, load the new one
//        if uiView.document?.documentURL != self.url {
            
            uiView.load(url: .init(string: "https://www.google.com")!)
            uiView.activeCanvas?.zoomScale = 1.0
            
//        }
        
    }
    
}

// MARK: - 3. The Custom PDF View
class DrawingPDFView: PDFView,
                      PKToolPickerObserver,
                      PKCanvasViewDelegate {
    
    let toolPicker = PKToolPicker()
    
    // We track the last touched canvas to know where to Undo/Redo
    weak var activeCanvas: PKCanvasView?
    
    lazy var overlayProvider: CanvasOverlayProvider = {
        return CanvasOverlayProvider(toolPicker: self.toolPicker,
                                     delegate: self)
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        configureView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        
        self.autoScales = true
        self.displayMode = .singlePageContinuous
        self.displaysPageBreaks = true
        self.usePageViewController(false)
        self.pageOverlayViewProvider = self.overlayProvider
        self.isInMarkupMode = true
        self.isUserInteractionEnabled = true
        
    }
    
    override func didMoveToWindow() {
        
        super.didMoveToWindow()
        
        guard self.window != nil else {
            
            self.toolPicker.setVisible(false, forFirstResponder: self)
            self.toolPicker.removeObserver(self)
            
            return
            
        }
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            self.toolPicker.setVisible(true, forFirstResponder: self)
            self.toolPicker.addObserver(self)
            self.becomeFirstResponder()
            
        }
        
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    func load(url: URL) {
        
        self.overlayProvider.pageCanvasMap.removeAll()
        self.activeCanvas = nil
        
        guard let document = self.document else { return }
        self.document = document
        
    }
    
    // MARK: - Logic for Toggle / Undo / Redo
    
    func setDrawingMode(isEnabled: Bool) {
        
        // 1. Show or Hide the ToolPicker
        self.toolPicker.setVisible(isEnabled, forFirstResponder: self)
        
        // 2. Enable/Disable interaction on all existing canvases
        // If disabled, touches fall through to the PDFView for scrolling
        for canvas in self.overlayProvider.pageCanvasMap.values {
            canvas.isUserInteractionEnabled = isEnabled
        }
        
        // 3. Update the provider's state for future pages
        self.overlayProvider.isDrawingEnabled = isEnabled
        
    }
    
    func triggerUndo() {
        self.activeCanvas?.undoManager?.undo()
    }
    
    func triggerRedo() {
        self.activeCanvas?.undoManager?.redo()
    }
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        self.activeCanvas = canvasView
    }
    
    // MARK: - Snapshot
    
    func generateSnapshot() -> PDFDocument {
        
        guard let originalData = self.document?.dataRepresentation(),
              let workingCopy = PDFDocument(data: originalData) else {
            
            return PDFDocument()
            
        }
        
        for (page, canvas) in self.overlayProvider.pageCanvasMap {
            
            let drawing = canvas.drawing
            guard !drawing.bounds.isEmpty else { continue }
            
            let pageIndex = self.document?.index(for: page) ?? 0
            guard let pageCopy = workingCopy.page(at: pageIndex) else { continue }
            
            let bounds = pageCopy.bounds(for: .mediaBox)
            
            let newAnnotation = PencilKitAnnotation(
                bounds: bounds,
                forType: .stamp,
                withProperties: nil
            )
            
            newAnnotation.drawing = drawing
            newAnnotation.pageBounds = bounds
            
            pageCopy.addAnnotation(newAnnotation)
            
        }
        
        return workingCopy
        
    }
    
}

// MARK: - 4. Overlay Provider
class CanvasOverlayProvider: NSObject,
                             PDFPageOverlayViewProvider {
    
    var pageCanvasMap: [PDFPage: PKCanvasView] = [:]
    
    weak var toolPicker: PKToolPicker?
    weak var delegate: PKCanvasViewDelegate?
    
    // State to ensure new pages respect the toggle setting
    var isDrawingEnabled: Bool = true
    
    init(toolPicker: PKToolPicker,
         delegate: PKCanvasViewDelegate) {
        
        self.toolPicker = toolPicker
        self.delegate = delegate
        
    }
    
    func pdfView(_ view: PDFView,
                 overlayViewFor page: PDFPage) -> UIView? {
        
        if let existingCanvas = pageCanvasMap[page] {
            return existingCanvas
        }
        
        let canvas = PKCanvasView(frame: .zero)
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        
        // Important: Respect the current toggle state
        canvas.isUserInteractionEnabled = self.isDrawingEnabled
        
        canvas.delegate = self.delegate
        self.toolPicker?.addObserver(canvas)
        self.pageCanvasMap[page] = canvas
        
        return canvas
        
    }
    
    func pdfView(_ pdfView: PDFView,
                 willEndDisplayingOverlayView overlayView: UIView,
                 for page: PDFPage) {
        
    }
    
}

// MARK: - 5. Annotation
class PencilKitAnnotation: PDFAnnotation {
    
    var drawing: PKDrawing?
    var pageBounds: CGRect = .zero
    
    override func draw(with box: PDFDisplayBox,
                       in context: CGContext) {
        
        guard let drawing = self.drawing else { return }
        
        let image = drawing.image(from: self.pageBounds, scale: 1.0)
        guard let cgImage = image.cgImage else { return }
        
        context.saveGState()
        
        let flipRect = CGRect(
            x: bounds.origin.x,
            y: bounds.origin.y + bounds.height,
            width: bounds.width,
            height: -bounds.height
        )
        
        context.draw(cgImage, in: flipRect)
        context.restoreGState()
        
    }
    
}

// MARK: - 6. Usage View
struct CleanPDFContainer: View {
    
    let controller = PDFController()
    
    // Start with the sample from the Bundle
    @State var url = Bundle.main.url(forResource: "Sample", withExtension: "pdf")!
    
    // Local state to manage the toggle UI
    @State var isDrawing: Bool = true
    
    var body: some View {
        
        NavigationView {
            
            PDFEditor(pdfDocument: PDFDocument(url: url)!, controller: controller)
                .edgesIgnoringSafeArea(.bottom)
                .navigationTitle("Editor")
                .toolbar {
                    
                    // Left Side: Mode Toggle
                    ToolbarItem(placement: .navigationBarLeading) {
                        
                        Button(action: {
                            self.isDrawing.toggle()
                            self.controller.setDrawingEnabled(self.isDrawing)
                        }) {
                            Image(systemName: self.isDrawing ? "hand.draw.fill" : "scroll")
                        }
                        
                    }
                    
                    // Center/Right: Undo/Redo & Save
                    ToolbarItem(placement: .navigationBarTrailing) {
                        
                        HStack {
                            
                            Button(action: { self.controller.undo() }) {
                                Image(systemName: "arrow.uturn.backward")
                            }
                            
                            Button(action: { self.controller.redo() }) {
                                Image(systemName: "arrow.uturn.forward")
                            }
                            
                            Button("Save") {
                                saveAndReload()
                            }
                            
                        }
                        
                    }
                    
                }
            
        }
        
    }
    
    func saveAndReload() {
        
        let newDoc = self.controller.snapshot()
        
        let fileName = "SavedPDF_\(Int(Date().timeIntervalSince1970)).pdf"
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let newURL = docsURL.appendingPathComponent(fileName)
        
        if let data = newDoc.dataRepresentation() {
            
            do {
                
                try data.write(to: newURL)
                print("Saved to: \(newURL.path)")
                
                self.url = newURL
                
            } catch {
                print("Error saving file: \(error)")
            }
            
        }
        
    }
    
}
