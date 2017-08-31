//
//  CASSession.swift
//  sushelper
//
//  Created by xieyi on 2017/8/4.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

/// Simulate CAS login
open class CASSession {
    
    private let cas_url = "https://cas.sustc.edu.cn/cas/login?service=http%3A%2F%2Fjwxt.sustc.edu.cn%2Fjsxsd%2F"
    private let logout_url = "https://cas.sustc.edu.cn/cas/logout"
    private let headers: HTTPHeaders = [
        ://"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
    ]
    
    private let stuid:String
    private let password:String
    
    public init(stuid:String, password:String) {
        self.stuid = stuid
        self.password = password
    }
    
    /// Login current account
    ///
    /// - Parameter callback: Async callback
    open func login(_ callback: @escaping (String) -> Void) {
        load_cas(callback)
    }
    
    /// Logout. You don't really need to wait for the callback.
    ///
    /// - Parameter callback: Async callback
    open func logout(_ callback: @escaping (String) -> Void) {
        var cas_html:String? = nil
        let request = MyAlamofire.shared?.request(logout_url, headers: headers).responseData(completionHandler: { response in
            switch response.result {
            case .success:
                cas_html = String(data: response.data!, encoding: .utf8)
                guard cas_html != nil else {
                    callback("Empty response")
                    return
                }
                guard (cas_html?.lengthOfBytes(using: .utf8))! > 0 else {
                    callback("Empty response")
                    return
                }
                if (cas_html?.contains("success"))! {
                    callback("success")
                    return
                } else {
                    callback(cas_html!)
                }
                break
            case .failure(let error):
                debugPrint(error)
                callback(error.localizedDescription)
            }
        })
        MyAlamofire.requests.append(request)
    }
    
    /// Load cas page to get several parameters.
    ///
    /// - Parameter callback: Async callback
    private func load_cas(_ callback: @escaping (String) -> Void) {
        var cas_html:String? = nil
        let request = MyAlamofire.shared?.request(cas_url, headers: headers).responseData(completionHandler: { response in
            switch response.result {
            case .success:
                cas_html = String(data: response.data!, encoding: .utf8)
                guard cas_html != nil else {
                    callback("Empty response")
                    return
                }
                //Already logged in
                //It would be fucked off if it is changed to "弱智科技".
                if (cas_html?.contains("强智科技"))! {
                    callback("success")
                    return
                }
                let doc = HTML(html: cas_html!, encoding: .utf8)
                let lt = doc?.xpath("//input[@name=\"lt\"]").first?["value"]
                let execution = doc?.xpath("//input[@name=\"execution\"]").first?["value"]
                let _eventId = doc?.xpath("//input[@name=\"_eventId\"]").first?["value"]
                let submit = doc?.xpath("//input[@name=\"submit\"]").first?["value"]
                guard lt != nil else {
                    callback("lt is empty!")
                    return
                }
                guard execution != nil else {
                    callback("execution is empty!")
                    return
                }
                guard _eventId != nil else {
                    callback("_eventId is empty!")
                    return
                }
                guard submit != nil else {
                    callback("submit is empty!")
                    return
                }
                self.auth_cas(lt!, execution!, _eventId!, submit!, callback)
                break
            case .failure(let error):
                debugPrint(error)
                callback(error.localizedDescription)
            }
        })
        MyAlamofire.requests.append(request)
    }
    
    /// Auth with cas.
    ///
    /// - Parameters:
    ///   - lt: Ask developer of CAS system.
    ///   - execution: Ask developer of CAS system.
    ///   - _eventId: Ask developer of CAS system.
    ///   - submit: Ask developer of CAS system.
    ///   - callback: Async callback
    private func auth_cas(_ lt:String, _ execution:String, _ _eventId:String, _ submit:String, _ callback: @escaping (String) -> Void) {
        let poststr = "username=\(stuid)&password=\(password)&lt=\(lt)&execution=\(execution)&_eventId=\(_eventId)&submit=%E7%99%BB%E5%BD%95"
        let request = MyAlamofire.shared?.upload(poststr.data(using: .utf8)!, to: cas_url, method: .post, headers: headers).responseString(completionHandler: {response in
            switch response.result {
            case .success:
                let html = String(data: response.data!, encoding: .utf8)
                guard html != nil else {
                    callback("Empty response")
                    return
                }
                //It would also be fucked off if it is changed to "弱智科技".
                if (html?.contains("强智科技"))! {
                    callback("success")
                    return
                } else {
                    callback(html!)
                    return
                }
            case .failure(let error):
                debugPrint(error)
                callback(error.localizedDescription)
            }
        })
        MyAlamofire.requests.append(request)
    }
    
}
