//
//  QCPresenterViewController.swift
//  QuizCards
//
//  Created by Ashwin Paudel on 2021-02-20.
//

import Cocoa

class QCPresenterViewController: NSViewController {

    @IBOutlet weak var questionLabel: NSTextField!
    
    @IBOutlet weak var answerLabel: NSTextField!
    
    var path = URL(string: "sfds")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
        // Do view setup here.
    }
    func reloadData() {
        answerLabel.isHidden = true

        let infoListFile = path?.appendingPathComponent("card.plist")
        
        let dict = NSDictionary(contentsOfFile: infoListFile!.absoluteString) as! [String: AnyObject]

          if let QCName = dict["questions and answers"] as? [NSDictionary] {
               print("Info.plist : \(QCName)")
            print(QCName[0].object(forKey: "question"))
            questionLabel.stringValue = QCName.randomElement()?.object(forKey: "question") as! String
            answerLabel.stringValue = QCName.randomElement()?.object(forKey: "answer") as! String

            //                QCName[0].object(forKey: "question") as! String
            
          }
        
    }
    init(fileURL: URL?) {
        super.init(nibName: "QCPresenterViewController", bundle: nil)
        self.path = fileURL
    }
    @IBAction func seeAnswer(_ sender: Any) {
        answerLabel.isHidden = false
        
    }
    @IBAction func closeButton(_ sender: Any) {
        self.view.window?.close()
    }
    @IBAction func choseNext(_ sender: Any) {
        reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
