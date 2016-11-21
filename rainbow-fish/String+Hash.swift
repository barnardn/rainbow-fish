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
        let data = self.data(using: String.Encoding.utf8)!
        var shasum = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CC_SHA1((data as NSData).bytes, CC_LONG(data.count), &shasum)
        let outString = NSMutableString(capacity: shasum.count)
        for byte in shasum {
            outString.appendFormat("%02x", byte)
        }
        return outString as String
    }

    func md5() -> String {
        let data = self.data(using: String.Encoding.utf8)!
        var md5sum = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5((data as NSData).bytes, CC_LONG(data.count), &md5sum)
        let outString = NSMutableString(capacity: md5sum.count)
        for byte in md5sum {
            outString.appendFormat("%02x", byte)
        }
        return outString as String
    }
    
    
}
