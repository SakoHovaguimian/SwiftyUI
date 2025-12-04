import SwiftUI
import PDFKit
import PencilKit

// MARK: - 1. Definitions & Keys

extension PDFAnnotationKey {
    static let pencilKitData = PDFAnnotationKey(rawValue: "raw_pk_drawing_data")
}

enum EditorTool: String, CaseIterable {
    case move = "hand.point.up.left.fill"
    case pen = "pencil"
    case eraser = "eraser"
    case text = "textformat"
    case arrow = "arrow.up.right"
    case rect = "rectangle"
    case circle = "circle"
}

// MARK: - 2. Controller

class PDFController {
    var captureSnapshot: (() -> PDFDocument)?
    var changeTool: ((EditorTool) -> Void)?
    var performUndo: (() -> Void)?
    var performRedo: (() -> Void)?
    
    var currentTool: EditorTool = .move
    
    func snapshot() -> PDFDocument {
        return self.captureSnapshot?() ?? PDFDocument()
    }
    
    func selectTool(_ tool: EditorTool) {
        self.currentTool = tool
        self.changeTool?(tool)
    }
    
    func undo() { self.performUndo?() }
    func redo() { self.performRedo?() }
}

// MARK: - 3. SwiftUI Wrapper

struct PDFEditor: UIViewRepresentable {
    
    let url: URL
    let controller: PDFController
    
    func makeUIView(context: Context) -> DrawingPDFView {
        let pdfView = DrawingPDFView()
        pdfView.load(url: self.url)
        
        // Hooks
        self.controller.captureSnapshot = { [weak pdfView] in
            return pdfView?.generateSnapshot() ?? PDFDocument()
        }
        
        self.controller.changeTool = { [weak pdfView] tool in
            pdfView?.setTool(tool)
        }
        
        self.controller.performUndo = { [weak pdfView] in pdfView?.triggerUndo() }
        self.controller.performRedo = { [weak pdfView] in pdfView?.triggerRedo() }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: DrawingPDFView, context: Context) {
        if uiView.document?.documentURL != self.url {
            uiView.load(url: self.url)
        }
    }
}

// MARK: - 4. Custom PDF View (The Engine)

class DrawingPDFView: PDFView, PKToolPickerObserver, PKCanvasViewDelegate {
    
    let toolPicker = PKToolPicker()
    weak var activeCanvas: PKCanvasView?
    var currentTool: EditorTool = .move
    
    // Shape Preview
    private var shapeLayer: CAShapeLayer?
    private var startPoint: CGPoint?
    
