//
//  String+Hash.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 4/2/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation

extension String  {
    
    func sha1() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var shasum = [UInt8](count: Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &shasum)
        var outString = NSMutableString(capacity: shasum.count)
        for byte in shasum {
            outString.appendFormat("%02x", byte)
        }
        return outString
    }

    func md5() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var md5sum = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        CC_MD5(data.bytes, CC_LONG(data.length), &md5sum)
        var outString = NSMutableString(capacity: md5sum.count)
        for byte in md5sum {
            outString.appendFormat("%02x", byte)
        }
        return outString
    }
    
    
}