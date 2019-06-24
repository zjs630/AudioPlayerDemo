//
//  SFAudioPlayerViewController.swift
//  AudioPlayerDemo
//
//  Created by JingshunZhang on 2019/6/24.
//  Copyright © 2017年 ix86. All rights reserved.
//

import UIKit
import AVFoundation

/// 音乐播放器页面

class SFAudioPlayerViewController: UIViewController, SFAudioPlayerDelegate {

    /// 播放进度视图
    private let audioProgressView = SFAudioProgressView()
    /// 底部视图
    private let bottomView: SFStarPlazaCellBottomView = SFStarPlazaCellBottomView()

    private let audioPlayer = SFAudioPlayer.shared
    
    var model: SquareInterview? //初始化要有值，否则不会播放音频
    
    /// 封面大图
    fileprivate let mainBackgroundImageView: UIImageView = {
        let mainBackgroundImageView = UIImageView()
        mainBackgroundImageView.contentMode = UIView.ContentMode.scaleAspectFill
        mainBackgroundImageView.clipsToBounds = true
        return mainBackgroundImageView
    }()
    
    /// 音频旋转的封面小图
    fileprivate let headImageView: SLAnimationImageView = {
        let headImageView = SLAnimationImageView()
        headImageView.layer.cornerRadius = 75
        headImageView.layer.masksToBounds = true
        //headImageView.contentMode = UIViewContentMode.scaleAspectFill
        return headImageView
    }()
    
