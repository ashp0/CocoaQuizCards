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
    @IBOutlet weak var deleteBTNOutlet: NSButton!
    
    var path = URL(string: "")
    var cardData: NSMutableDictionary
    var infoListFile: URL
    
    // Access the proper item in the getCards() function
    var index: Int
    private var previouslySelectedCell: QCEditorTableCellView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dict = NSDictionary(contentsOfFile: infoListFile.absoluteString) as! NSMutableDictionary
        cardData = dict
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let flashDeckTitle = cardData["name"] as? String {
            cardNameTextField.stringValue = flashDeckTitle
        }
        
        tableView.reloadData()
        cardNameTextField.delegate = self
    }
    
    override func viewWillAppear() {
        if previouslySelectedCell == nil, let cell = tableView.view(atColumn: tableView.selectedColumn, row: tableView.selectedRow, makeIfNecessary: false) as? QCEditorTableCellView {
            previouslySelectedCell = cell
            cell.isSelected = true
        }
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        var questions = cardData["questions and answers"] as! [NSMutableDictionary]
        questions.remove(at: tableView.selectedRow)
        
        cardData.setObject(questions, forKey: "questions and answers" as NSCopying)
        
        saveBTN()
        tableView.reloadData()
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
        var questions = cardData["questions and answers"] as? [NSMutableDictionary]
        
        let newObject = NSMutableDictionary()
        newObject.setValue("Answer", forKey: "answer")
        newObject.setValue("Question", forKey: "question")
        questions?.append(newObject)
        
        cardData.setObject(questions!, forKey: "questions and answers" as NSCopying)
        
        saveBTN()
        tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let questions = cardData["questions and answers"] as? [NSMutableDictionary]
        return questions!.count
    }
    
    @IBAction func closeBTN(_ sender: Any) {
        // Save the cardData to the file
        cardData.write(toFile: infoListFile.absoluteString, atomically: true)
        cardData.write(toFile: infoListFile.absoluteString, atomically: true)
        cardData.write(to: infoListFile, atomically: true)
        
        
        // Close window
        self.view.window?.close()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let cell = tableView.view(atColumn: tableView.selectedColumn, row: tableView.selectedRow, makeIfNecessary: false) as? QCEditorTableCellView {
            previouslySelectedCell?.isSelected = false
            previouslySelectedCell = cell
            previouslySelectedCell!.isSelected = true
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "qcedtiorlistview"), owner: self) as? QCEditorTableCellView else { return nil }
        
        let questions = cardData["questions and answers"] as? [NSMutableDictionary]
        
        cell.QCQuestionTextField.stringValue = questions?[row].object(forKey: "question") as! String
        cell.QCAnswerTextField.stringValue = questions?[row].object(forKey: "answer") as! String
        cell.QCAnswerTextField.delegate = self
        cell.QCQuestionTextField.delegate = self
        cell.QCImageButton.action = #selector(uploadImage)
        
        if let image = questions?[row].object(forKey: "image") as? String {
            cell.QCImageButton.image = NSImage(contentsOfFile: image)
        }
        
        return cell
    }
    
    @objc func uploadImage() {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["public.image"]
        openPanel.allowsMultipleSelection = false
        
        openPanel.begin { [self] (response) in
            if response == .OK, let fileURL = openPanel.url {
                self.duplicateImage(to: fileURL)
                
                let newFile = fileURL.absoluteString.replacingOccurrences(of: "file://", with: "")
                let questions = cardData["questions and answers"] as? [NSMutableDictionary]
                questions?[tableView.selectedRow].setValue(newFile, forKey: "image")
                
                cardData.setObject(questions!, forKey: "questions and answers" as NSCopying)
                tableView.reloadData()
            }
        }
    }
    
    func duplicateImage(to sourceURL: URL) {
        do {
            let fileManager = FileManager.default
            
            // Create the destination folder if it doesn't exist
            
            let filePath = "file://" + self.path!.absoluteString
            let filePathURL = URL(string: filePath)!
            
            let contentsURL = filePathURL.appendingPathComponent("Contents")
            try fileManager.createDirectory(at: contentsURL, withIntermediateDirectories: true, attributes: nil)
            
            // Create a destination URL for the duplicated image
            let destinationURL = contentsURL.appendingPathComponent(sourceURL.lastPathComponent)
            
            // Duplicate the image file
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        } catch {
            print("Error duplicating image: \(error.localizedDescription)")
        }
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
        let cell = tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: true) as? QCEditorTableCellView
        
        let questions = cardData["questions and answers"] as? [NSMutableDictionary]
        
        cardData.setValue(cardNameTextField.stringValue, forKey: "name")
        
        // Update the name on the plist file
        updateName()
        
        questions?[tableView.selectedRow].setValue(cell!.QCQuestionTextField.stringValue, forKey: "question")
        questions?[tableView.selectedRow].setValue(cell!.QCAnswerTextField.stringValue, forKey: "answer")
    }
    
    func updateName() {
        guard var cards = getCards(), index != -1 else { return }
        cards.root[index].name = cardNameTextField.stringValue
        
        let pListFilURL = QCDataDir()?.appendingPathComponent("cards.plist")
        
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        do {
            let data = try encoder.encode(cards)
            try data.write(to: pListFilURL!)
        } catch {
            print("[Editor] updateName()", error.localizedDescription)
        }
    }
    
    init(fileURL: URL?, _ index: Int = -1) {
        self.path = fileURL
        self.index = index
        self.infoListFile = fileURL!.appendingPathComponent("card.plist")
        
        cardData = .init()
        super.init(nibName: "QCEditorViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
