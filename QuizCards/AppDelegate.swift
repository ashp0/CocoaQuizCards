//
//  AppDelegate.swift
//  QuizCards
//
//  Created by Ashwin Paudel on 2021-02-20.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

//    @IBOutlet var window: NSWindow!
let windowController = QCWindowController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        windowController.showWindow(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    func application(_ application: NSApplication, open urls: [URL]) {
        
    }


}