    /// 播放开始或暂停按钮
    fileprivate lazy var playOrStopButton: UIButton = {
        let playOrStopButton = UIButton()
        let img = UIImage(named:"audio_player_play")
        playOrStopButton.setImage(img, for: .normal)
        playOrStopButton.addTarget(self, action: #selector(playOrPauseAduioButtonPressed), for: .touchUpInside)
        return playOrStopButton
    }()

    /// 旋转的指示器
    fileprivate let downloadingView: UIActivityIndicatorView = {
        let downloadingView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        downloadingView.isHidden = true
        return downloadingView
    }()
    
    // 阴影视图
    lazy var maskView: UIView = {
        let tempView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 100 - 60, width: UIScreen.main.bounds.width, height: 60))
        tempView.layer.addSublayer(self.gradientLayer)
        return tempView
    }()
    
    lazy var gradientLayer: CAGradientLayer = {
        let topColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        let bottomColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        //将颜色和颜色的位置定义在数组内
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: [CGFloat] = [0.0, 1.0]
        
        //创建CAGradientLayer实例并设置参数
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        
        //设置其frame以及插入view的layer
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: 60)
        return gradientLayer
    }()

    // MARK: - 系统函数
    override func loadView() {
        super.loadView()
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataForUI()
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)

        if let url = model?.audioUrl {
            playNewAudioURL(urlString: url)
        }
    }
    
    deinit {
        //如果播放音频时，点击返回了，要停止音频的播放
        SFAudioPlayer.shared.stop()
        NotificationCenter.default.removeObserver(self) 
    }
    
    // MARK: UI加载数据
    private func setupDataForUI() {
        if let model = model {
            //mainBackgroundImageView.sf_setImage(urlString: model.cover, placeholderImage: UIImage(named: "star_theme_default"))
            // 大背景图加高斯模糊
            mainBackgroundImageView.sf_setVagueImage(urlString: model.cover, placeholderImage: UIImage(named: "star_theme_default"), blur: 8.0)
            // 中间头像切圆角
            headImageView.sf_setCircleImage(urlString: model.avatar, placeholderImage: UIImage(named: "star_theme_default"),size: CGSize(width: 150, height: 150))
            audioProgressView.currentTimeLabel.text = "00:00"
            audioProgressView.totalTimeLabel.text = String.sf_convertMedia(time: model.duration)
            bottomView.setupData(model: model)
        }
    }
    
    // MARK: - 音频播放
    
    /// 点击播放或者暂停按钮
    @objc private func playOrPauseAduioButtonPressed() {
        guard let model = model else {
                return
        }
        let mediaURL = model.audioUrl
        //判断player对象是否存在
        if let player = SFAudioPlayer.shared.player{
            audioPlayer.delegate = self
            audioPlayer.playOrPause()
            changePlaying(status: player.isPlaying,will: true)
            return
        }
        playNewAudioURL(urlString: mediaURL) //开始新的音频
    }

    private func playNewAudioURL(urlString:String){
        
        beginDownloadAnimating()
        SFAudioManager.getLoaclAudioURL(urlString: urlString) { [weak self] (response, url, isOk) in
            self?.endDownloadAnimating()
            
            guard let strongSelf = self,
                let url = url else {
                    // 下载完成或失败后，设置没有播放状态
                    self?.changePlaying(status: false)
                    return
            }
            
            if isOk {
                // 播放音频
                let result = strongSelf.audioPlayer.play(loacl: url)
                if result.isOk {
                    strongSelf.audioPlayer.delegate = strongSelf
                    if let duration = strongSelf.audioPlayer.player?.duration {
                        strongSelf.audioProgressView.seekBar.maximumValue =  Float(duration)
                        strongSelf.audioProgressView.totalTimeLabel.text = String.sf_convertMedia(time: Int32(duration))
                    }
                    strongSelf.changePlaying(status: true)
                } else {
                    strongSelf.changePlaying(status: false)
                    strongSelf.showAlert(message: "播放失败，请重试！")
                }
            } else { // 下载失败
                strongSelf.showAlert(message: "音频下载失败，请重试！")
                SFAudioManager.removeCacheAudio(by: url)
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    
    // 进度条播放seek
    @objc fileprivate func seekTime(_ sender: UISlider) {
        if let _ = audioPlayer.player  {
            audioPlayer.seekTime = TimeInterval(sender.value)
        }
    }

    /// 改变播放状态
    /// - Parameter isPlayStatus: true 表示正在播放的状态， false 表示默认状态
    func changePlaying(status isPlayStatus: Bool, will replay:Bool = false) {
        if isPlayStatus {
            playOrStopButton.setImage(UIImage(named:"audio_player_pause"), for: .normal)
            if replay {
                headImageView.resumeAnimation()
            } else {
                headImageView.startAnimating()
            }
        } else {
            playOrStopButton.setImage(UIImage(named:"audio_player_play"), for: .normal)
            if replay {
                headImageView.pauseAnimation()
            } else {
                headImageView.stopAnimating()
            }
        }
    }
    
    func playover() {
        endDownloadAnimating()
        changePlaying(status: false)
        audioProgressView.playoverStatus()
    }
    
    private func pausePlay() {
        //判断player对象是否存在
        if let player = SFAudioPlayer.shared.player,
            player.isPlaying{
            audioPlayer.delegate = self
            audioPlayer.playOrPause()
            changePlaying(status: player.isPlaying,will: true)
        }
    }
    
    /// 下载音频时要先开始下载动画
    func beginDownloadAnimating() {
        playOrStopButton.isHidden = true
        downloadingView.isHidden = false
        downloadingView.startAnimating()
    }
    
    /// 下载结束时，关闭下载动画
    func endDownloadAnimating() {
        downloadingView.isHidden = true
        playOrStopButton.isHidden = false
        downloadingView.stopAnimating()
    }

    /// 音频player delegate 刷新进度
    func updateAudioProgress(player:AVAudioPlayer) {
        if let bar:UISlider = audioProgressView.seekBar, bar.state == .normal {
            audioProgressView.currentPlayTime = Float(player.currentTime)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        playover()
    }
    
    @objc private func willResignActive() {
        pausePlay() //暂停播放
    }
}

// MARK: - UI相关
extension SFAudioPlayerViewController {
    private func layoutNavibar() {
        navigationController?.navigationBar.backgroundColor = UIColor.clear
    }

    private func setupUI() {
        view.backgroundColor = .white
        layoutNavibar()
        // 图片
        view.addSubview(mainBackgroundImageView)
        mainBackgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.bottom.equalTo(-100)
        }
        
        view.addSubview(self.maskView)
        
        mainBackgroundImageView.addSubview(headImageView)
        headImageView.snp.makeConstraints { (make) in
            make.center.equalTo(mainBackgroundImageView)
            make.width.height.equalTo(150)
        }
        
        // 播放或暂停按钮
        view.addSubview(playOrStopButton)
        playOrStopButton.snp.makeConstraints { (make) in
            make.center.equalTo(mainBackgroundImageView)
            make.width.height.equalTo(48)
        }
        
        // 旋转的菊花
        view.addSubview(downloadingView)
        downloadingView.snp.makeConstraints { (make) in
            make.center.equalTo(playOrStopButton)
        }

        // 进度条
        audioProgressView.seekBar.addTarget(self, action: #selector(seekTime), for: .valueChanged)
        view.addSubview(audioProgressView)
        audioProgressView.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.left.right.equalTo(view).offset(0)
            make.bottom.equalTo(view).offset(-100)
        }
        
        // 底部视图
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).offset(0)
            make.height.equalTo(100)
            make.left.right.equalTo(view)
        }
        updateBottomUI()
    }
    
    private func updateBottomUI() {
        bottomView.liveTitleLabel.snp.updateConstraints{ (make) in
            make.top.equalTo(20)
        }
    }
    
}

