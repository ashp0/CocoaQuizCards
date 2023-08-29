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
        self.contentViewController = QCItemListViewController()
    }
    
    convenience init() {
        self.init(windowNibName: "QCWindowController")
    }
}
