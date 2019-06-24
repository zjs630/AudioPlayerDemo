//
//  SFAudioProgressView.swift
//  AudioPlayerDemo
//
//  Created by 张京顺 on 2019/6/24.
//  Copyright © 2019 ix86. All rights reserved.
//

import UIKit
import SnapKit

class SFAudioProgressView: UIView {
    
    var currentTimeLabel: UILabel!
    var totalTimeLabel: UILabel!
    var seekBar: UISlider!
    
    var currentPlayTime: Float = 0 {
        willSet {
            currentTimeLabel.text = String.sf_convertMedia(time: Int32(newValue))
            seekBar.value = newValue
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playoverStatus() {
        currentTimeLabel.text = "00:00"
        seekBar.value = 0
    }
    
    private func setupUI() {
        // 当前时间进度Label
        currentTimeLabel = UILabel.sf_label(font: 12, color: 0xffffff)
        addSubview(currentTimeLabel)
        currentTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(self)
        }
        
        // 进度条
        seekBar = UISlider()
        seekBar.minimumValue = 0
        seekBar.value = 0
        seekBar.isContinuous = false
        //seekBar.maximumValue = Float(player.player!.duration);
        seekBar.minimumTrackTintColor = .white
        seekBar.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        seekBar.setThumbImage(UIImage(named: "audio_slider_thumb"), for: .normal)
        addSubview(seekBar)
        seekBar.snp.makeConstraints { (make) in
            make.left.equalTo(currentTimeLabel.snp.right).offset(6)
            make.centerY.equalTo(self)
        }
        
        // 音频总长时间Label
        totalTimeLabel = UILabel.sf_label(font: 12, color: 0xffffff)
        addSubview(totalTimeLabel)
        totalTimeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-10)
            make.centerY.equalTo(self)
            make.left.equalTo(seekBar.snp.right).offset(6)
        }
        
    }
}

