//
//  SFAudioPlayer.swift
//  FanGroupTest
//
//  Created by JingshunZhang on 2017/5/16.
//  Copyright © 2017年 ix86. All rights reserved.
//

import Foundation
import AVFoundation

@objc protocol SFAudioPlayerDelegate: NSObjectProtocol {
    
    /// 更新进度
    ///
    /// - Parameter player: 播放器
    func updateAudioProgress(player:AVAudioPlayer)
    
    /// 播放结束
    ///
    /// - Parameters:
    ///   - player: 播放器
    ///   - flag: 是否播放成功
    @objc optional func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
}

class SFAudioPlayer: NSObject {
    /// 单例
    static let shared = SFAudioPlayer()
    ///播放器
    var player:AVAudioPlayer?
    /// 用于刷新播放进度
    var timer: Timer?
    
    var cellIndexRow: Int?
    
    /// 是否正在播放
    var isPlaying: Bool {
        if let thePlayer = self.player {
            return thePlayer.isPlaying
        }
        return false
    }
    
    var progress: Double{
        if let player = player {
            let progress = player.currentTime / player.duration
            return progress
        }
        return 0
    }
    
    weak var delegate:SFAudioPlayerDelegate?
    
    /// 从当前时间播放音频
    var seekTime:TimeInterval = 0 {
        willSet {
            player?.currentTime = newValue
        }
    }
    
    /// 初始化播放器并播放音频
    ///
    /// - Parameters:
    ///   - url: 播放地址
    /// - Returns: 是否播放成功
    func play(loacl url:URL) -> (isOk: Bool,errorCode: Int?){
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory("AVAudioSessionCategoryPlayback")
            
            player = try AVAudioPlayer(contentsOf:url)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            startTimer()
        } catch {
            print(error)
            let code = (error as NSError).code
            if  code == 1685348671 { //文件下载错误，删掉错误缓存
                SFAudioManager.removeCacheAudio(by: url)
            }
            stop() //停止播放
            return (false,code)
        }
        
        return (true, nil)
    }
    
    /// 用于更新播放进度
    private func startTimer() {
        if  timer != nil {
            stopTimer()
        }
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(updateAudioProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateAudioProgress() {
        if let thePlayer = player {
            delegate?.updateAudioProgress(player: thePlayer)
        }
    }
    /// 停止timer
    fileprivate func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    /// 播放或者暂停播放音频
    func playOrPause() {
        guard let thePlayer = player else {
            return
        }
        
        if thePlayer.isPlaying {
            pause()
        } else {
            thePlayer.play()
            startTimer()
        }
    }
    
    /// 暂停播放音频
    func pause() {
        guard let thePlayer = player else {
            return
        }
        
        if thePlayer.isPlaying {
            thePlayer.pause()
            stopTimer()
        }
    }

    
    /// 停止播放音频，停止time更新进度
    func stop() {
        guard let thePlayer = player else {
            return
        }

        if (thePlayer.isPlaying) {
            thePlayer.stop()
        }
        player = nil
        stopTimer()
        cellIndexRow = nil
    }
}

extension SFAudioPlayer : AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.audioPlayerDidFinishPlaying?(player, successfully: true)
        self.player = nil
        stopTimer()

        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"AudioPlayerDidFinishPlaying"), object: cellIndexRow)
    }
}
