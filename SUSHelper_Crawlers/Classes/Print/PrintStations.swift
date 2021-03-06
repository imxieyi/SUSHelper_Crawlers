//
//  PrintStations.swift
//  sushelper
//
//  Created by xieyi on 2017/8/13.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Kanna

/// Query print stations
open class PrintStations {
    
    static let headers: HTTPHeaders = [
        ://"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
    ]
    
    /// Get session number and query all print stations
    ///
    /// - Parameter callback: Async callback
    open static func query(_ callback: @escaping (String, [PrintStation]) -> Void) {
        PrintSession.pms_public_login { ret in
            if ret == "success" {
                query_main(callback)
            } else {
                callback(ret, [])
            }
        }
    }
    
    /// Main query method
    ///
    /// - Parameter callback: Async callback
    private static func query_main(_ callback: @escaping (String, [PrintStation]) -> Void) {
        var query_headers = headers
        query_headers["Content-Type"] = "application/json"
        let requestjson = "{\"bstrSessionID\": \"\(pms_session)\"}"
        let request = MyAlamofire.shared?.upload(requestjson.data(using: .utf8)!, to: pms_print_station_query_url, headers: query_headers).responseData(completionHandler: { response in
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
                    var items: [PrintStation] = []
                    for item in result {
                        guard let status = item["dwStatus"].int else {
                            callback("Broken response json", [])
                            return
                        }
                        guard var property = item["szProperty"].string else {
                            callback("Broken response json", [])
                            return
                        }
                        property = property.removeBetween("<", ">")
                        guard var strstatus = item["szStatus"].string else {
                            callback("Broken response json", [])
                            return
                        }
                        strstatus = strstatus.removeBetween("<", ">")
                        guard let form = item["szForm"].string else {
                            callback("Broken response json", [])
                            return
                        }
                        guard var name = item["szName"].string else {
                            callback("Broken response json", [])
                            return
                        }
                        name = name.removeBetween("\\(", "\\)")
                        guard var statinfo = item["szStatInfo"].string else {
                            callback("Broken response json", [])
                            return
                        }
                        statinfo = statinfo.removeBetween("<", ">")
                        items.append(PrintStation(status: status, property: property, strstatus: strstatus, form: form, name: name, statinfo: statinfo))
                    }
                    //TODO: A workaround of empty job list after show station list
                    pms_session = ""
                    callback("success", items)
                } else {
                    callback("Invalid response json", [])
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

/// Describe a print station
open class PrintStation {
    
    /// Status number.
    /// Generally 0 means "operational".
    /// However I don't know how many codes are valid.
    /// Do not trust it before you have made clear what each code stands for.
    open let status: Int
    /// Print/Copy/Scan
    open let property: String
    /// Status description.
    /// Easier to understand but harder to parse.
    open let strstatus: String
    /// A4/A3 etc.
    open let form: String
    /// Always include Color/BlackWhite and location.
    open let name: String
    /// Additional status info
    open let statinfo: String
    
    public init(status: Int, property: String, strstatus: String, form: String, name: String, statinfo: String) {
        self.status = status
        self.property = property
        self.strstatus = strstatus
        self.form = form
        self.name = name
        self.statinfo = statinfo
    }
    
}