    lazy var overlayProvider: CanvasOverlayProvider = {
        return CanvasOverlayProvider(toolPicker: self.toolPicker, delegate: self)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        setupGestures()
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
    
    private func setupGestures() {
        // Dragging for Shapes
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self // Critical for blocking scroll
        panGesture.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panGesture)
        
        // Tapping for Text
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        // We do NOT set delegate here because we want standard taps to work unless we are in text mode
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Tool Switching
    
    func setTool(_ tool: EditorTool) {
        self.currentTool = tool
        
        let isPencilMode = (tool == .pen || tool == .eraser)
        
        // 1. Configure PencilKit
        self.toolPicker.setVisible(isPencilMode, forFirstResponder: self)
        self.overlayProvider.isDrawingEnabled = isPencilMode
        
        // 2. Refresh Canvases (Hit Testing)
        for canvas in self.overlayProvider.pageCanvasMap.values {
            canvas.isUserInteractionEnabled = isPencilMode
        }
        
        // 3. Configure Scrolling Logic
        // If we are drawing shapes, we don't want the PDF to scroll
        // The PanGesture delegate handles this dynamically, but we can also set properties here if needed.
        if let scrollView = self.subviews.first as? UIScrollView {
            scrollView.isScrollEnabled = (tool == .move || isPencilMode || tool == .text)
        }
    }
    
    // MARK: - Gesture Logic (Shapes)
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard [.arrow, .rect, .circle].contains(currentTool) else { return }
        
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            self.startPoint = location
            
            // Create Preview Layer
            let layer = CAShapeLayer()
            layer.strokeColor = UIColor.systemBlue.cgColor
            layer.lineWidth = 3
            layer.fillColor = UIColor.clear.cgColor
            layer.lineDashPattern = [4, 4] // Dashed line for preview
            layer.zPosition = 999 // Ensure it's on top
            self.layer.addSublayer(layer)
            self.shapeLayer = layer
            
        case .changed:
            guard let start = self.startPoint, let layer = self.shapeLayer else { return }
            let path = UIBezierPath()
            
            if currentTool == .arrow {
                path.move(to: start)
                path.addLine(to: location)
            } else {
                let rect = CGRect(x: min(start.x, location.x),
                                  y: min(start.y, location.y),
                                  width: abs(location.x - start.x),
                                  height: abs(location.y - start.y))
                
                if currentTool == .circle {
                    path.append(UIBezierPath(ovalIn: rect))
                } else {
                    path.append(UIBezierPath(rect: rect))
                }
            }
            layer.path = path.cgPath
            
        case .ended:
            guard let start = self.startPoint else { return }
            addShapeAnnotation(start: start, end: location)
            
            // Cleanup
            self.shapeLayer?.removeFromSuperlayer()
            self.shapeLayer = nil
            self.startPoint = nil
            
        default:
            // Cancelled/Failed
            self.shapeLayer?.removeFromSuperlayer()
            self.shapeLayer = nil
        }
    }
    
    // UIGestureRecognizerDelegate: This stops the ScrollView from stealing our shape touches
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer, pan.view == self {
            return [.arrow, .rect, .circle].contains(currentTool)
        }
        return true
    }
    
    private func addShapeAnnotation(start: CGPoint, end: CGPoint) {
        // We must find which page we are drawing on
        guard let page = self.page(for: start, nearest: true) else { return }
        
        // Convert View Points -> Page Points
        let startPage = self.convert(start, to: page)
        let endPage = self.convert(end, to: page)
        
        // Calculate Bounds
        let bounds = CGRect(x: min(startPage.x, endPage.x),
                            y: min(startPage.y, endPage.y),
                            width: abs(endPage.x - startPage.x),
                            height: abs(endPage.y - startPage.y))
        
        var annotation: PDFAnnotation?
        
        switch currentTool {
        case .rect:
            annotation = PDFAnnotation(bounds: bounds, forType: .square, withProperties: nil)
        case .circle:
            annotation = PDFAnnotation(bounds: bounds, forType: .circle, withProperties: nil)
        case .arrow:
            // Arrows are 'Line' annotations with specific styles
            // Note: Line annotations bounds usually cover the whole page or large area, but start/end points define the drawing
            annotation = PDFAnnotation(bounds: page.bounds(for: .mediaBox), forType: .line, withProperties: nil)
            annotation?.startPoint = startPage
            annotation?.endPoint = endPage
            annotation?.endLineStyle = .openArrow
        default: break
        }
        
        if let ann = annotation {
            ann.color = .systemBlue
            ann.border = PDFBorder()
            ann.border?.lineWidth = 3.0
            page.addAnnotation(ann)
        }
    }
    
    // MARK: - Text Logic (Tap)
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        // 1. Check if we hit an EXISTING annotation first (Edit Mode)
        let location = gesture.location(in: self)
        
        if let page = self.page(for: location, nearest: true) {
            let pagePoint = self.convert(location, to: page)
            
            // Hit Test for Annotations
            if let hitAnnotation = page.annotation(at: pagePoint), hitAnnotation.type == "FreeText" {
                // Edit Existing
                presentTextInput(for: hitAnnotation, on: page)
                return
            }
        }
        
        // 2. If no hit, and tool is Text, create NEW (Creation Mode)
        guard currentTool == .text else { return }
        
        guard let page = self.page(for: location, nearest: true) else { return }
        let pagePoint = self.convert(location, to: page)
        
        let newAnnotation = PDFAnnotation(bounds: CGRect(x: pagePoint.x, y: pagePoint.y, width: 200, height: 40), forType: .freeText, withProperties: nil)
        newAnnotation.color = .clear
        newAnnotation.font = UIFont.systemFont(ofSize: 18)
        newAnnotation.fontColor = .black
        newAnnotation.contents = "Tap to edit"
        
        page.addAnnotation(newAnnotation)
        
        // Immediately allow editing
        presentTextInput(for: newAnnotation, on: page)
    }
    
    private func presentTextInput(for annotation: PDFAnnotation, on page: PDFPage) {
        let alert = UIAlertController(title: "Edit Text", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = annotation.contents
        }
        
        let saveAction = UIAlertAction(title: "Done", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                annotation.contents = text
                // Force redraw
                page.removeAnnotation(annotation)
                page.addAnnotation(annotation)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            page.removeAnnotation(annotation)
        }
        
        alert.addAction(saveAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        // Find top controller to present
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Standard Methods
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard self.window != nil else { return }
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
        guard let document = PDFDocument(url: url) else { return }
        self.document = document
    }
    
    func triggerUndo() { self.activeCanvas?.undoManager?.undo() }
    func triggerRedo() { self.activeCanvas?.undoManager?.redo() }
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) { self.activeCanvas = canvasView }
    
    func generateSnapshot() -> PDFDocument {
        guard let originalData = self.document?.dataRepresentation(),
              let workingCopy = PDFDocument(data: originalData) else { return PDFDocument() }
        
        for (page, canvas) in self.overlayProvider.pageCanvasMap {
            let drawing = canvas.drawing
            guard !drawing.bounds.isEmpty else { continue }
            
            let pageIndex = self.document?.index(for: page) ?? 0
            guard let pageCopy = workingCopy.page(at: pageIndex) else { continue }
            let bounds = pageCopy.bounds(for: .mediaBox)
            
            let newAnnotation = PencilKitAnnotation(bounds: bounds, forType: .stamp, withProperties: nil)
            newAnnotation.drawing = drawing
            newAnnotation.pageBounds = bounds
            
            let data = drawing.dataRepresentation()
            newAnnotation.setValue(data, forAnnotationKey: .pencilKitData)
            
            pageCopy.addAnnotation(newAnnotation)
        }
        return workingCopy
    }
}

