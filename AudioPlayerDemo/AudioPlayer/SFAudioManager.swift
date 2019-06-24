//
//  SFAudioManager.swift
//
//  Created by JingshunZhang on 2017/5/25.
//  Copyright © 2017年 ix86. All rights reserved.
//

import UIKit

class SFAudioManager: NSObject {
    static var cellIndexPathRow: Int = -1
    
    /// 依据音频网络url，下载资源到本地，返回获取播放地址。（cellId，仅饭圈用）
    class func getLoaclAudioURL(urlString: String, cellId: Int = -1,completion: @escaping (_ response: URLResponse?, _ filePath:URL?, _ isSuccess: Bool)->()) {
        
        cellIndexPathRow = cellId
        //1.先判断是否有缓存,有缓存不用再去下载
        let audioCacheManager = SFFanGroupAudioCacheManager.shared
        let path = audioCacheManager.getCacheFilePath(urlString: urlString)
        if FileManager.default.fileExists(atPath: path) {
            let p = URL(fileURLWithPath: path)
            completion(nil,p,true)
            return
        }
        //2.下载音频
        // 先判断是否有未完成的下载，如果有先结束下载
        switch audioCacheManager.status {
        case .downloading:
            audioCacheManager.dataTaskCancel()
        default: break
        }
        
        SFFanGroupAudioCacheManager.shared.downloadAudio(urlString:urlString){
            (response: URLResponse, filePath:URL?, isSuccess: Bool) in
            completion(response,filePath,isSuccess)
        }
        
    }
    
    /// 暂停下载，导致的重新播放音频
    class func reloadAudioURL(completion: @escaping (_ response: URLResponse?, _ filePath:URL?, _ isSuccess: Bool)->()) {
        SFFanGroupAudioCacheManager.shared.reDownloadAudio{
            (response: URLResponse, filePath:URL?, isSuccess: Bool) in
            completion(response,filePath,isSuccess)
        }
        
    }

    
    /// 是否是正在下载的单元格
    class func isDownLoadingCell(cellId: Int) -> Bool {
        let status = SFFanGroupAudioCacheManager.shared.status
        return (status == .downloading) && (cellId == cellIndexPathRow)
    }
    
    /// 是否正在下载
    class func isDownLoading() -> (isDownLoading: Bool,cellIndexPathRow: Int){
        let status = SFFanGroupAudioCacheManager.shared.status
        let isDownLoading = (status == .downloading) && (cellIndexPathRow != -1)
        return (isDownLoading,cellIndexPathRow)
    }

    class func removeCacheAudio(by url: URL) {
        let path = url.relativePath
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print(error)
            }
        }

    }
    
    class func stopDownlaod() {
        SFFanGroupAudioCacheManager.shared.dataTaskCancel()
    }
    
    class func pasueDownload() {
        SFFanGroupAudioCacheManager.shared.dataTaskSuspend()
    }
    
    class func resumeDownload() {
        SFFanGroupAudioCacheManager.shared.dataTaskResume()
    }
}
