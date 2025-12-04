//
//  DrawingAnnotation.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/2/25.
//


import PDFKit

class DrawingAnnotation: PDFAnnotation {
    
    static let drawingDataKey: String = "drawingData"
    static let pdfPageMediaBoxHeightKey: String = "pdfPageMediaBoxHeight"
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        
        guard let page = self.page as? PDFDocumentPage,
              let pdfPageMediaBoxHeightKey = self.value(
                forAnnotationKey: PDFAnnotationKey(
                    rawValue: DrawingAnnotation.pdfPageMediaBoxHeightKey
                )
              ) as? NSNumber else {
            return
        }
        
        let verticalShiftValue = CGFloat(truncating: pdfPageMediaBoxHeightKey)
        
        UIGraphicsPushContext(context)
        context.saveGState()
        
        let transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
            .translatedBy(x: 0.0, y: -verticalShiftValue)
        
        context.concatenate(transform)
        
        if let drawing = page.resizableContainerView?.canvasView.drawing {
            let image = drawing.image(from: drawing.bounds, scale: 1)
            image.draw(in: drawing.bounds)
        }
        
        context.restoreGState()
        UIGraphicsPopContext()
    }
}