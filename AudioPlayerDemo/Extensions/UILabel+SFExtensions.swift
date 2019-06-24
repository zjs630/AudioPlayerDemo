//
//  UILabel+SFExtensions.swift
//  FanGroupTest
//
//  Created by JingshunZhang on 2017/5/15.
//  Copyright © 2017年 ix86. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    class func sf_label(font size:CGFloat, color rgb: UInt32, text: String? = nil, bgColor: UInt32? = nil, alignment: NSTextAlignment = .left) -> UILabel {
        let contentLabel = UILabel()
        contentLabel.font = UIFont.systemFont(ofSize: size)
        contentLabel.textColor = UIColor.sf_color(rgb: rgb)
        contentLabel.text = text
        if bgColor != nil {
            contentLabel.backgroundColor = UIColor.sf_color(rgb: bgColor!)
        }
        contentLabel.textAlignment = alignment
        contentLabel.layer.masksToBounds = true //优化中文图层混合问题
        return contentLabel
    }
    
    /// 加粗的字体
    class func sf_boldLabel(font size:CGFloat, color rgb: UInt32, text: String? = nil, bgColor: UInt32? = nil, alignment: NSTextAlignment = .left) -> UILabel {
        let contentLabel = UILabel()
        contentLabel.font = UIFont.boldSystemFont(ofSize: size)
        contentLabel.textColor = UIColor.sf_color(rgb: rgb)
        contentLabel.text = text
        if bgColor != nil {
            contentLabel.backgroundColor = UIColor.sf_color(rgb: bgColor!)
        }
        contentLabel.textAlignment = alignment
        contentLabel.layer.masksToBounds = true //优化中文图层混合问题
        return contentLabel
    }

    
    class func sf_label(font size:CGFloat, uicolor color: UIColor, text: String? = nil, bgColor: UIColor? = nil, alignment: NSTextAlignment = .left) -> UILabel {
        let contentLabel = UILabel()
        contentLabel.font = UIFont.systemFont(ofSize: size)
        contentLabel.textColor = color
        contentLabel.text = text
        if bgColor != nil {
            contentLabel.backgroundColor = bgColor
        }
        contentLabel.textAlignment = alignment
        contentLabel.layer.masksToBounds = true //优化中文图层混合问题
        return contentLabel
    }

}
