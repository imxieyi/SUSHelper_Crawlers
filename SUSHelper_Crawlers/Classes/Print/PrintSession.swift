//
//  PrintSession.swift
//  sushelper
//
//  Created by xieyi on 2017/8/13.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

let pms_service_url = "http://pms.sustc.edu.cn/Service.asmx"
let pms_print_station_query_url = "http://pms.sustc.edu.cn/Service.asmx/GetDevices"
let pms_print_job_query_url = "http://pms.sustc.edu.cn/Service.asmx/GetPrintJob"
let pms_print_job_set_url = "http://pms.sustc.edu.cn/Service.asmx/SetPrintJob"

let pms_test_private_logged_url = "http://pms.sustc.edu.cn/Service.asmx/CheckSession"

let pms_upload_file_url_format = "http://pms.sustc.edu.cn/upload.aspx?sid=%@"

let pms_session_request_body = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" ><soap:Body><InitSession xmlns=\"http://tempuri.org/\"><bstrPCName></bstrPCName></InitSession></soap:Body></soap:Envelope>"

let pms_private_login_body_format = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" ><soap:Body><Login xmlns=\"http://tempuri.org/\"><bstrSessionID>%@</bstrSessionID><bstrUserName>%@</bstrUserName><bstrPassword>%@</bstrPassword></Login></soap:Body></soap:Envelope>"

var pms_session = ""
fileprivate var pms_account = ""

let pms_test_public_login_url = "http://pms.sustc.edu.cn/Service.asmx/GetDevices"

/// Login Unifound print management system
open class PrintSession {

    static let headers: HTTPHeaders = [
        ://"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
    ]
    
    /// Get a session number
    ///
    /// - Parameter callback: Async callback
    static func pms_public_login(_ callback: @escaping (String) -> Void) {
        var query_headers = headers
        query_headers["SOAPAction"] = "\"http://tempuri.org/InitSession\""
        query_headers["Content-Type"] = "text/xml; charset=UTF-8"
        let request = MyAlamofire.shared?.upload(pms_session_request_body.data(using: .utf8)!, to: pms_service_url, headers: query_headers).responseData { response in
            switch response.result {
            case .success:
                guard response.data != nil else {
                    callback("Empty response")
                    return
                }
                let xml = XML(xml: response.data!, encoding: .utf8)
                guard let session = xml?.xpath("/").first?.text else {
                    callback("Session number not found!")
                    return
                }
                debugPrint("Got session number: \(session)")
                guard session.contains("ok") else {
                    callback("Session number not found!")
                    return
                }
                pms_session = session.subStringAfter(",")
                callback("success")
                break
            case .failure(let error):
                debugPrint(error)
                callback(error.localizedDescription)
            }
        }
        MyAlamofire.requests.append(request)
    }
    
    /// Login with username and password
    ///
    /// - Parameters:
    ///   - username: Unifound account
    ///   - password: Unifound password
    ///   - callback: Async callback
    static func pms_private_login(_ username: String, _ password: String, _ callback: @escaping (String) -> Void) {
        debugPrint("Logging in pms with username \(username)")
        let body = String(format: pms_private_login_body_format, pms_session, username, password)
        var login_headers = headers
        login_headers["SOAPAction"] = "\"http://tempuri.org/Login\""
        login_headers["Content-Type"] = "text/xml; charset=UTF-8"
        let request = MyAlamofire.shared?.upload(body.data(using: .utf8)!, to: pms_service_url, method: .post, headers: login_headers).responseData { response in
            switch response.result {
            case .success:
                guard response.data != nil else {
                    callback("Empty response")
                    return
                }
                if let str = String(data: response.data!, encoding: .utf8) {
                    if str.contains("ok") {
                        callback("success")
                    } else {
                        if str.contains("fail") {
                            callback("wrongpassword")
                        } else {
                            callback(str)
                        }
                    }
                } else {
                    callback("Empty response")
                    return
                }
                break
            case .failure(let error):
                debugPrint(error)
                callback(error.localizedDescription)
            }
        }
        MyAlamofire.requests.append(request)
    }
    
    /// Test if this private session is already logged in
    ///
    /// - Parameter callback: Async callback
    static func pms_test_private_session(_ callback: @escaping (String) -> Void) {
        let body = "{\"bstrSessionID\": \"\(pms_session)\"}"
        var check_headers = headers
        check_headers["Content-Type"] = "application/json"
        check_headers["X-Requested-With"] = "XMLHttpRequest"
        let request = MyAlamofire.shared?.upload(body.data(using: .utf8)!, to: pms_test_private_logged_url, method: .post, headers: check_headers).responseData { response in
            switch response.result {
            case .success:
                guard response.data != nil else {
                    callback("Empty response")
                    return
                }
                if let str = String(data: response.data!, encoding: .utf8) {
                    if str.contains("true") {
                        callback("success")
                    } else {
                        callback("fail")
                    }
                } else {
                    callback("Empty response")
                    return
                }
                break
            case .failure(let error):
                debugPrint(error)
                callback(error.localizedDescription)
            }
        }
        MyAlamofire.requests.append(request)
    }
    
    /// Auto detect login status and then login
    ///
    /// - Parameters:
    ///   - username: Unifound print account
    ///   - password: Unifound print password
    ///   - callback: Async callback
    open static func pms_login(_ username: String, _ password: String, _ callback: @escaping (String) -> Void) {
        if pms_account != username {
            pms_session = ""
        }
        //Maybe logged in?
        if pms_session != "" {
            let requestjson = "{\"bstrSessionID\": \"\(pms_session)\"}"
            var check_headers = headers
            check_headers["X-Requested-With"] = "XMLHttpRequest"
            check_headers["Content-Type"] = "application/json"
            let request = MyAlamofire.shared?.upload(requestjson.data(using: .utf8)!, to: pms_test_public_login_url, headers: check_headers).responseData { response in
                switch response.result {
                case .success:
                    guard response.data != nil else {
                        callback("Empty response")
                        return
                    }
                    if let str = String(data: response.data!, encoding: .utf8) {
                        if str.contains("SessionOut") {
                            //Not logged in or expired
                            pms_public_login { ret in
                                if ret == "success" {
                                    pms_private_login(username, password) { ret in
                                        callback(ret)
                                    }
                                } else {
                                    callback(ret)
                                }
                            }
                        } else {
                            //Already publicly logged in
                            debugPrint("Already has session number")
                            pms_test_private_session { ret in
                                if ret == "success" {
                                    //Logged in
                                    debugPrint("Already logged in")
                                    callback("success")
                                } else {
                                    if ret == "fail" {
                                        //Not logged in or expired
                                        pms_public_login { ret in
                                            if ret == "success" {
                                                pms_private_login(username, password) { ret in
                                                    callback(ret)
                                                    if ret == "success" {
                                                        pms_account = username
                                                    }
                                                }
                                            } else {
                                                callback(ret)
                                            }
                                        }
                                    } else {
                                        //Error occurred
                                        callback(ret)
                                    }
                                }
                            }
                        }
                    } else {
                        callback("Empty response")
                        return
                    }
                    break
                case .failure(let error):
                    debugPrint(error)
                    callback(error.localizedDescription)
                }
            }
            MyAlamofire.requests.append(request)
        } else {
            //Login in from scratch
            pms_public_login { ret in
                if ret == "success" {
                    pms_private_login(username, password) { ret in
                        callback(ret)
                        if ret == "success" {
                            pms_account = username
                        }
                    }
                } else {
                    callback(ret)
                }
            }
        }
    }
    
}
