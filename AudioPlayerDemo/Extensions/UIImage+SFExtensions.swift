//
//  UIImage+SFExtensions.swift
//  FanGroupTest
//
//  Created by JingshunZhang on 2017/5/18.
//  Copyright © 2017年 ix86. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import CoreImage

// MARK: - 绘制圆形
extension UIImage {

    /// 将图像绘制成圆形图像
    ///
    /// - Parameters:
    ///   - size: 要绘制的图像大小，size宽高要一致
    ///   - opaque: 设置为true：不透明。false：会产生图层混合,对table性能优化会有些影响
    ///   - backColor: 圆形图像外边的颜色（和图片后面的大背景重合的颜色）
    ///   - lineColor: 描边颜色
    /// - Returns: 将图像绘制成圆形图像
    func sf_circleImage(size: CGSize, opaque: Bool = true, backColor: UIColor? = UIColor.white, lineColor: UIColor?) -> UIImage? {
        // 1. 计算图片画布的Rect
        let hw = size.height //圆形的直径
        let imgH = self.size.height
        let imgW = self.size.width
        
        var rectH: CGFloat = 0
        var rectW: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        if imgW > imgH { // 按高度缩放
            rectH = hw
            rectW = imgW * hw / imgH
            x = (rectW - rectH) / 2.0
        } else { //按宽度缩放
            rectW = hw
            rectH = imgH * hw / imgW
            y = (rectH - rectW) / 2.0
        }
        let drawRect = CGRect(x:-x,y:-y,width:rectW,height:rectH)
        
        // 2. 绘制
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
        let clipRect = CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: hw, height: hw))
        //填充背景色
        if backColor != nil {
            backColor?.setFill()
            UIRectFill(clipRect)
        }
        // 裁剪
        let path = UIBezierPath(ovalIn: clipRect)
        path.addClip()
        // 绘制
        draw(in: drawRect)
        
        if let lColore = lineColor {
            let ovalPath = UIBezierPath(ovalIn: clipRect)
            ovalPath.lineWidth = 1
            lColore.setStroke()
            ovalPath.stroke()
        }

        // 获取图像
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return result

    }

    
    /// 按图片的短边等比缩放的图片大小
    fileprivate class func scaleSizeByMinSide(imageSize: CGSize, toSize: CGSize) -> CGSize {
        // 1.如果图片宽高相等，直接返回想要的大小
        let imgW = imageSize.width
        let imgH = imageSize.height
        if imgW == imgH {
            return toSize
        }
        // 2.处理等比缩放
        var toW = toSize.width
        var toH = toSize.height
        if imgW > imgH {// 按短边（高度）缩放
            toW = imgW * toH / imgH
        } else { // 按宽度缩放
            toH = imgH * toW / imgW
        }
        return CGSize(width: toW, height: toH)
    }
    
}


// MARK: - 等比缩放
extension UIImage {
    
    /// 等比缩放，返回不超过maxSize的图片宽高
    ///
    /// - Parameters:
    ///   - imageSize: 图片的实际大小
    ///   - maxSize: 图片存放的最大矩形区域
    /// - Returns: 等比缩放后的大小
    private class func imageScaleSize(imageSize: CGSize, maxSize: CGSize) -> CGSize {
        let imgW = imageSize.width
        let imgH = imageSize.height
        let maxW = maxSize.width
        let maxH = maxSize.height
        if imgW <= maxW && imgH <= maxH {
            return imageSize
        }

        var width: CGFloat = 0
        var height: CGFloat = 0

        if imgW >= imgH {
            let h: CGFloat = imgH * maxW / imgW
            if h <= maxH {
                width = maxW
                height = h
            } else {
                width = imgW * maxH / imgH
                height = maxH
            }
        } else {
            let w: CGFloat = imgW * maxH / imgH
            if w <= maxW {
                width = w
                height = maxH
            } else {
                height = imgH * maxW / imgW
                width = maxW
            }
        }

        return CGSize(width: width, height: height)
    }

    /// 等比缩放图像
    ///
    /// - Parameter maxSize: 图像所在的矩形区域
    /// - Returns: 缩放后的图像
    func sf_scaleImage(maxSize: CGSize) -> UIImage? {
        // 等比缩放的大小
        let scallSize = UIImage.imageScaleSize(imageSize: self.size, maxSize: maxSize)
        
        UIGraphicsBeginImageContextWithOptions(scallSize, true, 0)
        draw(in: CGRect(origin: CGPoint(), size: scallSize))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
}


// MARK: - 高斯模糊
extension UIImage {
    /// 高斯模糊
    func vagueImage(blur: CGFloat) -> UIImage? {
        var drawImage = self
        var rect = CGRect(origin: CGPoint.zero, size: self.size)
        if self.size.width > 720 {
            rect = CGRect(origin: CGPoint.zero, size: CGSize(width: 720, height: self.size.height / self.size.width * 720))
            drawImage = drawImage.compressedPicture(size: rect.size)
        }
        if self.size.height > 1000 {
            rect = CGRect(origin: CGPoint.zero, size: CGSize(width: self.size.width / self.size.height * 1000, height: 1000))
            drawImage = drawImage.compressedPicture(size: rect.size)
        }
        
        //获取原始图片
        let inputImage =  CIImage(image: drawImage)
        //使用高斯模糊滤镜
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(inputImage, forKey:kCIInputImageKey)
        //设置模糊半径值（越大越模糊）
        filter.setValue(blur, forKey: kCIInputRadiusKey)
        let outputCIImage = filter.outputImage!
        let context =  CIContext(options: convertToOptionalCIContextOptionDictionary([convertFromCIContextOption(CIContextOption.useSoftwareRenderer) : false]))
        
        let cgImage = context.createCGImage(outputCIImage, from: rect)
        if let cgImage = cgImage {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    private func compressedPicture(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalCIContextOptionDictionary(_ input: [String: Any]?) -> [CIContextOption: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (CIContextOption(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCIContextOption(_ input: CIContextOption) -> String {
	return input.rawValue
}
