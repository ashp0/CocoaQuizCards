//
//  QCWindowController.swift
//  QuizCards
//
//  Created by Ashwin Paudel on 2021-02-20.
//

import Cocoa

class QCWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.contentViewController = QCItemListViewController(nibName: "QCItemListViewController", bundle: nil)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    convenience init() {
        self.init(windowNibName: "QCWindowController")
    }
}
