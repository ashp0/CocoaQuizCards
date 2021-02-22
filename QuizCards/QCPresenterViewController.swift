//
//  QCPresenterViewController.swift
//  QuizCards
//
//  Created by Ashwin Paudel on 2021-02-20.
//

import Cocoa

class QCPresenterViewController: NSViewController, NSSharingServiceDelegate {

    @IBOutlet weak var questionLabel: NSTextField!
    
    @IBOutlet weak var answerLabel: NSTextField!
    
    var path = URL(string: "sfds")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
        // Do view setup here.
    }
    @IBAction func shareFile(_ sender: NSButton) {
        let newURL = "\(path!)/"
        let shareItems = [NSURL(fileURLWithPath: newURL)]
//        let service = NSSharingService(named: .composeMessage)
//        service?.delegate = self
////        service?.recipients = ["/tim.cook@apple.com"]
//        service?.subject = "\(NSLocalizedString("Re: Requested PDF", comment: ""))"
//
////        var sdfasd = URL(string: "")
//        service?.perform(withItems: shareItems)
        
                NSSharingService.shareSocialData(content: shareItems, button: sender)
    }

//    override var acceptsFirstResponder: Bool { get { return true } }

    func reloadData() {
        answerLabel.isHidden = true

        
        let infoListFile = path?.appendingPathComponent("card.plist")
        
        let dict = NSDictionary(contentsOfFile: infoListFile!.absoluteString) as! [String: AnyObject]

          if let QCName = dict["questions and answers"] as? [NSDictionary] {
               print("Info.plist : \(QCName)")
            let randomElement = QCName.randomElement()

            print(QCName[0].object(forKey: "question"))
            questionLabel.stringValue = randomElement!.object(forKey: "question") as! String
            answerLabel.stringValue = randomElement!.object(forKey: "answer") as! String

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
extension NSSharingService {
class func shareSocialData ( content: [AnyObject], button: NSButton ) {
    let sharingServicePicker = NSSharingServicePicker (items: content )

    sharingServicePicker.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.maxX)
}
}
