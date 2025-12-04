//
//  PDFKitDrawingView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/2/25.
//


import UIKit
import PencilKit
import PDFKit

class PDFKitDrawingView: UIView {

    enum ModeType {
        case drawing
        case `default`
    }

    var currentPageIndex: Int = 0
    var pdf: PDFView?
    var page: PDFDocumentPage?

    var canvasView: PKCanvasView = {
        let view = PKCanvasView(frame: .zero)
        view.drawingPolicy = .anyInput
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()

        var config = UIButton.Configuration.filled()
        config.titlePadding = 0
        config.imagePlacement = .top
        config.imagePadding = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func enable(mode: ModeType, image: ImageResource? = nil) {
        switch mode {
        case .drawing:
            self.canvasView.isUserInteractionEnabled = true

        case .default:
            self.canvasView.isUserInteractionEnabled = false
        }
    }

    @objc private func didAddSignatureButtonClicked() {
//        guard let page = self.page else { return }
//        let img = ImageResource.sign1
//        let pageRect = page.bounds(for: .mediaBox).maxY
//        print(pageRect)
    }
}

// MARK: - Settings

private extension PDFKitDrawingView {

    func setupViews() {
        addSubview(canvasView)

        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: topAnchor),
            canvasView.trailingAnchor.constraint(equalTo: trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])
    }
}
