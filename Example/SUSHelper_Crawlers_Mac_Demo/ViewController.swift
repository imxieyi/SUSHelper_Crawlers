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
    
    let grades: [Grade] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Load Demo Account
        account.stringValue = "00000000"
        password.stringValue = "0ava0k"
    }

    @IBAction func runpressed(_ sender: Any) {
        
    }
    
}
