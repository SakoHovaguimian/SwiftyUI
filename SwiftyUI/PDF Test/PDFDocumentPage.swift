//
//  PDFDocumentPage.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/2/25.
//


//  PDFDocumentPage.swift

import PDFKit

class PDFDocumentPage: PDFPage {
    
    var resizableContainerView: PDFKitDrawingView?
    
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        
        super.draw(with: box, to: context)
        
        UIGraphicsPushContext(context)
        context.saveGState()
        
//        let pageBounds = self.bounds(for: box)
//        context.translateBy(x: 50.0, y: pageBounds.size.height + 150)
//        context.scaleBy(x: 1.0, y: -1.0)
//        context.rotate(by: CGFloat.pi / 10.0)
//        
//        let userName = "ADEL" // CTS.Auth.userName.get()
//        var color = UIColor.black
//        // if CTS.DocumentDetails.watermark.hashValue { color = .clear }
//        
//        let string: NSString = userName as NSString
//        let attributes: [NSAttributedString.Key: Any] = [
//            NSAttributedString.Key.foregroundColor: color,
//            // TODO: Change Font
//            // .font: Fonts.ffShamelFamilySemiRoundBold.semiRoundBold.font(size: 18)
//        ]
//        
//        let rw = CGFloat(130)
//        let rh = CGFloat(50)
//        let bw = pageBounds.size.width
//        let bh = pageBounds.size.height
//        
//        let wSteps = (bw / rw) + 1
//        let hSteps = (bh / rh) + 1
//        
//        for i in stride(from: 0 as CGFloat, to: hSteps, by: +1 as CGFloat) {
//            for j in stride(from: 0 as CGFloat, to: wSteps, by: +1 as CGFloat) {
//                string.draw(
//                    at: CGPoint(x: j * rw, y: i * rh),
//                    withAttributes: attributes
//                )
//            }
//        }
        
        context.restoreGState()
        UIGraphicsPopContext()
    }
}
