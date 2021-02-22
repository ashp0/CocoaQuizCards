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
        if (UserDefaults.standard.bool(forKey: "firstTimeLaunched")) {
           // App already launched

        } else {
           // This is the first launch ever
           UserDefaults.standard.set(true, forKey: "firstTimeLaunched")
           UserDefaults.standard.synchronize()
            let alert = NSAlert()
            alert.messageText = "Do you want to watch a tutorial?"
            alert.addButton(withTitle: "Watch Video")
            alert.addButton(withTitle: "I already know how to use the app")
            
            let responce = alert.runModal()
            switch responce {
            case .alertFirstButtonReturn:
                NSWorkspace.shared.open(URL(string: "https://www.google.com")!)
            default:
                break
            }
        }
        windowController.showWindow(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    func application(_ application: NSApplication, open urls: [URL]) {
        
    }


}

