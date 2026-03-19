//
//  InterstitialAdView.swift
//  HotdogUp
//
//  Full-screen house ad shown every N deaths, promoting "Remove Ads for $0.99".
//

import UIKit
import SnapKit

protocol InterstitialAdViewDelegate: AnyObject {
    func interstitialAdDidPressRemoveAds()
    func interstitialAdDidDismiss()
}

final class InterstitialAdView: UIView {

    weak var delegate: InterstitialAdViewDelegate?

    // MARK: - Countdown

    private let countdownDuration = 3
    private var remainingSeconds = 3
    private var timer: Timer?

    // MARK: - UI Elements

    private let overlayView = UIView()
    private let cardView = UIView()
    private let hotdogImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let removeAdsButton = UIButton(type: .system)
    private let dismissButton = UIButton(type: .system)
    private let countdownLabel = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        // Semi-transparent background
        backgroundColor = UIColor(white: 0, alpha: 0.85)

        // Card container
        cardView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }

        // Hotdog image
        let hotdogType = Container.shared.settings.selectedHotdogType
        hotdogImageView.image = UIImage(named: "\(hotdogType.name)_11")
        hotdogImageView.contentMode = .scaleAspectFit
        cardView.addSubview(hotdogImageView)
        hotdogImageView.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }

        // Title
        titleLabel.text = "Tired of interruptions?"
        titleLabel.font = UIFont(name: "MarkerFelt-Wide", size: 22)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        cardView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(hotdogImageView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }

        // Subtitle
        subtitleLabel.text = "Remove ads forever for just $0.99"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor(white: 0.8, alpha: 1)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        cardView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }

        // Remove Ads button
        removeAdsButton.setTitle("Remove Ads — $0.99", for: .normal)
        removeAdsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        removeAdsButton.setTitleColor(.white, for: .normal)
        removeAdsButton.backgroundColor = UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1)
        removeAdsButton.layer.cornerRadius = 12
        removeAdsButton.addTarget(self, action: #selector(removeAdsTapped), for: .touchUpInside)
        cardView.addSubview(removeAdsButton)
        removeAdsButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }

        // Dismiss button (initially hidden, shows after countdown)
        dismissButton.setTitle("", for: .normal)
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        dismissButton.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        dismissButton.isEnabled = false
        cardView.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(removeAdsButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-20)
            make.height.equalTo(32)
        }

        // Countdown label (top-right corner)
        countdownLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        countdownLabel.textColor = UIColor(white: 0.5, alpha: 1)
        countdownLabel.textAlignment = .center
        addSubview(countdownLabel)
        countdownLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(16)
            make.right.equalTo(-16)
        }
    }

    // MARK: - Show / Hide

    func show() {
        isHidden = false
        alpha = 0
        remainingSeconds = countdownDuration
        updateCountdownUI()
        dismissButton.isEnabled = false

        UIView.animate(withDuration: 0.3) { self.alpha = 1 }

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        remainingSeconds -= 1
        if remainingSeconds <= 0 {
            timer?.invalidate()
            timer = nil
            dismissButton.isEnabled = true
            dismissButton.setTitle("No thanks, continue", for: .normal)
            countdownLabel.text = ""
        } else {
            updateCountdownUI()
        }
    }

    private func updateCountdownUI() {
        countdownLabel.text = "\(remainingSeconds)s"
        dismissButton.setTitle("Wait \(remainingSeconds)s...", for: .normal)
    }

    private func hide(completion: (() -> Void)? = nil) {
        timer?.invalidate()
        timer = nil
        UIView.animate(withDuration: 0.2, animations: { self.alpha = 0 }) { _ in
            self.isHidden = true
            completion?()
        }
    }

    // MARK: - Actions

    @objc private func removeAdsTapped() {
        delegate?.interstitialAdDidPressRemoveAds()
    }

    @objc private func dismissTapped() {
        hide { [weak self] in
            self?.delegate?.interstitialAdDidDismiss()
        }
    }
}
