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
    @IBOutlet weak var imageView: NSImageView!
    
    var path: URL
    
    // Questions and answers
    var qaas: [NSDictionary] = []
    var questionIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showQuestion()
    }
    
    @IBAction func shareFile(_ sender: NSButton) {
        let newURL = "\(path)/"
        let shareItems = [NSURL(fileURLWithPath: newURL)]
        NSSharingService.shareSocialData(content: shareItems, button: sender)
    }
        
    func reloadData() {
        qaas.shuffle()
        questionIndex = 0
    }
    
    func showQuestion() {
        hideAnswer()
        
        guard questionIndex < qaas.count else {
            restart()
            return
        }

        let question = qaas[questionIndex]
        questionLabel.stringValue = question.object(forKey: "question") as! String
        answerLabel.stringValue = question.object(forKey: "answer") as! String
        
        if let image = question.object(forKey: "image") as? String {
            imageView.image = NSImage(contentsOfFile: image)
        } else {
            imageView.image = nil
        }

        
        questionIndex += 1
    }
    
    func showAnswer() {
        answerLabel.isHidden = false
        imageView.isHidden = false
    }
    
    func hideAnswer() {
        answerLabel.isHidden = true
        imageView.isHidden = true
    }
    
    func restart() {
        showAnswer()
        
        questionLabel.textColor = .green
        answerLabel.textColor = .green
        
        questionLabel.stringValue = "Finished Quiz"
        answerLabel.stringValue = "Shuffling Questions..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.questionLabel.textColor = .labelColor
            self.answerLabel.textColor = .labelColor
            
            self.reloadData()
            self.showQuestion()
        }
    }
    
    init(fileURL: URL) {
        self.path = fileURL
        super.init(nibName: "QCPresenterViewController", bundle: nil)
        
        let infoListFile = path.appendingPathComponent("card.plist")
        let dict = NSDictionary(contentsOfFile: infoListFile.absoluteString) as! [String: AnyObject]
        self.qaas = dict["questions and answers"] as! [NSDictionary]
        qaas.shuffle()
    }
    
    @IBAction func seeAnswer(_ sender: Any) {
        showAnswer()
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.view.window?.close()
    }
    
    @IBAction func choseNext(_ sender: Any) {
        showQuestion()
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
