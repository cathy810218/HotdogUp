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
        self.backgroundColor = UIColor(hex: "#000000", alpha: 0.5)

        // Character type is read via Container settings; fallback to .mrjj
        let currentHotdogType = Container.shared.settings.selectedHotdogType
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
        
        removeAdsBtn = UIButton(type: .system)
        removeAdsBtn.setTitle("Remove Ads", for: .normal)
        removeAdsBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        removeAdsBtn.setTitleColor(.white, for: .normal)
        removeAdsBtn.setTitleColor(UIColor(white: 0.5, alpha: 1), for: .disabled)
        removeAdsBtn.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1)
        removeAdsBtn.layer.cornerRadius = 8
        self.addSubview(removeAdsBtn)
        removeAdsBtn.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.bottom.equalTo(-12)
            make.width.equalTo(100)
            make.height.equalTo(36)
        }
        removeAdsBtn.addTarget(self, action: #selector(removeAdsPressed), for: .touchUpInside)
        // TODO: Re-enable when Google AdMob is integrated
        removeAdsBtn.isHidden = true

        restoreIAPBtn = UIButton(type: .system)
        restoreIAPBtn.setTitle("Restore", for: .normal)
        restoreIAPBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        restoreIAPBtn.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .normal)
        restoreIAPBtn.setTitleColor(UIColor(white: 0.5, alpha: 1), for: .disabled)
        self.addSubview(restoreIAPBtn)
        restoreIAPBtn.snp.makeConstraints { make in
            make.right.equalTo(removeAdsBtn.snp.left).offset(-8)
            make.centerY.equalTo(removeAdsBtn)
            make.width.equalTo(60)
            make.height.equalTo(36)
        }
        restoreIAPBtn.addTarget(self, action: #selector(restoreIAPPressed), for: .touchUpInside)
        // TODO: Re-enable when Google AdMob is integrated
        restoreIAPBtn.isHidden = true
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
