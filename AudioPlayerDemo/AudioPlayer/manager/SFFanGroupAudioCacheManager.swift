//
//  SFFanGroupAudioCacheManager.swift
//
//  Created by JingshunZhang on 2017/5/25.
//  Copyright © 2017年 ix86. All rights reserved.
//

import UIKit
import AFNetworking

private let kAudioMaxCacheAge: Double = 60*60*60*3 //音频缓存最大时间，默认3天，单位秒

enum audioDownloadStatus: Int {
    case notBegin       //没有开始
    case downloading    //下载中
    case suspend        //暂停下载
    case complete       //下载完成
    case failed         //下载失败
}

class SFFanGroupAudioCacheManager {
    static let shared: SFFanGroupAudioCacheManager = SFFanGroupAudioCacheManager()
    
    var manager: AFURLSessionManager!
    /// 音频文件下载路径，~/Library/Cache/Audio
    fileprivate var downloadPath: String = ""
    /// 当前下载音频的url字符串
    var curentDownloadURL: String = ""
    /// 下载状态
    var status: audioDownloadStatus = .notBegin
    /// 下载任务
    var dataTask: URLSessionDownloadTask?
    
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(cleanDisk), name: UIApplication.didEnterBackgroundNotification, object: nil)

        manager = AFURLSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        let security = AFSecurityPolicy.default()
        security.allowInvalidCertificates = true
        security.validatesDomainName = false
        manager.securityPolicy = security
        createAudioDirectory()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 创建音频缓存目录
    private func createAudioDirectory() {
        let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let path = cacheDir.appending("/Audio")
        let url = URL(fileURLWithPath: path, isDirectory: true)
        let fm = FileManager.default
        if !fm.fileExists(atPath: path) {
            do {
                try fm.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }catch {
                print(error)
            }
        }
        downloadPath = path
        print(downloadPath)
    }
    
    
    /// 依据下载URL地址获取缓存的文件路径
    ///
    /// - Parameter urlString: 要下载的音频url地址
    /// - Returns: 缓存的文件地址
    func getCacheFilePath(urlString: String) -> String {
        var name = urlString.md5
        let pathExtension = (urlString as NSString).pathExtension
        if pathExtension != "" {
            name += ".\(pathExtension)"
        }
        let cachePath = (downloadPath as NSString).appendingPathComponent(name)
        return cachePath
    }
    
    /// 下载音频
    func downloadAudio(urlString: String, completion: @escaping (_ response: URLResponse, _ filePath:URL?, _ isSuccess: Bool)->()) {
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        //防止目录被删除，因为清空缓存，会删掉目录，如果目录不存在需要重新创建
        createAudioDirectory()
        
        //如果url地址一致，且是下载失败或者暂停状态，继续原来下载
        if curentDownloadURL == urlString && (status == .suspend) {
            if dataTask?.state != .completed {
                dataTaskResume()
                return
            }
        }
        
        curentDownloadURL = urlString
        let request = URLRequest(url: url)
        
        //创建下载任务
        dataTask = manager.downloadTask(with: request,
            progress:nil,
            destination: { [weak self](targetPath, response) -> URL in
                guard let strongSelf = self else {
                    return URL(fileURLWithPath: "")
                }
                let cachePath = strongSelf.getCacheFilePath(urlString: urlString)
                let mp3URL = URL(fileURLWithPath: cachePath)
                return mp3URL
        },
            completionHandler: { [weak self](response, filePath, error) in
                var isOk = true
                if error == nil {
                    self?.dataTaskComplete()
                } else {
                    isOk = false
                    self?.dataTaskFailed()
                }
                print(filePath?.absoluteString ?? "")
                completion(response, filePath, isOk)
        })
        
        // 开始下载
        dataTaskBegin()
    }
    
    func reDownloadAudio(completion: @escaping (_ response: URLResponse, _ filePath:URL?, _ isSuccess: Bool)->()) {
        guard let url = URL(string: curentDownloadURL) else {
            return
        }
        //防止目录被删除，因为清空缓存，会删掉目录，如果目录不存在需要重新创建
        createAudioDirectory()

        if status == .suspend {
            dataTaskResume()
            return
        }
        let request = URLRequest(url: url)
        
        //创建下载任务
        dataTask = manager.downloadTask(with: request,
                                        progress:nil,
                                        destination: { [weak self](targetPath, response) -> URL in
                                            guard let strongSelf = self else {
                                                return URL(fileURLWithPath: "")
                                            }
                                            let cachePath = strongSelf.getCacheFilePath(urlString: strongSelf.curentDownloadURL)
                                            let mp3URL = URL(fileURLWithPath: cachePath)
                                            return mp3URL
            },
                                        completionHandler: { [weak self](response, filePath, error) in
                                            var isOk = true
                                            if error == nil {
                                                self?.dataTaskComplete()
                                            } else {
                                                isOk = false
                                                self?.dataTaskFailed()
                                            }
                                            completion(response, filePath, isOk)
        })
        
        // 开始下载
        dataTaskBegin()
    }

    

    /// 开始下载
    func dataTaskBegin() {
        status = .downloading //开始下载
        dataTask?.resume()
    }
    
    /// 下载完成
    func dataTaskComplete() {
        status = .complete
        curentDownloadURL = ""
    }
    
    /// 下载失败
    func dataTaskFailed() {
        status = .failed
        // 保留curentDownloadURL，可以再次下载
    }
    
    /// 暂停下载
    func dataTaskSuspend() {
        //如果时下载状态，暂停下载
        if status == .downloading {
            status = .suspend
            dataTask?.suspend()
        }
    }
    
    /// 取消下载/结束下载
    func dataTaskCancel() {
        if status == .downloading {
            dataTask?.cancel()
        }
        status = .notBegin //恢复默认状态
        curentDownloadURL = ""
        dataTask = nil
    }
    
    /// 继续下载
    func dataTaskResume() {
        //如果时暂停状态，继续下载
        if status == .suspend && dataTask != nil{
            status = .downloading //开始下载
            dataTask?.resume()
        }
    }
}

