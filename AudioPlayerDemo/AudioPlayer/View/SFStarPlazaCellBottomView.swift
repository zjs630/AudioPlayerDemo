//
//  SFStarPlazaCellBottomView.swift
//
//  Created by JingshunZhang on 2017/6/10.
//  Copyright © 2017年 ix86. All rights reserved.
//

import UIKit
import SnapKit

class SFStarPlazaCellBottomView: UIView {

    // 直播标题Label
    lazy var liveTitleLabel: UILabel = {
        let tempLabel = UILabel.sf_label(font: 15, color: 0x333333)
        tempLabel.numberOfLines = 2
        return tempLabel
    }()

    // 房间头像
    lazy var roomTitleImageView: UIImageView = {
        let tempView = UIImageView()
        tempView.contentMode = .scaleAspectFill
        tempView.image = UIImage(named: "video_head_default")
        return tempView
    }()
    // 房间标题
    var roomTitleLabel: UILabel = UILabel.sf_label(font: 13, color: 0x999999)
    
    // 房间日期文本
    lazy var roomDateLabel: UILabel = UILabel.sf_label(font: 11, color: 0x999999, alignment:.right)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        // 3.添加直播标题
        addSubview(liveTitleLabel)
        liveTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(10)
        }
        
        // 4 添加房间头像
        addSubview(roomTitleImageView)
        roomTitleImageView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(liveTitleLabel.snp.bottom).offset(10)
            make.width.height.equalTo(27)
        }
        
        // 6 添加时间标题
        addSubview(roomDateLabel)
        roomDateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(roomTitleImageView)
            make.width.equalTo(104)
        }
        // 5 添加房间标题
        addSubview(roomTitleLabel)
        roomTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(roomTitleImageView.snp.right).offset(9)
            make.centerY.equalTo(roomTitleImageView)
            make.right.greaterThanOrEqualTo(roomDateLabel.snp.left).offset(-5)
        }

    }
    
    func setupData(model: SquareInterview) {
        liveTitleLabel.text = model.audioTitle
        roomTitleImageView.sf_setCircleImage(urlString: model.avatar, placeholderImage: UIImage(named: "video_head_default"), size: CGSize(width:27, height:27))
        roomTitleLabel.text = model.nickName
        roomDateLabel.text = model.timeStr
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        

}
