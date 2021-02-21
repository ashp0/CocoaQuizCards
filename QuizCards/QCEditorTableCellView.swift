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

@IBOutlet weak var QCSaveButton: NSButton!

override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    // Drawing code here.
}
}