// MARK: - 缓存管理
extension SFFanGroupAudioCacheManager {
    
    @objc fileprivate func cleanDisk() {
        let queue = DispatchQueue(label: "com.ix86.fangroup")
        queue.async {
            let diskCacheURL = URL.init(fileURLWithPath: self.downloadPath, isDirectory: true)
            let resourceKeys: Set = [URLResourceKey.isDirectoryKey,URLResourceKey.contentModificationDateKey, URLResourceKey.totalFileAllocatedSizeKey]
            var resourceArrayKeys: [URLResourceKey] = []
            for resourcekey in resourceKeys {
                resourceArrayKeys.append(resourcekey)
            }
            
            let fileManager = FileManager.default
            let myFileEnumerator = fileManager.enumerator(at: diskCacheURL, includingPropertiesForKeys:resourceArrayKeys)
            
            let expirationDate = Date(timeIntervalSinceNow: -kAudioMaxCacheAge)
            
            // Enumerate all of the files in the cache directory.
            //  1. Removing files that are older than the expiration date.
            var urlsToDelete = [URL]()
            guard let fileEnumerator = myFileEnumerator else {
                return
            }
            
            for fileURL in fileEnumerator {
                let fileUrl: URL = fileURL as! URL
                let resourceValues = try? fileUrl.resourceValues(forKeys: resourceKeys)
                // Skip directories.
                if resourceValues?.fileResourceType == URLFileResourceType.directory {
                    continue
                }
                // Remove files that are older than the expiration date;
                if let modificationDate: Date = resourceValues?.contentModificationDate {
                    if modificationDate < expirationDate {
                        urlsToDelete.append(fileUrl)
                        continue
                    }
                }
            }
            for fileURL: URL in urlsToDelete {
                try? fileManager.removeItem(at: fileURL)
            }
            
            //  2. Remove temp files

            let tmpURL = URL.init(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let tmpResourceArrayKeys: [URLResourceKey] = [URLResourceKey.isDirectoryKey]
            let myTmpFileEnumerator = fileManager.enumerator(at: tmpURL, includingPropertiesForKeys:tmpResourceArrayKeys)
            guard let tmpFileEnumerator = myTmpFileEnumerator else {
                return
            }
            for fileURL in tmpFileEnumerator {
                if let fileUrl: URL = fileURL as? URL {
                    let resourceValues = try? fileUrl.resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
                    // Skip directories.
                    if resourceValues?.fileResourceType == URLFileResourceType.directory {
                        continue
                    }
                    // Remove files
                    let pathExtension = (fileUrl.absoluteString as NSString).pathExtension
                    if pathExtension == "tmp" {
                        try? fileManager.removeItem(at: fileUrl)
                    }
                }
            }

        }
    }

}
