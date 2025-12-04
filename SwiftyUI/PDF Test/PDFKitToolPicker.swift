//
//  PDFKitToolPicker.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/2/25.
//


import UIKit
import PencilKit

class PDFKitToolPicker: NSObject {

    let toolPicker = PKToolPicker()

    static let shared = PDFKitToolPicker()

    override init() {
        
        super.init()
        self.setToolToYellowHighlighter()
        
    }

    func setToolToYellowHighlighter() {
        let highlighterYellowColor = UIColor(
            red: 1.0,
            green: 1.0,
            blue: 0.0,
            alpha: 0.7
        )

        self.toolPicker.selectedTool = PKInkingTool(
            .marker,
            color: highlighterYellowColor,
            width: 25.0
        )
    }
}
