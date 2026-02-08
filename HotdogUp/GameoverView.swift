//
//  GameoverView.swift
//  HotdogUp
//
//  Created by Cathy Oun on 8/17/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import UIKit
import SnapKit

protocol GameoverViewDelegate: AnyObject {
    func gameoverViewDidPressShareButton()
    func gameoverViewDidPressReplayButton()
    func gameoverViewDidPressHomeButton()
    func gameoverViewDidPressRemoveAds()
    func gameoverViewDidPressRestore()
}

class GameoverView: UIView {
    weak var delegate: GameoverViewDelegate?
    var removeAdsBtn = UIButton()
    var restoreIAPBtn = UIButton()
    var shareBtn = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
//        gameoverView = UIView()
//        self.view.addSubview(gameoverView)
//        gameoverView.isHidden = true
//        gameoverView.snp.makeConstraints { (make) in
//            make.edges.equalTo(self.view!)
//        }
        self.backgroundColor = UIColor(hex: "#000000", alpha: 0.5)
        
        let selectedRaw = UserDefaults.standard.integer(forKey: "UserDefaultsSelectCharacterKey")
        let currentHotdogType = Hotdog.HotdogType(rawValue: selectedRaw) ?? .mrjj
        let gameoverHotdogView = UIImageView(image: UIImage(named: "\(currentHotdogType.name)_gameover"))
        let gameoverImg = UIImage(named: "gameover")
        
        let gameoverBackgroundView = UIImageView(image: UIImage(named: "gameover_background"))
        self.addSubview(gameoverBackgroundView)
        gameoverBackgroundView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            if let w = gameoverImg?.size.width {
                make.width.equalTo(w)
            } else {
                make.width.equalTo(200)
            }
            make.height.equalTo(gameoverHotdogView.frame.size.height * 2)
        }
        gameoverBackgroundView.layer.cornerRadius = 10.0
        gameoverBackgroundView.layer.masksToBounds = true
        
        
        let gameoverTitleView = UIImageView(image: gameoverImg)
        self.addSubview(gameoverTitleView)
        gameoverTitleView.snp.makeConstraints { (make) in
            make.centerX.equalTo(gameoverBackgroundView)
            make.top.left.equalTo(gameoverBackgroundView).offset(10)
//            make.right.equalTo(gameoverBackgroundView).offset(-10)
        }
        
        self.addSubview(gameoverHotdogView)
        gameoverHotdogView.snp.makeConstraints { (make) in
            make.center.equalTo(gameoverBackgroundView)
        }
        
        let homeBtn = UIButton(type: .custom)
        homeBtn.setBackgroundImage(UIImage(named: "gameover_home"), for: .normal)
        self.addSubview(homeBtn)
        homeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(gameoverBackgroundView)
            make.bottom.equalTo(gameoverBackgroundView).offset(-12)
        }
        homeBtn.addTarget(self, action: #selector(returnToMenu), for: .touchUpInside)
        
        let replayBtn = UIButton(type: .custom)
        replayBtn.setBackgroundImage(UIImage(named: "gameover_replay"), for: .normal)
        self.addSubview(replayBtn)
        replayBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(gameoverBackgroundView)
            make.bottom.equalTo(homeBtn)
        }
        replayBtn.addTarget(self, action: #selector(resetGameToShowAds), for: .touchUpInside)
        replayBtn.tag = 0 // dead
        
        shareBtn = UIButton(type: .custom)
        shareBtn.setBackgroundImage(UIImage(named: "gameover_share"), for: .normal)
        self.addSubview(shareBtn)
        shareBtn.snp.makeConstraints { (make) in
            make.right.equalTo(gameoverBackgroundView)
            make.bottom.equalTo(homeBtn)
        }
        shareBtn.addTarget(self, action: #selector(share), for: .touchUpInside)
        
        removeAdsBtn = UIButton(type: .custom)
        self.addSubview(removeAdsBtn)
        removeAdsBtn.setBackgroundImage(UIImage(named: "remove_ads"), for: .normal)
        removeAdsBtn.snp.makeConstraints({ (make) in
            make.right.bottom.equalTo(-12)
            make.width.height.equalTo(50)
        })
        removeAdsBtn.addTarget(self, action: #selector(removeAdsPressed), for: .touchUpInside)
        removeAdsBtn.isEnabled = false
        
        restoreIAPBtn = UIButton(type: .custom)
        self.addSubview(restoreIAPBtn)
        restoreIAPBtn.setBackgroundImage(UIImage(named: "restore"), for: .normal)
        restoreIAPBtn.snp.makeConstraints { (make) in
            make.right.equalTo(removeAdsBtn.snp.left).offset(-12)
            make.bottom.equalTo(-12)
            make.width.height.equalTo(50)
        }
        restoreIAPBtn.addTarget(self, action: #selector(restoreIAPPressed), for: .touchUpInside)
        restoreIAPBtn.isEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func returnToMenu() {
        delegate?.gameoverViewDidPressHomeButton()
    }
    
    @objc func resetGameToShowAds() {
        delegate?.gameoverViewDidPressReplayButton()
    }
    
    @objc func share() {
        delegate?.gameoverViewDidPressShareButton()
    }
    
    @objc func removeAdsPressed() {
        delegate?.gameoverViewDidPressRemoveAds()
    }
    
    @objc func restoreIAPPressed() {
        delegate?.gameoverViewDidPressRestore()
    }

}
