//
//  DemoAccount.swift
//  sushelper
//
//  Created by xieyi on 2017/8/7.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation

let CAS_Demo_Account = "00000000"
let CAS_DEMO_Password = "0ava0k"

var Demo_Mode = false

/// Demo data which does not require real login
class DemoData {
    
    //Grade
    static let semesters: [String] = [
        "2016-2017-1",
        "2016-2017-2",
        "2016-2017-3"
    ]
    
    static let grades: [String: [Grade]] = [
        "2016-2017-1": [
            Grade(semester: "2016-2017-1", id: "MA101", course: "高等数学", grade: 85, credit: 4, level: "A-", category: "通识必修"),
            Grade(semester: "2016-2017-1", id: "PHY101", course: "大学物理", grade: 87, credit: 4, level: "A-", category: "通识必修"),
            Grade(semester: "2016-2017-1", id: "CH101", course: "大学化学", grade: 80, credit: 4, level: "B", category: "通识必修"),
            Grade(semester: "2016-2017-1", id: "GE121", course: "心理学", grade: 81, credit: 3, level: "B", category: "通识选修"),
            Grade(semester: "2016-2017-1", id: "BIO101", course: "普通生物学", grade: 73, credit: 4, level: "C+", category: "通识必修"),
            Grade(semester: "2016-2017-1", id: "CS101", course: "计算机导论", grade: 92, credit: 3, level: "A-", category: "专业基础课")
        ],
        "2016-2017-2": [
            Grade(semester: "2016-2017-2", id: "MA203", course: "概率论与数理统计", grade: 94, credit: 3, level: "A", category: "专业基础课"),
            Grade(semester: "2016-2017-2", id: "CS102", course: "离散数学", grade: 93, credit: 3, level: "A", category: "专业基础课"),
            Grade(semester: "2016-2017-2", id: "MA113", course: "线性代数", grade: 67, credit: 4, level: "C-", category: "通识必修"),
            Grade(semester: "2016-2017-2", id: "PHY302", course: "量子力学", grade: 36, credit: 3, level: "F", category: "专业核心课"),
            Grade(semester: "2016-2017-2", id: "GE034", course: "托福培训", grade: 0, credit: 0, level: "P", category: "专业核心课")
        ],
        "2016-2017-3": [
            Grade(semester: "2016-2017-3", id: "CS312", course: "计算机创新实验", grade: 0, credit: 1, level: "P", category: "专业核心课")
        ]
    ]
    
}
