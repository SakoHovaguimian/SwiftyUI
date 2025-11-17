//
//  PDFDraw.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 11/11/25.
//

import SwiftUI
import PDFKit

@Observable
private class PDFManager {
    var drawingPoints: [DrawingPoint] = []
    
    var pageBounds: CGRect {
        if let page = pdfView.currentPage {
            return page.bounds(for: pdfView.displayBox)
        }
        return .zero
    }
    
    var pageOrigin: CGPoint {
        if let page = pdfView.currentPage {
            return pdfView.convert(CGPoint(x: 0, y: 0), from: page)
        }
        return .zero
    }
    var totalPages: Int = 0

    var scale: CGFloat = .zero {
        didSet {
            pdfView.scaleFactor = scale
        }
    }
    
    var currentPage: Int = 0 {
        didSet {
            if let document = pdfView.document, let page = document.page(at: currentPage - 1) {
                pdfView.go(to: page)
            }
        }
    }

    @ObservationIgnored
    var pdfView: PDFView = PDFView()
    
    private let maxPointDisplacement: CGFloat = 0.1
    let tempUrl = URL.documentsDirectory.appendingPathComponent("temp.pdf")

    init(
        autoScales: Bool = true,
        usePageViewController: Bool = true,
        backgroundColor: UIColor = .yellow.withAlphaComponent(0.2),
        displayDirection: PDFDisplayDirection = .vertical,
        pageBreakMargins: UIEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    ) {
        pdfView.autoScales = autoScales
        pdfView.usePageViewController(usePageViewController)
        pdfView.backgroundColor = backgroundColor
        pdfView.displayDirection = displayDirection
        pdfView.pageBreakMargins = pageBreakMargins
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePageChange(notification:)), name: Notification.Name.PDFViewPageChanged, object: self.pdfView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleScaleChange(notification:)), name: Notification.Name.PDFViewScaleChanged, object: self.pdfView)
            
    }
    
    func setDocument(_ data: Data) {
        let pdfDocument = PDFDocument(data: data)
        pdfView.document = pdfDocument
        
        currentPage = 1
        totalPages = pdfView.document?.pageCount ?? 0
        scale = pdfView.scaleFactor
        
        savePDF()

    }
    
    @MainActor
    func addDrawingPoints(to point: DrawingPoint, isDragging: Bool) {
        guard isDragging, let previousPoint = self.drawingPoints.last else {
            self.drawingPoints.append(point)
            return
        }
        self.drawingPoints.append(contentsOf: points(start: previousPoint, end: point, maxDisplacement: previousPoint.strokeWidth/4))
    }
    
    @MainActor
    func removeDrawingPoints(center: CGPoint, radius: CGFloat) {
        let totalPoints = drawingPoints.count
        for (index, point) in drawingPoints.reversed().enumerated() {
            if circleContainsPoint(center: center, radius: radius, point: point.location) {
                self.drawingPoints.remove(at: totalPoints - 1 - index)
            }
        }
    }
    
    @MainActor
    func retrieveDrawingPoints() {
        guard let page = pdfView.currentPage else {
            self.drawingPoints = []
            return
        }
        let drawingAnnotations = page.annotations.map { $0 as? DrawingAnnotation }.filter { $0 != nil }.map({ $0! })
        if drawingAnnotations.count == 0 {
            self.drawingPoints = []
            return
        }
        for annotation in drawingAnnotations {
            self.drawingPoints.append(contentsOf: annotation.drawingPoints)
            page.removeAnnotation(annotation)
        }
    }
    
    
    func addDrawingAnnotation() {
        guard let page = pdfView.currentPage else { return }
        let drawing = DrawingAnnotation(self.drawingPoints)
        drawing.bounds = page.bounds(for: pdfView.displayBox)
        drawing.type = DrawingAnnotation.annotationType
        page.addAnnotation(drawing)
        savePDF()
        
        DispatchQueue.main.async {
            self.drawingPoints.removeAll()
        }
    }
                                           
    @objc private func handlePageChange(notification: Notification) {
       let currentPageIndex = if let currentPage = pdfView.currentPage, let document = pdfView.document {
            document.index(for: currentPage)
       } else {
           0
       }
       DispatchQueue.main.async {
           self.scale = self.pdfView.scaleFactor
           self.currentPage = currentPageIndex + 1
       }
    }

    @objc private func handleScaleChange(notification: Notification) {
       DispatchQueue.main.async {
           self.scale = self.pdfView.scaleFactor
       }
    }
    
    private func points(start: DrawingPoint, end: DrawingPoint, maxDisplacement: CGFloat) -> [DrawingPoint] {
        let path = Path { path in
            path.move(to: start.location)
            path.addLine(to: end.location)
        }
        let distance = abs(hypot(start.location.x - end.location.x, start.location.y - end.location.y))
        let totalPoints = distance/maxDisplacement
        
        let timeInterval: CGFloat = 1/CGFloat(totalPoints)
        var currentTime: CGFloat = 0
        var points: [DrawingPoint] = []
        
        while currentTime <= 1 {
            if let currentPoint = path.trimmedPath(from: 0, to: currentTime).currentPoint {
                points.append(DrawingPoint(location: currentPoint, strokeWidth: start.strokeWidth, strokeColor: start.strokeColor))
            }
            currentTime = currentTime + timeInterval
        }
        return points
    }
    
    private func circleContainsPoint(center: CGPoint, radius: CGFloat, point: CGPoint) -> Bool {
        let distance = abs(hypot(center.x - point.x, center.y - point.y))
        return distance <= radius
    }
    
    private func savePDF() {
        if FileManager.default.fileExists(atPath: tempUrl.absoluteString) {
            try? FileManager.default.removeItem(at: tempUrl)
        }
        let result = pdfView.document?.write(to: tempUrl)
        if result == false {
            print("Error saving PDF.")
        }
    }

}

