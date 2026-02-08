//
//  PauseView.swift
//  HotdogUp
//
//  Created by Cathy Oun on 8/17/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import UIKit
import SnapKit
protocol PauseViewDelegate: AnyObject {
    func pauseViewDidPressResumeButton()
    func pauseViewDidPressReplayButton()
    func pauseViewDidPressMusicButton()
    func pauseViewDidPressHomeButton()
    func pauseViewDidPressSoundButton()
    func pauseViewDidPressTutorialButton()
}

class PauseView: UIView {
    weak var delegate: PauseViewDelegate?
    private var musicBtn = UIButton()
    private var soundBtn = UIButton()
    var isBackgroundMusicOn = UserDefaults.standard.bool(forKey: "UserDefaultsIsMusicOnKey") {
        didSet {
            musicBtn.setBackgroundImage(UIImage(named: isBackgroundMusicOn ? "button_music" : "button_musicoff"), for: .normal)
        }
    }
    var isSoundOn = UserDefaults.standard.bool(forKey: "UserDefaultsIsSoundEffectOnKey") {
        didSet {
            soundBtn.setBackgroundImage(UIImage(named: isSoundOn ? "button_sound" : "button_soundoff"), for: .normal)
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        let img = UIImage(named: "button_resume")

        self.backgroundColor = UIColor(hex: "#000000", alpha: 0.5)
        
        let buttonsView = UIView()
        self.addSubview(buttonsView)
        buttonsView.snp.makeConstraints { (make) in
            make.centerY.centerX.equalTo(self)
            make.width.equalTo(3 * (img?.size.height)! + 16)
            make.height.equalTo(2 * (img?.size.height)! + 8)
        }
        
        // home button
        let homeBtn = UIButton(type: .custom)
        homeBtn.setBackgroundImage(UIImage(named: "button_home"), for: .normal)
        homeBtn.layer.cornerRadius = 5.0
        homeBtn.layer.masksToBounds = true
        buttonsView.addSubview(homeBtn)
        homeBtn.snp.makeConstraints { (make) in
            make.top.left.equalTo(buttonsView)
        }
        homeBtn.addTarget(self, action: #selector(returnToMenu), for: .touchUpInside)
        
        
        // resume button
        let resumeBtn = UIButton(type: .custom)
        resumeBtn.setBackgroundImage(UIImage(named: "button_resume"), for: .normal)
        resumeBtn.layer.cornerRadius = 5.0
        resumeBtn.layer.masksToBounds = true
        buttonsView.addSubview(resumeBtn)
        resumeBtn.snp.makeConstraints { (make) in
            make.top.right.equalTo(buttonsView)
        }
        resumeBtn.addTarget(self, action: #selector(resume), for: .touchUpInside)
                
        // replay button
        let replayBtn = UIButton(type: .custom)
        replayBtn.setBackgroundImage(UIImage(named: "button_replay"), for: .normal)
        replayBtn.layer.cornerRadius = 5.0
        replayBtn.layer.masksToBounds = true
        buttonsView.addSubview(replayBtn)
        replayBtn.snp.makeConstraints { (make) in
            make.top.centerX.equalTo(buttonsView)
        }
        replayBtn.addTarget(self, action: #selector(resetGame), for: .touchUpInside)
        // sound button
        soundBtn = UIButton(type: .custom)
        soundBtn.setBackgroundImage(UIImage(named: UserDefaults.standard.bool(forKey: "UserDefaultsIsSoundEffectOnKey") ? "button_sound" : "button_soundoff"), for: .normal)
        soundBtn.layer.cornerRadius = 5.0
        soundBtn.layer.masksToBounds = true
        buttonsView.addSubview(soundBtn)
        soundBtn.snp.makeConstraints { (make) in
            make.left.bottom.equalTo(buttonsView)
        }
        soundBtn.addTarget(self, action: #selector(soundSwitch), for: .touchUpInside)
        
        // music button
        musicBtn = UIButton(type: .custom)
        musicBtn.setBackgroundImage(UIImage(named: UserDefaults.standard.bool(forKey: "UserDefaultsIsMusicOnKey") ? "button_music" : "button_musicoff"), for: .normal)
        musicBtn.layer.cornerRadius = 5.0
        musicBtn.layer.masksToBounds = true
        buttonsView.addSubview(musicBtn)
        musicBtn.snp.makeConstraints { (make) in
            make.bottom.centerX.equalTo(buttonsView)
        }
        musicBtn.addTarget(self, action: #selector(musicSwitch), for: .touchUpInside)
        
        // share button
        let shareBtn = UIButton(type: .custom)
        shareBtn.setBackgroundImage(UIImage(named: "button_info"), for: .normal)
        shareBtn.layer.cornerRadius = 5.0
        shareBtn.layer.masksToBounds = true
        buttonsView.addSubview(shareBtn)
        shareBtn.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(buttonsView)
        }
        shareBtn.addTarget(self, action: #selector(showTutorialView), for: .touchUpInside)
    }
    
    @objc func returnToMenu() {
        delegate?.pauseViewDidPressHomeButton()
    }
    
    @objc func resume() {
        delegate?.pauseViewDidPressResumeButton()
    }
    
    @objc func resetGame() {
        delegate?.pauseViewDidPressReplayButton()
    }
    
    @objc func soundSwitch() {
        delegate?.pauseViewDidPressSoundButton()
    }
    
    @objc func musicSwitch() {
        delegate?.pauseViewDidPressMusicButton()
    }
    
    @objc func showTutorialView() {
        delegate?.pauseViewDidPressTutorialButton()
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
