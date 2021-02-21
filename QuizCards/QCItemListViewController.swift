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
        tableView.delegate = self
        tableView.dataSource = self
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        print(getCards()!)
        return getCards()!.root.count
    }
    @IBAction func addNewFileButton(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["qccards"]
        panel.beginSheetModal(for: self.view.window!) { [self] (responce) in
            if responce == .OK {
                let newhistoryitem = CardItem(path: panel.url!.absoluteString, name: "Test")
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
                } catch {
                    print(error)
                }
            }
    }
        
        self.dismiss(self)
//        FileManager.default.secureCopyItem(at: <#T##URL#>, to: <#T##URL#>)
    }
    @IBAction func closseButton(_ sender: Any) {
        exit(0)
    }
    @objc func previewButtonClicked() {
//        presentAsModalWindow(QCPresenterViewController(fileURL: URL(string: (getCards()?.root[tableView.selectedRow].path)!)))
        
        var window = NSWindow(contentViewController: QCPresenterViewController(fileURL: URL(string: (getCards()?.root[tableView.selectedRow].path)!)))
        
        window.title = ""
        window.titlebarAppearsTransparent = true
        window.styleMask = [.fullSizeContentView, .borderless, .titled]
        if window.isVisible != true {
            window.makeKeyAndOrderFront(nil)
        }
    }
    @objc func editButtonClicked() {
//        presentAsModalWindow(QCPresenterViewController(fileURL: URL(string: (getCards()?.root[tableView.selectedRow].path)!)))
        print(tableView.selectedRow)
        if tableView.selectedRow == -1 {
        } else {
        var window = NSWindow(contentViewController: QCEditorViewController(fileURL: URL(string: (getCards()?.root[tableView.selectedRow].path)!)))
        window.title = ""
        window.titlebarAppearsTransparent = true
        window.styleMask = [.fullSizeContentView, .borderless, .titled]
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
        let dict = NSDictionary(contentsOfFile: infoListFile.absoluteString) as! [String: AnyObject]

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
