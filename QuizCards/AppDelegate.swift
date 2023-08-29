//
//  AppDelegate.swift
//  QuizCards
//
//  Created by Ashwin Paudel on 2021-02-20.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let windowController = QCWindowController()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if UserDefaults.standard.bool(forKey: "firstTimeLaunched") {
            // First ever launch
            showTutorial()
            
            let url = QCDataDir()?.appendingPathComponent("cards.plist")
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            do {
                let data = try encoder.encode(CardList(root: []))
                try data.write(to: url!)
            } catch {
                print("[AppDel] updateName()", error.localizedDescription)
            }
        }
        
        windowController.showWindow(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        let pListFileName = "cards.plist"
        
        guard let pListFileURL = QCDataDir()?.appendingPathComponent(pListFileName) else {
            print("Error: Unable to create plist file URL.")
            return
        }
        
        var allItems: [CardItem] = getCards()?.root ?? []
        
        for url in urls {
            let newURL = url.absoluteString.replacingOccurrences(of: "file://", with: "")
            let newCardName = url.deletingPathExtension().lastPathComponent
            
            if allItems.contains(where: { $0.name == newCardName }) {
                print("Card item with the same name already exists: \(newCardName)")
                // Should Present Card
                continue
            }
            
            let newCardItem = CardItem(path: newURL, name: newCardName)
            allItems.append(newCardItem)
        }
        
        let newList = CardList(root: allItems)
        
        do {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            let data = try encoder.encode(newList)
            try data.write(to: pListFileURL)
        } catch {
            print("Error while encoding/writing to plist: \(error)")
        }
    }
    
    
    func showTutorial() {
        UserDefaults.standard.set(false, forKey: "firstTimeLaunched")
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
}

