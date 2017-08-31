//
//  PrintUpload.swift
//  sushelper
//
//  Created by xieyi on 2017/8/17.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import Alamofire

class PrintUpload {
    
    static let headers: HTTPHeaders = [
        ://"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
    ]
    
    static func upload(_ username: String, _ password: String, _ file: PrintFile, _ callback: @escaping (String, Double) -> Void) {
        PrintSession.pms_login(username, password) { ret in
            if ret == "success" {
                upload_main(file, callback)
            } else {
                callback(ret, -1)
            }
        }
    }
    
    //Reference: https://medium.com/@hanifsgy/alamofire-multipart-with-parameters-upload-image-from-uiimagepickercontroller-swift-a4abada24ae
    private static func upload_main(_ file: PrintFile, _ callback: @escaping (String, Double) -> Void) {
        let url = try! URLRequest(url: String(format: pms_upload_file_url_format, pms_session), method: .post, headers: headers)
        MyAlamofire.shared?.upload(multipartFormData: { formdata in
            formdata.append(file.file, withName: "file", fileName: file.filename, mimeType: "application/pdf") //TODO: not right for other formats
            formdata.append(file.paperid.data(using: .utf8)!, withName: "paperid")
            formdata.append("\(file.color)".data(using: .utf8)!, withName: "color")
            formdata.append(file.double.data(using: .utf8)!, withName: "double")
            formdata.append("\(file.copies)".data(using: .utf8)!, withName: "copies")
        }, with: url, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress { progress in
                    callback("progress", progress.fractionCompleted)
                    }.responseData(completionHandler: { response in
                        switch response.result {
                        case .success:
                            guard let data = response.data else {
                                callback("Empty response", -1)
                                return
                            }
                            guard var str = String(data: data, encoding: .utf8) else {
                                callback("Invalide response", -1)
                                return
                            }
                            if str.contains("OnCurrentDialogOK(\"") {
                                str = str.subStringAfter("OnCurrentDialogOK(\"")
                                str = str.subStringBefore("$(\"#info\").click(function()")
                                str = str.subStringBefore("\");")
                                str = str.replacingOccurrences(of: "<br/>", with: "，")
                                str = str.removeBetween("<", ">")
                                callback(str, -2)
                                return
                            } else if str.contains("OnCurrentDialogError(\"") {
                                str = str.subStringAfter("OnCurrentDialogError(\"")
                                str = str.subStringBefore("$(\"#info\").click(function()")
                                str = str.subStringBefore("\");")
                                str = str.removeBetween("<", ">")
                                callback(str, -1)
                                return
                            } else if str == "" {
                                callback("服务器响应超时，文档可能已经上传成功，请等待几分钟后查询确认。", -1)
                            } else {
                                callback("I don't understand the response from the server", -1)
                                debugPrint(String(data: data, encoding: .utf8) ?? "")
                                return
                            }
                        case .failure(let error):
                            debugPrint(error)
                            callback(error.localizedDescription, -1)
                        }
                })
            case .failure(let error):
                debugPrint(error)
                callback(error.localizedDescription, -1)
            }
        })
    }
    
}

class PrintFile {
    
    let filename: String
    let paperid: String // A4  A3
    let color: Int // 0 - BW  1 - CO
    let double: String // dupnone  dupvertical  duphorizontal
    let copies: Int
    let file: Data
    
    init(filename: String, paperid: String, color: Int, double: String, copies: Int, file: Data) {
        self.filename = filename
        self.paperid = paperid
        self.color = color
        self.double = double
        self.copies = copies
        self.file = file
    }
    
}
