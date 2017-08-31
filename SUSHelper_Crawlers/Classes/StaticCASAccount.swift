//
//  StaticCASAccount.swift
//  Pods
//
//  Created by 谢宜 on 2017/8/31.
//
//

import Foundation

/// Instance CAS Account
open class StaticCASAccount {
    
    open var stuid = ""
    open var password = ""
    
    /// Login CAS
    ///
    /// - Parameter callback: Async callback
    open func login(_ callback: @escaping (String) -> Void) {
        debugPrint("Login cas with \(stuid)")
        if stuid == CAS_Demo_Account {
            if password == CAS_DEMO_Password {
                Demo_Mode = true
                callback("success")
                return
            } else {
                Demo_Mode = false
                callback("wrongpassword")
                return
            }
        }
        Demo_Mode = false
        CASSession(stuid: stuid, password: password).login(callback)
    }
    
    /// Logout CAS
    ///
    /// - Parameter callback: Async callback
    open func logout(_ callback: @escaping (String) -> Void) {
        if !Demo_Mode {
            CASSession(stuid: stuid, password: password).logout(callback)
        }
    }
    
}
