//
//  QCEditorTableCellView.swift
//  QuizCards
//
//  Created by Ashwin Paudel on 2021-02-21.
//

import Cocoa

class QCEditorTableCellView: NSTableCellView {
    @IBOutlet weak var QCQuestionTextField: NSTextField!
    @IBOutlet weak var QCAnswerTextField: NSTextField!
    @IBOutlet weak var QCImageButton: NSButton!
    
    private var selectedCell: Bool = false
    private var viewHasDrawn: Bool = false

    var isSelected: Bool {
        get {
            return selectedCell
        }
        set {
            print("[Cell] isSelected")
            selectedCell = newValue
            QCQuestionTextField.isEnabled = newValue
            QCAnswerTextField.isEnabled = newValue
            QCImageButton.isEnabled = newValue
        }
    }
    
    override func viewWillDraw() {
        if !viewHasDrawn {
            defer { viewHasDrawn = true }
            
            
            isSelected = false
        }
    }
}
