//
//  QCItemListViewController.swift
//  QuizCards
//
//  Created by Ashwin Paudel on 2021-02-21.
//

import Cocoa

class QCItemListViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            self.tableView.reloadData()
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        tableView.reloadData()
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let cards = getCards() {
            return cards.root.count
        } else {
            return 0
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
                            tableView.reloadData()
                            
                        } catch {
                            print(error)
                }
            }
        }
    }
    @IBAction func addNewFileButton(_ sender: Any) {
        let menu = NSMenu()
        menu.addItem(withTitle: "Open", action: #selector(openQCCardFile), keyEquivalent: "")
        menu.addItem(withTitle: "Create New", action: #selector(createNewQCCardFile), keyEquivalent: "")
        
        if let sender = sender as? NSButton {
            if let event = NSApplication.shared.currentEvent {
            NSMenu.popUpContextMenu(menu, with: event, for: sender)
//            NSMenu.popUpContextMenu(menu, with: event, for: sender)
        }
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
    @objc func createNewQCCardFile() {
        
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.canChooseFiles = false
//        panel.allowedFileTypes = ["qccards"]
        panel.beginSheetModal(for: self.view.window!) { [self] (responce) in
            if responce == .OK {
                do {
                let newURL = panel.url!.absoluteString.replacingOccurrences(of: "file://", with: "")
                    let fileName = getString(title: "What is the file name", question: "Enter the file name underneath", defaultValue: "fileName")
                    let filePath = URL(string: newURL)?.appendingPathComponent("\(fileName).qccards")
print("asdfasdfas")
                    print(filePath)
                    let applicationSupportFolderURL = try panel.url
                // swiftlint:disable force_cast
                let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
                    let folder = applicationSupportFolderURL!.appendingPathComponent("\(fileName).qccards", isDirectory: true)
                print("[ERR]: Folder location: \(folder.path)")
                if !FileManager.default.fileExists(atPath: folder.path) {
                    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
                }
                    try templateString.write(to: folder.appendingPathComponent("card.plist"), atomically: true, encoding: .utf8)
                    
                    let newhistoryitem = CardItem(path: filePath!.absoluteString, name: "Test")
                    let encoder = PropertyListEncoder()
                    encoder.outputFormat = .xml
                    let pListFilURL = QCDataDir()?.appendingPathComponent("cards.plist")
                    if !FileManager.default.fileExists(atPath: pListFilURL!.absoluteString) {
                         FileManager.default.createFile(atPath: pListFilURL!.absoluteString, contents: "".data(using: .utf8), attributes: nil)
                    }
                    
                    var allItems: [CardItem] = []
                   // allItems.append(contentsOf: getCards()!.root)
            //            allItems.append(contentsOf: getHistoryListItem()!.root)
                    allItems.append(newhistoryitem)
                    let newList = CardList(root: allItems)
                    do {
                        let data = try encoder.encode(newList)
                        try data.write(to: pListFilURL!)
                        tableView.reloadData()
                        
                    } catch {
                        print(error)
            }
//                return folder
            } catch {
            }
                
                
            }
        }

    }
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
    @IBAction func closseButton(_ sender: Any) {
        exit(0)
    }
    func copyFilesFromBundleToDocumentsFolderWith(fileExtension: String) {
        if let resPath = Bundle.main.resourcePath {
            do {
                let dirContents = try FileManager.default.contentsOfDirectory(atPath: resPath)
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let filteredFiles = dirContents.filter{ $0.contains(fileExtension)}
                for fileName in filteredFiles {
                    if let documentsURL = documentsURL {
                        let sourceURL = Bundle.main.bundleURL.appendingPathComponent(fileName)
                        let destURL = documentsURL.appendingPathComponent(fileName)
                        do { try FileManager.default.copyItem(at: sourceURL, to: destURL) } catch { }
                    }
                }
            } catch { }
        }
    }
    @objc func deleteButtonClicked() {
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
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let pListFilURL = QCDataDir()?.appendingPathComponent("cards.plist")
        if !FileManager.default.fileExists(atPath: pListFilURL!.absoluteString) {
             FileManager.default.createFile(atPath: pListFilURL!.absoluteString, contents: "".data(using: .utf8), attributes: nil)
        }
        var allItems: [CardItem] = []
        allItems.append(contentsOf: getCards()!.root)
//            allItems.append(contentsOf: getHistoryListItem()!.root)
        allItems.remove(at: tableView.selectedRow)
        let newList = CardList(root: allItems)
        do {
            let data = try encoder.encode(newList)
            try data.write(to: pListFilURL!)
            tableView.reloadData()
            
        } catch {
            print(error)
}
    }
    @objc func previewButtonClicked() {
        let isIndexValid = getCards()?.root.indices.contains(tableView.selectedRow)
        if isIndexValid == true {
            let window = NSWindow(contentViewController: QCPresenterViewController(fileURL: URL(string: (getCards()?.root[tableView.selectedRow].path)!)))
            
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
//        presentAsModalWindow(QCPresenterViewController(fileURL: URL(string: (getCards()?.root[tableView.selectedRow].path)!)))
        
        
    }
    @objc func editButtonClicked() {
//        presentAsModalWindow(QCPresenterViewController(fileURL: URL(string: (getCards()?.root[tableView.selectedRow].path)!)))
        print(tableView.selectedRow)
        if tableView.selectedRow == -1 {
        } else {
        var window = NSWindow(contentViewController: QCEditorViewController(fileURL: URL(string: (getCards()?.root[tableView.selectedRow].path)!)))
        window.title = ""
        window.titlebarAppearsTransparent = true
            window.styleMask = [.fullSizeContentView, .borderless, .titled, .resizable]
//            window.standardWindowButton(.zoomButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)!.isHidden = true
            window.standardWindowButton(.zoomButton)!.isHidden = true
            window.standardWindowButton(.closeButton)!.isHidden = true
        if window.isVisible != true {
            window.makeKeyAndOrderFront(nil)
        }
        }
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "extensionTableViewListCellView"), owner: self) as? QCTableCellView else { return nil }
        let path = getCards()!.root[row].path
        print("asdfasdf")
        print(path)
        let infoListFile = URL(string: path)!.appendingPathComponent("card.plist")
        print("safdijasldfijasldf")
        print(infoListFile)
//        let name = readPlistFile(infoListFile.absoluteString, "name") as! String
        
        cell.QCPreviewButton.action = #selector(previewButtonClicked)
        cell.QCEditButton.action = #selector(editButtonClicked)
        cell.QCDeleteButton.action = #selector(deleteButtonClicked)
        let dict = NSDictionary(contentsOfFile: infoListFile.absoluteString) as! [String: AnyObject]
        print(readPlistFile(infoListFile.absoluteString, "name"))
        print(infoListFile)
          if let QCName = dict["name"] {
               print("Info.plist : \(QCName)")
            cell.QCItemTitle.stringValue = QCName as! String

//           var dashC = CoachMarksDict["DashBoardCompleted"] as! Bool
//            print("DashBoardCompleted state :\(dashC) ")
          }
        
        
        
        print("asdfljnasdklfjdslafksadfkmsd")
//        print(name)

return cell
    }
    
}
public func getCards() ->  CardList? {
    let decoder = PropertyListDecoder()
    let url = QCDataDir()?.appendingPathComponent("cards.plist")
    if !FileManager.default.fileExists(atPath: url!.absoluteString) {
         FileManager.default.createFile(atPath: url!.absoluteString, contents: "".data(using: .utf8), attributes: nil)
    }
    if let data = try? Data(contentsOf: url!) {
        if let settings = try? decoder.decode(CardList.self, from: data) {
            return settings
        }
    }
    return nil
}

public struct CardList: Codable {
    let root: [CardItem]
}
public struct CardItem: Codable {
    let path: String
    let name: String
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
}

public func QCDataDir() -> URL? {
    do {
        let applicationSupportFolderURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        // swiftlint:disable force_cast
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
        let folder = applicationSupportFolderURL.appendingPathComponent("\(appName)/usr/data", isDirectory: true)
        print("[ERR]: Folder location: \(folder.path)")
        if !FileManager.default.fileExists(atPath: folder.path) {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        }
        return folder
    } catch {
    }
    return nil
}
public func readPlistFile(_ path: String, _ key: String) -> Any {
    let dataDir = URL(string: path)
    let output: Any
    print("sadfaisdfisdaf90u9809")
    print(dataDir!)
    if let dict = NSDictionary(contentsOf: dataDir!) {
        print("sadfaisdfisdaf90u9809")

        print(dict)
        output = dict.object(forKey: key)!
        return output
    }
    print("errorororororoorororororororoororororororo")
    return "not found" as? Any
}
extension FileManager {

    open func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }

}
