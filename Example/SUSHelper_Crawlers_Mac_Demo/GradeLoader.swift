//
//  GradeLoader.swift
//  SUSHelper_Crawlers
//
//  Created by xieyi on 2017/8/31.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import SUSHelper_Crawlers
import Async

/// Load grades into string
///
/// - Parameters:
///   - account: CAS Account
///   - password: CAS Password
///   - callback: Async Callback Function
///   - status: Status of the callback
///   - result: Result string or empty
func load_grades(_ account: String, _ password: String, _ callback: @escaping (_ status: String, _ result: String) -> Void) {
    var semesters: [String] = []
    ViewController.instance?.semaphore.wait()
    callback("out", "Auth CAS with \(account)...")
    let account = StaticCASAccount(account, password)
    account.login { ret in
        Async.background {
            guard ret == "success" else {
                ViewController.instance?.semaphore.wait()
                callback("error", "cannot login")
                return
            }
            //Get semester table
            GradeHelper.getsemesters { table in
                Async.background {
                    if table.count < 2 {
                        ViewController.instance?.semaphore.wait()
                        callback("error", "no semester")
                        return
                    }
                    if table[0] == "error" {
                        ViewController.instance?.semaphore.wait()
                        callback("error", table[1])
                        return
                    }
                    for item in table {
                        semesters.append(item)
                        ViewController.instance?.semaphore.wait()
                        callback("out", "Got semester \(item)")
                    }
                    ViewController.instance?.semaphore.wait()
                    callback("out", "\n")
                    semesters.sort(by: { (a, b) -> Bool in
                        return a < b
                    })
                    let sp = DispatchSemaphore(value: 1)
                    for item in semesters {
                        sp.wait()
                        //Get grades
                        GradeHelper.getgrades(item) { stat, grades in
                            Async.background {
                                guard stat[0] == "success" else {
                                    ViewController.instance?.semaphore.wait()
                                    callback("error", stat[1])
                                    return
                                }
                                for grade in grades {
                                    ViewController.instance?.semaphore.wait()
                                    callback("out", grade.description + "\n")
                                    ViewController.instance?.semaphore.wait()
                                    callback("out", "\n")
                                }
                                sp.signal()
                                if item == (semesters.last)! {
                                    ViewController.instance?.semaphore.wait()
                                    callback("success", "")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
