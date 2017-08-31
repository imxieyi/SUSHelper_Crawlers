//
//  CustomAlamofire.swift
//  sushelper
//
//  Created by xieyi on 2017/8/8.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import Alamofire

class MyAlamofire {
    
    static var shared: SessionManager? = nil
    
    static var requests: [Request?] = []
    
    static func initialize() {
        let conf = URLSessionConfiguration.default
        conf.timeoutIntervalForResource = 30
        conf.timeoutIntervalForRequest = 30
        shared = SessionManager(configuration: conf, delegate: SessionDelegate(), serverTrustPolicyManager: nil)
    }
    
    static func cancelAll() {
        debugPrint("Cancel all requests")
        for request in requests {
            if request != nil {
                request?.cancel()
            }
        }
        requests = []
    }
    
}
