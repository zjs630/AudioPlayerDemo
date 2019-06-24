//
//  SquareInterview.swift
//  AudioPlayerDemo
//
//  Created by 张京顺 on 2019/6/24.
//  Copyright © 2019 ix86. All rights reserved.
//

import Foundation
struct SquareInterview: Codable {
    
    /** 昵称 */
    var nickName: String

    /** 头像 */
    var avatar: String

    /** 视频标题/音频标题 */
    var audioTitle: String
    
    /** 时间字符串 ("yyyy-MM-dd hh:mm") */
    var timeStr: String

    /** 音频地址 */
    var audioUrl: String
    
    /** 封面 */
    var cover: String

    /** 封面中间的小图url */
    var coverMiddleUrl: String

    /** '时长 单位秒' */
    var duration: Int32


}
