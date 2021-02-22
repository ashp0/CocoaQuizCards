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
        let newURL = urls[0].absoluteString.replacingOccurrences(of: "file://", with: "")
        var itemCount = getCards()?.root.count
        var i = 0
                let newhistoryitem = CardItem(path: newURL, name: "Test")
                let encoder = PropertyListEncoder()
                encoder.outputFormat = .xml
                let pListFilURL = QCDataDir()?.appendingPathComponent("cards.plist")
                if !FileManager.default.fileExists(atPath: pListFilURL!.absoluteString) {
                     FileManager.default.createFile(atPath: pListFilURL!.absoluteString, contents: "".data(using: .utf8), attributes: nil)
                }
                var allItems: [CardItem] = []
                allItems.append(contentsOf: getCards()!.root)
        //            allItems.append(contentsOf: getHistoryListItem()!.root)
                allItems.append(newhistoryitem)
                let newList = CardList(root: allItems)
                do {
                    let data = try encoder.encode(newList)
                    try data.write(to: pListFilURL!)
//                    tableView.reloadData()
                    
                } catch {
                    print(error)
        }
    }


}

