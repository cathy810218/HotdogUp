//
//  TutorialView.swift
//  HotdogUp
//
//  Created by Cathy Oun on 8/16/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import UIKit
import SnapKit

class TutorialView: UIView {
    private var checkbox = Checkbox()
    private var label = UILabel()
    private var settings: GameSettings?

    var showCheckbox = true {
        didSet {
            checkbox.isHidden = !showCheckbox
            label.isHidden = !showCheckbox
        }
    }

    /// Use this initializer from GameViewController which injects settings.
    convenience init(frame: CGRect, settings: GameSettings) {
        self.init(frame: frame)
        self.settings = settings
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(hex: "#000000", alpha: 0.8)

        let jumpAreaView = UIView()
        addSubview(jumpAreaView)
        jumpAreaView.snp.makeConstraints { make in
            make.center.height.equalTo(self)
            make.width.equalTo(self).multipliedBy(3.0 / 5.0)
        }
        jumpAreaView.backgroundColor = UIColor(hex: "#2C2C2C", alpha: 0.5)

        let imageView = UIImageView(image: UIImage(named: "tutorial"))
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        createCheckbox()
    }

    private func createCheckbox() {
        checkbox = Checkbox(frame: CGRect(x: 50, y: 50, width: 25, height: 25))
        addSubview(checkbox)
        checkbox.borderColor = .white
        checkbox.backgroundColor = .clear
        checkbox.borderWidth = 3.0
        checkbox.borderStyle = .circle
        checkbox.checkmarkStyle = .tick
        checkbox.checkmarkColor = .white
        checkbox.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(-80)
            make.centerY.equalTo(self)
            make.height.width.equalTo(UIDevice.current.userInterfaceIdiom == .pad ? 30 : 25)
        }
        checkbox.addTarget(self, action: #selector(checkboxValueChanged(sender:)), for: .valueChanged)

        label = UILabel()
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(checkbox.snp.right).offset(10)
            make.centerY.height.equalTo(checkbox)
        }
        label.textColor = .white
        label.text = "Do not show this again"
        checkbox.isHidden = false
        label.isHidden = false
        label.font = UIFont(name: "BradleyHandITCTT-Bold", size: UIDevice.current.userInterfaceIdiom == .pad ? 22 : 18)
    }

    @objc private func checkboxValueChanged(sender: Checkbox) {
        settings?.doNotShowTutorial = sender.isChecked
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
