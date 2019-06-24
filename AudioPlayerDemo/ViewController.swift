//
//  ViewController.swift
//  AudioPlayerDemo
//
//  Created by 张京顺 on 2019/6/24.
//  Copyright © 2019 ix86. All rights reserved.
//

import UIKit
import AFNetworking

class ViewController: UIViewController {

    var model: SquareInterview?
    
    @IBOutlet weak var playAudioButton: UIButton!
    override func loadView() {
        super.loadView()
        playAudioButton.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    @IBAction func showDetailController(_ sender: Any) {
        let vc = SFAudioPlayerViewController()
        vc.model = model
        navigationController?.pushViewController(vc, animated: true)
        
        // testDownLoad()
    }
    
    private func loadData() {
        let url  = "https://ix86.win:8081/test/audio/audio.php"
        NetworkManager.request(url) { (json: Any?, isSuccess) in
            if isSuccess {
                print(json!)
                if let dic = json as? [String : Any] {
                    self.model = dic.convertToModel(SquareInterview.self)
                    self.playAudioButton.isHidden = false
                }
            }
        }
    }
}

extension ViewController {
    /// 测试下载代码
    /*
    private func testDownLoad() {
        let urlString = "https://ix86.win:8081/test/audio/ningxia.mp3"
        let manager = AFURLSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            let downloadTask = manager.downloadTask(with: request, progress: nil, destination: { (filePath:URL, resopnse:URLResponse) -> URL in
                let cachePath = SFFanGroupAudioCacheManager.shared.getCacheFilePath(urlString: urlString)
                print(cachePath)
                let mp3URL = URL(fileURLWithPath: cachePath)
                return mp3URL
                
            },
                completionHandler: { (response, filePath, error) in
                    print(filePath?.absoluteString ?? "")
            })
            
            downloadTask.resume()
        }
    }
    */
}
