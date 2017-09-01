//
//  ViewController.swift
//  SUSHelper_Crawlers_Mac_Demo
//
//  Created by 谢宜 on 2017/8/31.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Cocoa
import SUSHelper_Crawlers
import Async

class ViewController: NSViewController {

    @IBOutlet var account: NSTextField!
    @IBOutlet var password: NSSecureTextField!
    @IBOutlet var funcselect: NSComboBox!
    
    @IBOutlet var textview: NSTextView!
    @IBOutlet var button: NSButton!
    
    static var instance: ViewController? = nil
    
    let grades: [Grade] = []
    
    let semaphore = DispatchSemaphore(value: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewController.instance = self
        MyAlamofire.initialize()
        //Load Demo Account
        account.stringValue = "00000000"
        password.stringValue = "0ava0k"
    }
    
    override func viewDidDisappear() {
        MyAlamofire.cancelAll()
        ViewController.instance = nil
    }

    @IBAction func runpressed(_ sender: Any) {
        button.isEnabled = false
        textview.string = ""
        load_grades(account.stringValue, password.stringValue) { stat, result in
            Async.main {
                switch stat {
                case "out":
                    (self.textview.string)! += result + "\n"
                    self.textview.scrollToEndOfDocument(self.textview)
                case "success":
                    self.button.isEnabled = true
                    (self.textview.string)! += "Finished!"
                    self.textview.scrollToEndOfDocument(self.textview)
                case "error":
                    self.button.isEnabled = true
                    (self.textview.string)! += "Error: " + result + "\n"
                    self.textview.scrollToEndOfDocument(self.textview)
                default:
                    //Should never reach here
                    break
                }
                self.semaphore.signal()
            }
        }
    }
    
}
