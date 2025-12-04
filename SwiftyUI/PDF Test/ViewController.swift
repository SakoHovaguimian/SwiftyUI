//
//  ViewController.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/2/25.
//


import UIKit
import PDFKit
import PencilKit

class ViewController: UIViewController {

    var pdfView: PDFDocumentView!
    var drawButton: UIButton!
    var saveButton: UIButton!

    private var isDrawing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        pdfView = PDFDocumentView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false

        drawButton = UIButton(type: .system)
        drawButton.setTitle("Start Drawing", for: .normal)
        drawButton.translatesAutoresizingMaskIntoConstraints = false
        drawButton.addTarget(
            self,
            action: #selector(drawButtonTapped),
            for: .touchUpInside
        )

        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(
            self,
            action: #selector(saveButtonTapped),
            for: .touchUpInside
        )

        // Add PDFView + buttons to view
        view.addSubview(drawButton)
        view.addSubview(saveButton)
        view.addSubview(pdfView)

        // Set constraints for Draw button
        NSLayoutConstraint.activate([
            drawButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),
            drawButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            )
        ])

        // Set constraints for Save button
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),
            saveButton.leadingAnchor.constraint(
                equalTo: drawButton.trailingAnchor,
                constant: 16
            )
        ])

        // Set constraints for PDFView
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(
                equalTo: drawButton.bottomAnchor,
                constant: 16
            ),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Load sample.pdf from bundle
        if let path = Bundle.main.path(forResource: "Sample", ofType: "pdf") {
            let url = URL(fileURLWithPath: path)
            pdfView.loadPDF(url: url)
        }

        /*
        // Or: load last saved PDF from Documents directory
        do {
            let fileManager = FileManager.default
            let documentsURL = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )

            let fileURLs = try fileManager.contentsOfDirectory(
                at: documentsURL,
                includingPropertiesForKeys: nil
            )

            let documentURLs = fileURLs.filter { $0.pathExtension == "pdf" }
            debugPrint(documentURLs.count)

            pdfView.loadPDF(url: documentURLs.last)
        } catch {
            // handle error
        }
        */
    }

    // MARK: - Actions

    @objc func drawButtonTapped() {
        isDrawing.toggle()
        pdfView.drawing(isEnable: isDrawing)

        if isDrawing {
            drawButton.setTitle("Stop Drawing", for: .normal)
        } else {
            drawButton.setTitle("Start Drawing", for: .normal)
        }
    }

    @objc func saveButtonTapped() {
        let documentsURL = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )

        pdfView.saveTo(
            url: documentsURL,
            fileName: "my.pdf"
        )
    }
}
