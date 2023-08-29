//
//  QCItemListViewController.swift
//  QuizCards
//
//  Created by Ashwin Paudel on 2021-02-21.
//

import Cocoa

class QCItemListViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var tableView: NSTableView!
    
    var cardList: CardList
    let templateString = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>name</key>
    <string>Template</string>
    <key>questions and answers</key>
    <array>
        <dict>
            <key>answer</key>
            <string>Answer</string>
            <key>question</key>
            <string>Question</string>
        </dict>
    </array>
</dict>
</plist>
"""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey), name: NSWindow.didBecomeKeyNotification, object: nil)
    }
    
    @objc func windowDidBecomeKey(_ notification: Notification) {
        if notification.object is NSWindow {
            // Handle the active window
            self.cardList = getCards()!
            tableView.reloadData()
        }
    }
    
    init() {
        self.cardList = getCards()!
        super.init(nibName: "QCItemListViewController", bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func saveCards() {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let pListFilURL = QCDataDir()?.appendingPathComponent("cards.plist")
        
        do {
            let data = try encoder.encode(cardList)
            try data.write(to: pListFilURL!)
        } catch {
            print("[ListViewController] Saving cards", error.localizedDescription)
        }
    }
    
    
    @IBAction func addNewFileButton(_ sender: Any) {
        let menu = NSMenu()
        menu.addItem(withTitle: "Open", action: #selector(openQCCardFile), keyEquivalent: "")
        menu.addItem(withTitle: "Create New", action: #selector(createNewQCCardFile), keyEquivalent: "")
        
        if let sender = sender as? NSButton {
            if let event = NSApplication.shared.currentEvent {
                NSMenu.popUpContextMenu(menu, with: event, for: sender)
            }
        }
    }
    
    @objc func openQCCardFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["qccards"]
        panel.beginSheetModal(for: self.view.window!) { [self] (responce) in
            if responce == .OK {
                let newURL = panel.url!.absoluteString.replacingOccurrences(of: "file://", with: "")
                let newFlashcard = CardItem(path: newURL, name: panel.url?.deletingPathExtension().lastPathComponent ?? "Test")
                cardList.root.append(newFlashcard)
                
                print("ROLLLL", cardList.root)
                tableView.reloadData()
            }
        }
    }
    
    @objc func createNewQCCardFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.canChooseFiles = false
        //                panel.allowedFileTypes = ["qccards"]
        panel.beginSheetModal(for: self.view.window!) { [self] (responce) in
            if responce == .OK {
                do {
                    // Ask for name, then create the file
                    let newURL = panel.url!.absoluteString.replacingOccurrences(of: "file://", with: "")
                    let fileName = getString(title: "What is the file name", question: "Enter the file name underneath", defaultValue: "fileName")
                    let filePath = URL(string: newURL)?.appendingPathComponent("\(fileName).qccards")
                    let applicationSupportFolderURL = panel.url
                    
                    
                    let folder = applicationSupportFolderURL!.appendingPathComponent("\(fileName).qccards", isDirectory: true)
                    
                    if !FileManager.default.fileExists(atPath: folder.path) {
                        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
                    }
                    
                    try templateString.write(to: folder.appendingPathComponent("card.plist"), atomically: true, encoding: .utf8)
                    
                    let newFlashcard = CardItem(path: filePath!.absoluteString, name: fileName)
                    cardList.root.append(newFlashcard)
                    
                    tableView.reloadData()
                } catch {
                    print("[ItemList] Created", error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func closseButton(_ sender: Any) {
        saveCards()
        exit(0)
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        guard tableView.selectedRow < cardList.root.count, tableView.selectedRow != -1 else { return }
        
        if UserDefaults.standard.bool(forKey: "willShowDeleteDialog") == true {
            let alert = NSAlert()
            alert.messageText = "Item will be deleted from the list"
            alert.addButton(withTitle: "Ok")
            alert.showsSuppressionButton = true
            
            if let supress = alert.suppressionButton {
                let state = supress.state
                switch state {
                case NSControl.StateValue.on:
                    UserDefaults.standard.set(true, forKey: "willShowDeleteDialog")
                default: break
                }
            }
            alert.runModal()
        }
        
        cardList.root.remove(at: tableView.selectedRow)
        tableView.reloadData()
    }
    
    @IBAction func previewButtonClicked(_ sender: Any) {
        guard tableView.selectedRow != -1 else { return }
        saveCards()
        
        let window = NSWindow(contentViewController: QCPresenterViewController(fileURL: URL(string: cardList.root[tableView.selectedRow].path)!))
        
        window.title = ""
        window.titlebarAppearsTransparent = true
        window.styleMask = [.fullSizeContentView, .borderless, .titled, .resizable]
        window.standardWindowButton(.miniaturizeButton)!.isHidden = true
        window.standardWindowButton(.zoomButton)!.isHidden = true
        window.standardWindowButton(.closeButton)!.isHidden = true
        if window.isVisible != true {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        guard tableView.selectedRow != -1 else { return }
        saveCards()
        
        let window = NSWindow(contentViewController: QCEditorViewController(fileURL: URL(string: cardList.root[tableView.selectedRow].path)!, tableView.selectedRow))
        window.title = ""
        window.titlebarAppearsTransparent = true
        window.styleMask = [.fullSizeContentView, .borderless, .titled, .resizable]
        window.standardWindowButton(.miniaturizeButton)!.isHidden = true
        window.standardWindowButton(.zoomButton)!.isHidden = true
        window.standardWindowButton(.closeButton)!.isHidden = true
        if window.isVisible != true {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    func getString(title: String, question: String, defaultValue: String) -> String {
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")      // 1st button
        msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = title
        msg.informativeText = question
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = defaultValue
        
        msg.accessoryView = txt
        let response: NSApplication.ModalResponse = msg.runModal()
        
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            return txt.stringValue
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "extensionTableViewListCellView"), owner: self) as? QCTableCellView else { return nil }
        cell.QCItemTitle.stringValue = cardList.root[row].name
        
        return cell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return cardList.root.count
    }
    
}

public func getCards() ->  CardList? {
    let decoder = PropertyListDecoder()
    let url = QCDataDir()?.appendingPathComponent("cards.plist")
    
    if let data = try? Data(contentsOf: url!) {
        if let settings = try? decoder.decode(CardList.self, from: data) {
            return settings
        }
    }
    return nil
}

public struct CardList: Codable {
    var root: [CardItem]
}

public struct CardItem: Codable {
    let path: String
    var name: String
}


public struct QCCardList: Codable {
    let root: [QCCardItem]
}

public struct QCCardItem: Codable {
    let questionAndAnswer: [QCQA]
}

public struct QCQA: Codable {
    let question: String
    let answer: String
    let image: String?
}

public func QCDataDir() -> URL? {
    do {
        let applicationSupportFolderURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let folder = applicationSupportFolderURL.appendingPathComponent("QuizCards/usr/data", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: folder.path) {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        }
        
        return folder
    } catch {
        print("[QCDATADIR]", error.localizedDescription)
    }
    return nil
}
