//
//  CustomAlamofire.swift
//  sushelper
//
//  Created by xieyi on 2017/8/8.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import Alamofire

/// Track all requests of Alamofire
open class MyAlamofire {
    
    open static var shared: SessionManager? = nil
    
    open static var requests: [Request?] = []
    
    /// Call this before all requests
    open static func initialize() {
        let conf = URLSessionConfiguration.default
        conf.timeoutIntervalForResource = 30
        conf.timeoutIntervalForRequest = 30
        shared = SessionManager(configuration: conf, delegate: SessionDelegate(), serverTrustPolicyManager: nil)
    }
    
    /// Cancel all requests.
    /// Call this after a view disappears to prevent bugs.
    open static func cancelAll() {
        debugPrint("Cancel all requests")
        for request in requests {
            if request != nil {
                request?.cancel()
            }
        }
        requests = []
    }
    
}
