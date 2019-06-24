//
//  String+Extensions.swift
//  AudioPlayerDemo
//
//  Created by 张京顺 on 2019/6/24.
//  Copyright © 2019 ix86. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
        
    /// 格式化音频视频时长为时间字符串
    ///
    /// - Parameter duration: 时长
    /// - Returns: 时间字符串
    static func sf_convertMedia(time duration:Int32) -> String {
        let h = duration / (60 * 60)
        let ms = duration % (60 * 60)
        let m = ms / 60
        let s = ms % 60
        let time = h > 0 ? String(format:"%.2d:%.2d:%.2d",h,m,s) : String(format:"%.2d:%.2d",m,s)
        return time
    }
    

    var md5: String {
        
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate()
        
        return String(format: hash as String)
    }

}