private struct PDFViewRepresentable: UIViewRepresentable {
    @Environment(PDFManager.self) private var pdfManager

    func makeUIView(context: Context) -> PDFView {
        return pdfManager.pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) { }
}


private class DrawingAnnotation: PDFAnnotation {
    static let annotationType = "DrawingAnnotation"
    override var hasAppearanceStream: Bool { true }
    let drawingPoints: [DrawingPoint]
    
    private let maxDisplacement: CGFloat = 1
    
    init(_ drawingPoints: [DrawingPoint]) {
        self.drawingPoints = drawingPoints
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        // Draw original content under the new content.
        super.draw(with: box, in: context)
        UIGraphicsPushContext(context)
        context.saveGState()
        
        // translate and scale for different coordinate system
        // (0, 0) at top left corner
        let pageBounds = page?.bounds(for: box)  ?? .zero

        context.translateBy(x: 0, y: pageBounds.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        for point in drawingPoints {
            let path = UIBezierPath()
            path.addArc(withCenter: CGPoint(x: point.location.x, y:  point.location.y), radius: point.strokeWidth/2, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
            point.strokeColor.setFill()
            path.fill()
        }

        context.restoreGState()
        UIGraphicsPopContext()
    }
    
}



enum ViewMode {
    case view
    case draw
    case erase
}

struct DrawingView: View {
    @State private var pdfManager: PDFManager = PDFManager()
    @State private var viewMode: ViewMode = .view
    @State private var isDragging: Bool = false
    @State private var eraserLocation: CGPoint? = nil

    // radius in SwiftUI View Coordinate
    private let eraserRadius: CGFloat = 20
    
    var body: some View {
        PDFViewRepresentable()
            .environment(pdfManager)
            .overlay(content: {
                let width: CGFloat = pdfManager.pageBounds.width * pdfManager.scale
                let height: CGFloat = pdfManager.pageBounds.height * pdfManager.scale
                Rectangle()
                    .fill(viewMode != .view ? .red.opacity(0.1) : .clear )
                    .contentShape(Rectangle())
                    .allowsHitTesting(viewMode != .view)
                    .gesture(
                        DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
                            .onChanged { value in
                                guard viewMode != .view else { return }
                                
                                let bounds = CGRect(origin: .zero, size: CGSize(width: pdfManager.pageBounds.width * pdfManager.scale, height: pdfManager.pageBounds.height * pdfManager.scale))
                                let location = value.location
                                
                                if !bounds.contains(location) {
                                    isDragging = false
                                    return
                                }

                                let locationInPDF = CGPoint(x: location.x / pdfManager.scale, y: location.y / pdfManager.scale)

                                if viewMode == .erase {
                                    eraserLocation = value.location
                                    pdfManager.removeDrawingPoints(center: locationInPDF, radius: eraserRadius/pdfManager.scale)
                                    return
                                }
                                
                                pdfManager.addDrawingPoints(to: DrawingPoint(location: locationInPDF), isDragging: isDragging)

                                isDragging = true
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                    .overlay(content: {
                        ForEach(0..<pdfManager.drawingPoints.count, id: \.self) { index in
                            let point = pdfManager.drawingPoints[index]
                            let strokeWidth = point.strokeWidth * pdfManager.scale
                            Circle()
                                .frame(width: strokeWidth, height: strokeWidth)
                                .position(CGPoint(x: point.location.x * pdfManager.scale, y: point.location.y * pdfManager.scale))
                        }
                    })
                    .overlay {
                        if viewMode == .erase, let eraserLocation {
                            Circle()
                                .fill(.gray.opacity(0.8))
                                .frame(width: eraserRadius*2, height:eraserRadius*2)
                                .position(eraserLocation)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(width: width, height: height)
                    .position(CGPoint(x: pdfManager.pageOrigin.x + width/2 , y: pdfManager.pageOrigin.y - height/2))

            })
        .ignoresSafeArea(.all)
        .overlay(alignment: .topLeading, content: {
            HStack {
                if viewMode == .view {
                    Button(action: {
                        viewMode = .draw
                    }, label: {
                        Text("Draw")
                    })
                    .foregroundStyle(.black)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.5)))

                    Button(action: {
                        viewMode = .erase
                        pdfManager.retrieveDrawingPoints()
                        eraserLocation = CGPoint(x: pdfManager.pageBounds.width * pdfManager.scale / 2, y: pdfManager.pageBounds.height * pdfManager.scale / 2)
                    }, label: {
                        Text("Erase")
                    })
                    .foregroundStyle(.black)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.5)))

                } else {
                    Button(action: {
                        pdfManager.addDrawingAnnotation()
                        viewMode = .view
                        eraserLocation = nil
                    }, label: {
                        Text("Finish")
                    })
                    .foregroundStyle(.black)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.5)))
                }
            }
            .padding()

        })
        .overlay(alignment: .topTrailing, content: {
            ShareLink(item: pdfManager.tempUrl)
            .foregroundStyle(.black)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.5)))
            .padding()

        })
        .onAppear {
            if let url = Bundle.main.url(forResource: "Sample", withExtension: "pdf"), let data = try? Data(contentsOf: url) {
                pdfManager.setDocument(data)
            }
        }
    }
}

 
// in PDF Coordinate
private struct DrawingPoint {
    var location: CGPoint
    var strokeWidth: CGFloat = 10
    var strokeColor: UIColor = UIColor.black
}

#Preview {
    
    DrawingView()
    
}

#Preview {
    
    ScrollView(.horizontal) {
        
        HStack(spacing: 8) {
            
            ForEach(0..<4, id: \.self) { index in
                
                Rectangle()
                    .fill(index % 2 == 0 ? Color.red : Color.blue)
                    .frame(height: 120)
                    .containerRelativeFrame(.horizontal)
                
            }
            
        }
        .scrollTargetLayout()
        
    }
    .scrollTargetBehavior(.viewAligned)
    .safeAreaPadding(.horizontal, 16)
    
}
