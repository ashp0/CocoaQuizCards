//
//  QCTableCellView.swift
//  QuizCards
//
//  Created by Ashwin Paudel on 2021-02-21.
//

import Cocoa

class QCTableCellView: NSTableCellView {
    
    @IBOutlet weak var QCItemTitle: NSTextField!
    @IBOutlet weak var QCPreviewButton: NSButton!
    @IBOutlet weak var QCEditButton: NSButton!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
