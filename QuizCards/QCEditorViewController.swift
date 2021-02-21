//
//  QCEditorViewController.swift
//  QuizCards
//
//  Created by Ashwin Paudel on 2021-02-20.
//

import Cocoa

class QCEditorViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var tableView: NSTableView!
    var path = URL(string: "")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.delegate = self
        tableView.dataSource = self
    }
    @IBAction func addButton(_ sender: Any) {
        let infoListFile = path?.appendingPathComponent("card.plist")
//        let cell = sender
        let dict = NSDictionary(contentsOfFile: infoListFile!.absoluteString) as! NSDictionary
//        let cell = tableView.selectedCell() as? QCEditorTableCellView
        var QCName = dict["questions and answers"] as? [NSMutableDictionary]
        
        let newObject = NSMutableDictionary()
        newObject.setValue("\"Answer\"" as? String, forKey: "answer")
        newObject.setValue("\"Question\"" as? String, forKey: "question")
//        print(NSMutableDictionary().setValue("Answer", forKey: "answer"))
        print("look above")
        print(QCName)

        QCName?.append(newObject)
        print("look bellow")

        print(QCName)
        
        //        writePlistFile(infoListFile!, "question", data: "test")
        
        dict.write(toFile: infoListFile!.absoluteString, atomically: true)
        do {
            try dict.write(to: infoListFile!)
            
        } catch {
            print("adsfkjadsnfkjasndfkjasndfkjasndfkjsnckadsjnrvriuh8")
            print(error.localizedDescription)

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
        cell.QCSaveButton.action = #selector(saveBTN)
        return cell
    }
    @objc func saveBTN(_ sender: QCEditorTableCellView) {
        print("dsafasdf")
        let infoListFile = path?.appendingPathComponent("card.plist")
//        let cell = sender
        let cell = tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: true) as? QCEditorTableCellView
        
        let dict = NSDictionary(contentsOfFile: infoListFile!.absoluteString) as! NSDictionary
//        let cell = tableView.selectedCell() as? QCEditorTableCellView
          let QCName = dict["questions and answers"] as? [NSMutableDictionary]
        QCName?[tableView.selectedRow].setValue(cell!.QCQuestionTextField.stringValue, forKey: "question")
        QCName?[tableView.selectedRow].setValue(cell!.QCAnswerTextField.stringValue, forKey: "answer")
//        writePlistFile(infoListFile!, "question", data: "test")
        
        do {
            let sdfads = try! dict.write(toFile: infoListFile!.absoluteString, atomically: true)
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