// MARK: - 5. Overlay Provider

class CanvasOverlayProvider: NSObject, PDFPageOverlayViewProvider {
    var pageCanvasMap: [PDFPage: PKCanvasView] = [:]
    weak var toolPicker: PKToolPicker?
    weak var delegate: PKCanvasViewDelegate?
    var isDrawingEnabled: Bool = true
    
    init(toolPicker: PKToolPicker, delegate: PKCanvasViewDelegate) {
        self.toolPicker = toolPicker
        self.delegate = delegate
    }
    
    func pdfView(_ view: PDFView, overlayViewFor page: PDFPage) -> UIView? {
        if let existingCanvas = pageCanvasMap[page] { return existingCanvas }
        
        let canvas = PKCanvasView(frame: .zero)
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.isUserInteractionEnabled = self.isDrawingEnabled
        canvas.delegate = self.delegate
        
        for annotation in page.annotations {
            if let data = annotation.value(forAnnotationKey: .pencilKitData) as? Data {
                try? canvas.drawing = PKDrawing(data: data)
                page.removeAnnotation(annotation)
            }
        }
        
        self.toolPicker?.addObserver(canvas)
        self.pageCanvasMap[page] = canvas
        return canvas
    }
    
    func pdfView(_ pdfView: PDFView, willEndDisplayingOverlayView overlayView: UIView, for page: PDFPage) {}
}

// MARK: - 6. Annotation

class PencilKitAnnotation: PDFAnnotation {
    var drawing: PKDrawing?
    var pageBounds: CGRect = .zero
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        guard let drawing = self.drawing else { return }
        let image = drawing.image(from: self.pageBounds, scale: 1.0)
        UIGraphicsPushContext(context)
        image.draw(in: self.bounds)
        UIGraphicsPopContext()
    }
}

// MARK: - 7. Container

struct CleanPDFContainer: View {
    let controller = PDFController()
    @State var url = Bundle.main.url(forResource: "Sample", withExtension: "pdf")!
    @State var currentTool: EditorTool = .move
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(EditorTool.allCases, id: \.self) { tool in
                            Button(action: {
                                self.currentTool = tool
                                self.controller.selectTool(tool)
                            }) {
                                Image(systemName: tool.rawValue)
                                    .font(.title2)
                                    .foregroundColor(currentTool == tool ? .white : .blue)
                                    .padding(10)
                                    .background(currentTool == tool ? Color.blue : Color.blue.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding()
                }
                
                PDFEditor(url: url, controller: controller)
                    .edgesIgnoringSafeArea(.bottom)
            }
            .navigationTitle("Editor")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveAndReload() }
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
            try? data.write(to: newURL)
            self.url = newURL
        }
    }
}
