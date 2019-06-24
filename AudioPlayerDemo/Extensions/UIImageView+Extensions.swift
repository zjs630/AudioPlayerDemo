//
//  UIImageView+Extensions.swift
//  AudioPlayerDemo
//
//  Created by 张京顺 on 2019/6/24.
//  Copyright © 2019 ix86. All rights reserved.
//


import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    // 设置高斯模糊效果
    func sf_setVagueImage(urlString: String?, placeholderImage: UIImage?, blur: CGFloat) {
        guard let urlString = urlString,
            let url  = URL(string: urlString) else {
                image = placeholderImage
                return
        }
        // 判断是否有缓存 add by zjs
        let nurlStr = "\(url.deletingPathExtension())VagueImage.\(url.pathExtension)"

        SDImageCache.shared.diskImageExists(withKey: nurlStr) { (isExists) in
            if isExists {
                let img = SDImageCache.shared.imageFromDiskCache(forKey: nurlStr)
                self.image = img
                return
            }
            
            // 网络下载
            self.sd_setImage(with: url, placeholderImage: UIImage(named: "star_theme_default"), options: [.retryFailed,.queryMemoryData,.avoidAutoSetImage]) { [weak self](image: UIImage?, error: Error?, type: SDImageCacheType, path: URL?) in
                if let showImage = image{
                    DispatchQueue.global().async {
                        let vagueImage = showImage.vagueImage(blur: blur)
                        DispatchQueue.main.async {
                            self?.image = vagueImage
                        }
                        // 缓存新图 add zjs
                        SDImageCache.shared.store(vagueImage, forKey: nurlStr, toDisk: true)
                    }
                }
            }

        }
        
    }
    
    /// 加载网络图片
    func sf_setImage(urlString: String?, placeholderImage: UIImage?) {
        guard let urlString = urlString,
            let url  = URL(string: urlString) else {
                image = placeholderImage
                return
        }
        sd_setImage(with: url, placeholderImage: placeholderImage)
    }
    
    ///  加载网络图片，绘制为圆形图片，并缓存到硬盘
    ///
    /// - Parameters:
    ///   - urlString: 图片地址字符串
    ///   - placeholderImage: 默认图
    ///   - size: 生成的图片大小，大小要一致
    ///   - isOpaque:  建议设置为true：不透明，同时设置背景色。//设置为false，达到layer.masksToBounds=true的效果
    ///   - backColor: 当不同明度为true时设置背景色
    func sf_setCircleImage(urlString: String?, placeholderImage: UIImage?, size: CGSize, isOpaque: Bool = true, backColor: UIColor? = .white) {
        guard let urlString = urlString,
            let url  = URL(string: urlString) else {
                image = placeholderImage
                return
        }
        
        // 判断是否有缓存
        let nurlStr = "\(url.deletingPathExtension())CircleImage\(size.width)\(isOpaque).\(url.pathExtension)"
        SDImageCache.shared.diskImageExists(withKey: nurlStr) { (isExists) in
            if isExists {
                let img = SDImageCache.shared.imageFromDiskCache(forKey: nurlStr)
                self.image = img
                return
            }
        
            // 网络下载
            self.sd_setImage(with: url, placeholderImage: placeholderImage, options: [.retryFailed,.queryMemoryData,.avoidAutoSetImage]) { [weak self] (image, _, _, _) in
                DispatchQueue.global().async {
                    guard let image = image else {
                        return
                    }
                    let img = image.sf_circleImage(size: size, opaque: isOpaque, backColor: backColor,lineColor: UIColor.sf_color(rgb: 0xeeeeee))
                    DispatchQueue.main.async {
                        self?.image = img
                    }
                    // 缓存新图
                    SDImageCache.shared.store(img, forKey: nurlStr, toDisk: true)
                }
            }
            
        }
        
        
        
    }
    

}
