//
//  StringExt.swift
//  sushelper
//
//  Created by xieyi on 2017/8/14.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation

extension String {
    
    //Reference: https://stackoverflow.com/questions/43383835/remove-the-first-six-characters-from-a-string-swift
    func removeFirst(_ length: Int) -> String {
        if length <= 0 {
            return self
        } else if let to = self.index(self.startIndex, offsetBy: length, limitedBy: self.endIndex) {
            return self.substring(from: to)
            
        } else {
            return ""
        }
    }
    
    //Reference: https://stackoverflow.com/questions/29421726/swift-how-to-get-the-string-before-a-certain-character
    func subStringBefore(_ what: String) -> String {
        if let range = self.range(of: what) {
            let firstPart = self[self.startIndex..<range.lowerBound]
            return firstPart
        } else {
            return self
        }
    }
    
    func subStringAfter(_ what: String) -> String {
        if let range = self.range(of: what) {
            let lastPart = self[range.upperBound..<self.endIndex]
            return lastPart
        } else {
            return self
        }
    }
    
    //Reference: https://stackoverflow.com/questions/31725424/swift-get-string-between-2-strings-in-a-string
    func removeBetween(_ from: String, _ to: String) -> String {
        var temp = self
        while true {
            if let match = temp.range(of: "\(from)(.*?)\(to)", options: .regularExpression) {
                if match.lowerBound == match.upperBound {
                    break
                }
                temp.removeSubrange(match)
            } else {
                break
            }
        }
        return temp
    }
    
}
