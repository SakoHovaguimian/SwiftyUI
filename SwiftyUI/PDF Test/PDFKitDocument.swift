    //
    //  PDFKitDocument.swift
    //  SwiftyUI
    //
    //  Created by Sako Hovaguimian on 12/2/25.
    //


    import UIKit
    import PDFKit

    class PDFKitDocument: UIDocument {

        var pdfDocument: PDFDocument?
        var pdf: PDFDocumentView

        enum MyPencilKitOverPDFDocumentError: Error {
            case open
        }

        init(fileURL url: URL, pdf: PDFDocumentView) {
            self.pdf = pdf
            super.init(fileURL: url)
        }

        override func load(fromContents contents: Any, ofType typeName: String?) throws {
            guard let typeName = typeName else {
                throw MyPencilKitOverPDFDocumentError.open
            }
            self.load(typeName: typeName, contents: contents)
        }

        override func contents(forType typeName: String) throws -> Any {
            guard let pdfDocument = pdfDocument else { return Data() }

            for i in 0...pdfDocument.pageCount - 1 {
                guard let page = pdfDocument.page(at: i) else { return Data() }
                addDrawingAnnottion(page)
            }

            let options = [PDFDocumentWriteOption.burnInAnnotationsOption: true]
            // ,PDFDocumentWriteOption.saveImagesAsJPEGOption:true,PDFDocumentWriteOption.optimizeImagesForScreenOption:true

            guard let resultData = pdfDocument.dataRepresentation(options: options) else { return Data() }
            return resultData
        }
    }

    //MARK: - Helper
    extension PDFKitDocument {

        func load(typeName: String, contents: Any) {
            switch typeName {
            case "com.adobe.pdf":
                guard let data = contents as? Data else { self.pdfDocument = nil; return }
                self.pdfDocument = PDFDocument(data: data)
            default:
                print("loadFromContents: typeName : \(String(describing: typeName))")
            }
        }

        func addDrawingAnnottion(_ page: PDFPage) {
            if let page = (page as? PDFDocumentPage),
               let drawing = page.resizableContainerView?.canvasView.drawing {

                let mediaBoxBounds = page.bounds(for: .cropBox)
                let mediaBoxHeight = page.bounds(for: .cropBox).height

                let userDefinedAnnotationProperties = [
                    DrawingAnnotation.pdfPageMediaBoxHeightKey: NSNumber(value: mediaBoxHeight)
                ]

                let newAnnotation = DrawingAnnotation(
                    bounds: mediaBoxBounds,
                    forType: .stamp,
                    withProperties: userDefinedAnnotationProperties
                )

                do {
                    let codedData = try NSKeyedArchiver.archivedData(
                        withRootObject: drawing,
                        requiringSecureCoding: true
                    )

                    newAnnotation.setValue(
                        codedData,
                        forAnnotationKey: PDFAnnotationKey(rawValue: DrawingAnnotation.drawingDataKey)
                    )
                } catch {
                    print("\(error.localizedDescription)")
                }

                page.addAnnotation(newAnnotation)
            }
        }
    }

    //MARK: - PDFDocumentDelegate
    extension PDFDocumentView: PDFDocumentDelegate {

        func classForPage() -> AnyClass {
            return PDFDocumentPage.self
        }
    }

    //MARK: - UIScrollViewDelegate
    extension PDFDocumentView: UIScrollViewDelegate {

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            guard let page = self.currentPage,
                  let index = self.document?.index(for: page) else { return }

            currentPageIndex = index
        }
    }
