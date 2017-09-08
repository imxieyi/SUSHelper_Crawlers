//
//  PrintJobs.swift
//  sushelper
//
//  Created by xieyi on 2017/8/14.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Kanna

/// Actions of existing print jobs
open class PrintJobs {
    
    /// Custom headers of all requests
    static let headers: HTTPHeaders = [
        ://"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
    ]
    
    /// Login and query all print jobs
    ///
    /// - Parameters:
    ///   - username: Unifound account
    ///   - password: Unifound password
    ///   - callback: Async callback
    open static func query(_ username: String, _ password: String, _ callback: @escaping (String, [PrintJob]) -> Void) {
        PrintSession.pms_login(username, password) { ret in
            if ret == "success" {
                query_main(callback)
            } else {
                callback(ret, [])
            }
        }
    }
    
    /// Delete print job of a given job id
    ///
    /// - Parameters:
    ///   - username: Unifound account
    ///   - password: Unifound password
    ///   - id: Job id
    ///   - callback: Async callback
    open static func delete(_ username: String, _ password: String, id: Int, _ callback: @escaping (String) -> Void) {
        PrintSession.pms_login(username, password) { ret in
            if ret == "success" {
                let json = "{\"bstrSessionID\": \"\(pms_session)\",\"bstrOP\":\"DEL\",\"bstrJobID\":\"\(id)\"}"
                var delete_headers = headers
                delete_headers["Content-Type"] = "application/json"
                delete_headers["X-Requested-With"] = "XMLHttpRequest"
                let request = MyAlamofire.shared?.upload(json.data(using: .utf8)!, to: pms_print_job_set_url, method: .post, headers: delete_headers).responseData { response in
                    switch response.result {
                    case .success:
                        guard response.data != nil else {
                            callback("Empty response")
                            return
                        }
                        let rjson = JSON(data: response.data!)
                        guard rjson.exists() else {
                            callback("Invalid response")
                            return
                        }
                        let error = rjson["ErrorMessage"]
                        if error == "" {
                            callback("success")
                        } else {
                            callback("fail")
                        }
                        break
                    case .failure(let error):
                        debugPrint(error)
                        callback(error.localizedDescription)
                    }
                }
                MyAlamofire.requests.append(request)
            } else {
                callback(ret)
            }
        }
    }
    
    /// Trigger generating preview images on PMS server
    ///
    /// - Parameters:
    ///   - username: PMS account
    ///   - password: PMS password
    ///   - filename: .opm file to generate
    open static func generate_preview(_ username: String, _ password: String, filename: String) {
        PrintSession.pms_login(username, password) { ret in
            guard ret == "success" else {
                return
            }
            debugPrint("Request preview for \(filename)")
            let request1url = "http://pms.sustc.edu.cn/view.aspx"
            let parameters1: Parameters = [
                "sid": pms_session,
                "f": filename,
                "c": "1"
            ]
            debugPrint("Encoded url: \(request1url)")
            let request = MyAlamofire.shared?.request(request1url, method: .get, parameters: parameters1, encoding: URLEncoding.default, headers: nil).response { response1 in
                debugPrint("resp1: \(response1.error as Any)")
                let request = MyAlamofire.shared?.request(request1url).response { response1_5 in
                    debugPrint("resp1.5: \(response1_5.error as Any)")
                    let request2url = "http://pms.sustc.edu.cn/view.aspx?op=GetImg&s=false"
                    let request = MyAlamofire.shared?.upload("".data(using: .utf8)!, to: request2url).response { response2 in
                        debugPrint("resp2: \(response2.error as Any)")
                        let request3url = "http://pms.sustc.edu.cn/view.aspx?op=GetImg&s=true"
                        let request = MyAlamofire.shared?.upload("".data(using: .utf8)!, to: request3url).response { response3 in
                            debugPrint("resp3: \(response3.error as Any)")
                        }
                        MyAlamofire.requests.append(request)
                    }
                    MyAlamofire.requests.append(request)
                }
                MyAlamofire.requests.append(request)
            }
            MyAlamofire.requests.append(request)
        }
    }
    
    /// Main procedure of query method
    ///
    /// - Parameter callback: Async callback (hell)
    private static func query_main(_ callback: @escaping (String, [PrintJob]) -> Void) {
        var query_headers = headers
        query_headers["Content-Type"] = "application/json"
        query_headers["X-Requested-With"] = "XMLHttpRequest"
        let requestjson = "{\"bstrSessionID\": \"\(pms_session)\"}"
        let request = MyAlamofire.shared?.upload(requestjson.data(using: .utf8)!, to: pms_print_job_query_url, headers: query_headers).responseData(completionHandler: { response in
            switch response.result {
            case .success:
                guard response.data != nil else {
                    callback("Empty response", [])
                    return
                }
                let json = JSON(data: response.data!)
                guard json.exists() else {
                    callback("Invalid response json", [])
                    return
                }
                if let result = json["Result"].array {
                    var items: [PrintJob] = []
                    for item in result {
                        guard let id = item["dwJobId"].int else {
                            callback("Broken response json", [])
                            return
                        }
                        guard let pages = item["dwPages"].int else {
                            callback("Broken response json", [])
                            return
                        }
                        guard let copies = item["dwCopies"].int else {
                            callback("Broken response json", [])
                            return
                        }
                        guard var property = item["szProperty"].string else {
                            callback("Broken response json", [])
                            return
                        }
                        property = property.removeBetween("<", ">")
                        guard var form = item["szForm"].string else {
                            callback("Broken response json", [])
                            return
                        }
                        form = form.removeBetween("<", ">")
                        guard let time = item["szDateTime"].string else {
                            callback("Broken response json", [])
                            return
                        }
                        guard let name = item["szDocument"].string else {
                            callback("Broken response json", [])
                            return
                        }
                        guard let jobfilename = item["szJobFileName"].string else {
                            callback("Broken response json", [])
                            return
                        }
                        let job = PrintJob(id: id, pages: pages, copies: copies, property: property, form: form, time: time, name: name, jobfilename: jobfilename)
                        items.append(job)
                    }
                    callback("success", items)
                } else {
                    callback("success", [])
                    return
                }
                break
            case .failure(let error):
                debugPrint(error)
                callback(error.localizedDescription, [])
            }
        })
        MyAlamofire.requests.append(request)
    }
    
}

/// Describe a single print job
open class PrintJob {
    
    /// The job id which can be used to delete the job
    open let id: Int
    open let pages: Int
    open let copies: Int
    /// Color/BlackWhite
    open let property: String
    /// Paper type
    open let form: String
    open let time: String
    open let name: String
    /// Used to get preview of print file
    open let jobfilename: String
    
    public init(id: Int, pages: Int, copies: Int, property: String, form: String, time: String, name: String, jobfilename: String) {
        self.id = id
        self.pages = pages
        self.copies = copies
        self.property = property
        self.form = form
        self.time = time
        self.name = name
        self.jobfilename = jobfilename
    }
    
}
