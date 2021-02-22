//
//  QCEditorViewController.swift
//  QuizCards
//
//  Created by Ashwin Paudel on 2021-02-20.
//

import Cocoa

class QCEditorViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {

    @IBOutlet weak var cardNameTextField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    var path = URL(string: "")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.delegate = self
        tableView.dataSource = self
        let infoListFile = path?.appendingPathComponent("card.plist")
        let dict = NSDictionary(contentsOfFile: infoListFile!.absoluteString) as! NSMutableDictionary
        var QCName = dict["name"] as? String

        cardNameTextField.stringValue = QCName!
        cardNameTextField.delegate = self
    }
    func writeDictionary(toPlist plistDict: NSDictionary) -> Bool {
        let infoListFile = path!.appendingPathComponent("card.plist")
        let filePath = infoListFile.absoluteString
        let result = (plistDict as NSDictionary?)?.write(toFile: filePath, atomically: true) ?? false
        return result
    }
    @IBAction func deleteButton(_ sender: Any) {
        let infoListFile = path?.appendingPathComponent("card.plist")
        let dict = NSDictionary(contentsOfFile: infoListFile!.absoluteString) as! NSMutableDictionary
        var QCName = dict["questions and answers"] as? [NSMutableDictionary]
        
        QCName?.remove(at: tableView.selectedRow)
//        print(QCName)
//        print("adsfadfladf")
        dict.setObject(QCName, forKey: "questions and answers" as NSCopying)
        print(dict)
        do {
            if infoListFile?.absoluteString.hasPrefix("file:///") == true {
                let url = URL(string: "\(infoListFile!.absoluteString)")
                try dict.write(to: url!)
                print("successfully written data")
                tableView.reloadData()
            } else {
            let url = URL(string: "file://\(infoListFile!.absoluteString)")
            try dict.write(to: url!)
            print("successfully written data")
            tableView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
            print(infoListFile)
        }
    }
   
    @IBOutlet weak var deleteBTNOutlet: NSButton!
    @IBAction func saveButtonAction(_ sender: Any) {
        saveBTN()
    }
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if tableView.isHighlighted != true {
            deleteBTNOutlet.isEnabled = true
        } else {
            deleteBTNOutlet.isEnabled = false
        }
        return true

    }
    
    @IBAction func addButton(_ sender: Any) {
        let infoListFile = path?.appendingPathComponent("card.plist")
        let dict = NSDictionary(contentsOfFile: infoListFile!.absoluteString) as! NSMutableDictionary
        var QCName = dict["questions and answers"] as? [NSMutableDictionary]
        let newObject = NSMutableDictionary()
        newObject.setValue("Answer" as? String, forKey: "answer")
        newObject.setValue("Question" as? String, forKey: "question")
        QCName?.append(newObject)
        print(QCName)
        print("adsfadfladf")
        dict.setObject(QCName, forKey: "questions and answers" as NSCopying)
        print(dict)
        do {
            if infoListFile?.absoluteString.hasPrefix("file:///") == true {
                let url = URL(string: "\(infoListFile!.absoluteString)")
                try dict.write(to: url!)
                print("successfully written data")
                tableView.reloadData()
            } else {
            let url = URL(string: "file://\(infoListFile!.absoluteString)")
            try dict.write(to: url!)
            print("successfully written data")
            tableView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
            print(infoListFile)
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let infoListFile = path?.appendingPathComponent("card.plist")
        
        let dict = NSDictionary(contentsOfFile: infoListFile!.absoluteString) as! [String: AnyObject]

          let QCName = dict["questions and answers"] as? [NSDictionary]
        return QCName!.count
            
        
    }
    @IBAction func closeBTN(_ sender: Any) {
        self.view.window?.close()
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "qcedtiorlistview"), owner: self) as? QCEditorTableCellView else { return nil }
        
        let infoListFile = path?.appendingPathComponent("card.plist")
        
        let dict = NSDictionary(contentsOfFile: infoListFile!.absoluteString) as! [String: AnyObject]

          let QCName = dict["questions and answers"] as? [NSMutableDictionary]
        
        cell.QCQuestionTextField.stringValue = QCName?[row].object(forKey: "question") as! String
        cell.QCAnswerTextField.stringValue = QCName?[row].object(forKey: "answer") as! String
        cell.QCAnswerTextField.delegate = self
        cell.QCQuestionTextField.delegate = self
//        cell.QCSaveButton.action = #selector(saveBTN)
        return cell
    }
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        saveBTN()
        return true
    }
    
    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        saveBTN()
        return true
    }
    func controlTextDidBeginEditing(_ obj: Notification) {
        saveBTN()
    }
    func controlTextDidChange(_ obj: Notification) {
        saveBTN()
    }
    func controlTextDidEndEditing(_ obj: Notification) {
        saveBTN()
    }
    @objc func saveBTN() {
        print("dsafasdf")
        let infoListFile = path?.appendingPathComponent("card.plist")
//        let cell = sender
        let cell = tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: true) as? QCEditorTableCellView
        
        let dict = NSDictionary(contentsOfFile: infoListFile!.absoluteString) as! NSDictionary
//        let cell = tableView.selectedCell() as? QCEditorTableCellView
          let QCName = dict["questions and answers"] as? [NSMutableDictionary]
        let QCNamee = dict["name"] as? String

        dict.setValue(cardNameTextField.stringValue, forKey: "name")
        
        QCName?[tableView.selectedRow].setValue(cell!.QCQuestionTextField.stringValue, forKey: "question")
        QCName?[tableView.selectedRow].setValue(cell!.QCAnswerTextField.stringValue, forKey: "answer")
//        writePlistFile(infoListFile!, "question", data: "test")
        
        do {
            let sdfads = try! dict.write(toFile: infoListFile!.absoluteString, atomically: true)
            try! dict.write(toFile: infoListFile!.absoluteString, atomically: true)
//            try! dict.write(to: infoListFile!)
            try! dict.write(to: infoListFile!, atomically: true)

            if sdfads == true {
            print("dsasadfalnsdflkasdnfasdf")
            }
        } catch {
            print("adsfkjadsnfkjasndfkjasndfkjasndfkjsnckadsjnrvriuh8")
            print(error.localizedDescription)

        }
    }
    init(fileURL: URL?) {
        super.init(nibName: "QCEditorViewController", bundle: nil)
        self.path = fileURL
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public func writePlistFile(_ name: String, _ key: String, data: Any) {
    let dataDir = QCDataDir()?.appendingPathComponent("\(name).plist")
    if let dict = NSMutableDictionary(contentsOf: dataDir!) {
        dict.setObject(data, forKey: key as NSCopying)
        if dict.write(toFile: dataDir!.absoluteString, atomically: true) {
            print("sucsess")
        }
    }
}
public func writePlistFile(_ url: URL, _ key: String, data: Any) {
    let dataDir = url
    if let dict = NSMutableDictionary(contentsOf: dataDir) {
        dict.setObject(data, forKey: key as NSCopying)
        if dict.write(toFile: dataDir.absoluteString, atomically: true) {
            print("sucsess")
        }
    }
}

