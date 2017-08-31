//
//  GradeHelper.swift
//  sushelper
//
//  Created by xieyi on 2017/8/7.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

let Semester_List_URL = "http://jwxt.sustc.edu.cn/jsxsd/kscj/cjcx_query"
let Grade_List_URL    = "http://jwxt.sustc.edu.cn/jsxsd/kscj/cjcx_list"
let Grade_Detail_URL  = "http://jwxt.sustc.edu.cn/jsxsd/kscj/pscj_list.do"

class GradeHelper {
    
    static let headers:HTTPHeaders = [
        ://"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
    ]
    
    public static func getsemesters(_ callback: @escaping ([String]) -> Void) {
        var html:String? = nil
        let request = MyAlamofire.shared?.request(Semester_List_URL, headers: headers).responseData(completionHandler: { response in
            switch response.result {
            case .success:
                html = String(data: response.data!, encoding: .utf8)
                guard html != nil else {
                    callback(["error", "Empty response"])
                    return
                }
                guard (html?.lengthOfBytes(using: .utf8))! > 0 else {
                    callback(["error", "Empty response"])
                    return
                }
                if (html?.contains("kksj"))! {
                    //do {
                        let doc = HTML(html: html!, encoding: .utf8)
                        let table = doc?.xpath("//select[@id=\"kksj\"]/option")
                        var values: [String] = []
                        for option in table! {
                            if let value = option["value"]{
                                if value != "" {
                                    values.append(value)
                                }
                            }
                        }
                        callback(values)
                    //} catch let error {
                    //    callback(["error", error.localizedDescription])
                    //}
                    return
                } else {
                    callback(["error", "invalidresponse"])
                }
                break
            case .failure(let error):
                callback(["error", error.localizedDescription])
            }
        })
        MyAlamofire.requests.append(request)
    }
    
    public static func getgrades(_ semester: String, _ callback: @escaping ([String], [Grade]) -> Void) {
        var html:String? = nil
        let poststr = "kksj=\(semester)&kcxz=&kcmc=&xsfs=all"
        let request = MyAlamofire.shared?.upload(poststr.data(using: .utf8)!, to: Grade_List_URL, method: .post, headers: headers).responseData { response in
            switch response.result {
            case .success:
                html = String(data: response.data!, encoding: .utf8)
                guard html != nil else {
                    callback(["error", "Empty response"], [])
                    return
                }
                guard (html?.lengthOfBytes(using: .utf8))! > 0 else {
                    callback(["error", "Empty response"], [])
                    return
                }
                if (html?.contains("td colspan"))! {
                    callback(["success"], [])
                    return
                }
                if (html?.contains("dataList"))! {
                    //do {
                        let doc = HTML(html: html!, encoding: .utf8)
                        let table = doc?.xpath("//table[@id=\"dataList\"]//tr")
                        var grades: [Grade] = []
                        for i in 1...(table?.count)!-1 {
                            let row = table?[i].xpath("td")
                            //Default values
                            var courseid: String = ""
                            var course: String = ""
                            var grade: Double = -1
                            var credit: Double = 0
                            var level: String = ""
                            var category: String = ""
                            //Course ID
                            if let text = row?[2].text {
                                courseid = text
                            }
                            //Course name
                            if let text = row?[3].text {
                                course = text
                            }
                            //Grade
                            if let href = row?[4].xpath("a").first {
                                if let link = href["href"] {
                                    if let gradeindex = link.range(of: "zcj=")?.upperBound {
                                        let gradestr = link.substring(from: gradeindex)
                                        if gradestr.characters.index(of: "'") != nil {
                                            if gradestr.contains("通过") {
                                                grade = -1
                                            } else {
                                                grade = (gradestr as NSString).doubleValue
                                            }
                                        }
                                    }
                                }
                            }
                            //Credit
                            if let text = row?[5].text {
                                credit = (text as NSString).doubleValue
                            }
                            //Level
                            if var text = row?[4].text {
                                text = text.replacingOccurrences(of: "\r", with: "")
                                text = text.replacingOccurrences(of: "\n", with: "")
                                text = text.replacingOccurrences(of: "\t", with: "")
                                level = text
                            }
                            //Category
                            if let text = row?[9].text {
                                category = text
                            }
                            grades.append(Grade(semester: semester, id: courseid, course: course, grade: grade, credit: credit, level: level, category: category))
                        }
                        callback(["success"], grades)
                    //} catch let error {
                    //    callback(["error", error.localizedDescription], [])
                    //}
                    return
                } else {
                    callback(["error", "invalidresponse"], [])
                }
                break
            case .failure(let error):
                callback(["error", error.localizedDescription], [])
            }
        }
        MyAlamofire.requests.append(request)
    }
    
}

enum GPAType {
    case fivelevel
    case hundredscore
}

class Grade {
    
    let semester: String
    let courseid: String
    let course: String
    let grade: Double
    let credit: Double
    let level: String
    let category: String
    var include = true
    
    var pointer: Any? = nil
    
    init(semester: String, id: String, course: String, grade: Double, credit: Double, level: String, category: String) {
        self.semester = semester
        self.courseid = id
        self.course = course
        self.grade = grade
        self.credit = credit
        self.level = level
        self.category = category
    }
    
    func getGPA(_ type: GPAType) -> Double {
        if type == .fivelevel {
            if grade >= 97 {
                return 4.00
            }
            if grade >= 93 {
                return 3.94
            }
            if grade >= 90 {
                return 3.85
            }
            if grade >= 87 {
                return 3.73
            }
            if grade >= 83 {
                return 3.55
            }
            if grade >= 80 {
                return 3.32
            }
            if grade >= 77 {
                return 3.09
            }
            if grade >= 73 {
                return 2.78
            }
            if grade >= 70 {
                return 2.42
            }
            if grade >= 67 {
                return 2.08
            }
            if grade >= 63 {
                return 1.63
            }
            if grade >= 60 {
                return 1.15
            }
            return 0
        }
        if type == .hundredscore {
            if grade < 60 {
                return 0
            }
            return grade / 20 - 1
        }
        //Should never reach here
        return 0
    }
    
}
