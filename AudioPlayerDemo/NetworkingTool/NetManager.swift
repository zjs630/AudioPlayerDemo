//
//  NetManager.swift
//  AudioPlayerDemo
//
//  Created by 张京顺 on 2019/6/24.
//  Copyright © 2019 ix86. All rights reserved.
//

import Foundation
import AFNetworking

enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

/// A dictionary of parameters to apply to a `URLRequest`.
typealias Parameters = [String: Any]

class NetworkManager: AFHTTPSessionManager {
    static let shared: NetworkManager = {
        let instance = NetworkManager()
        instance.session.configuration.timeoutIntervalForRequest = 15
        instance.securityPolicy.allowInvalidCertificates = false
        instance.responseSerializer.acceptableContentTypes?.insert("text/plain")
        instance.responseSerializer.acceptableContentTypes?.insert("text/html")
        return instance
    }()
    
    /// 网络请求 get/post
    ///
    /// - Parameters:
    ///   - url: 接口路径
    ///   - method: HTTPMethod
    ///   - parameters: parameters
    ///   - encoding: ParameterEncoding
    ///   - headers: HTTPHeaders
    ///   - completion: 回调
    static func request(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        completion: @escaping (_ json: Any?, _ isSuccess: Bool) -> Void) {
        
        let success = { (taks: URLSessionDataTask, json: Any?) in
            completion(json, true)
        }
        let failure = { (task: URLSessionDataTask?, error: Error) in
            completion(nil, false)
        }
        
        if method == .get {
            NetworkManager.shared.get(url, parameters: parameters, headers: [:], progress: nil, success:success, failure: failure)
        } else if method == .post {
            NetworkManager.shared.post(url, parameters: parameters, headers: [:], progress: nil, success:success, failure: failure)
        }
        
    }

}

extension Dictionary {
    
    /// 自身节点转model
    ///
    /// - Parameter type: 类型
    /// - Returns: 传入类型实例
    func convertToModel<F:Codable>(_ type: F.Type) -> F? {
        do{
            let data : Data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
            let decoder = JSONDecoder()
            let model = try decoder.decode(F.self, from: data)
            return model
        }catch{
            print(error.localizedDescription)
            return nil
        }
    }
}

