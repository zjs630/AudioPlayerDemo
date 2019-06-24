//
//  UIColor+SFExtensions.swift
//
//  Created by JingshunZhang on 2017/5/3.
//  Copyright © 2017年 ix86. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{

    // MARK: 类方法
    
    /// 生成一个颜色
    ///
    /// - Parameters:
    ///   - hex: 十六进制的RGB值
    ///   - a: 透明度
    /// - Returns: 返回一个UIColor对象
    class func sf_color(rgb hex: UInt32, a: CGFloat = 1.0) -> UIColor {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /// 生成一个颜色
    ///
    /// - Parameter hex: 十六进制的ARGB值
    /// - Returns: 返回一个UIColor对象
    class func sf_color(argb hex: UInt32) -> UIColor {
        let a = CGFloat((hex & 0xFF000000) >> 24) / 255.0
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        
        if #available(iOS 10.0, *) {
            return UIColor(displayP3Red: r, green: g, blue: b, alpha: a)
        }
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    
    /// 生产一个颜色
    ///
    /// - Parameters:
    ///   - red: 十进制的红色值
    ///   - green: 十进制的绿色值
    ///   - blue: 十进制的蓝色值
    ///   - a: 透明度
    /// - Returns: 返回一个UIColor对象
    class func sf_color(r red: UInt32,g green: UInt32,b blue: UInt32, a: CGFloat = 1.0) -> UIColor {
        let r = CGFloat(red) / 255.0
        let g = CGFloat(green) / 255.0
        let b = CGFloat(blue) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)

    }
    
    ///  随机颜色（常用于测试UI）
    ///
    /// - Returns: 返回一个随机颜色
    class func sf_randomColor() -> UIColor {
        return sf_color(r: arc4random_uniform(256), g: arc4random_uniform(256), b: arc4random_uniform(256))
    }

}
