//
//  GameViewController.swift
//  HotdogUp
//
//  Created by Cathy Oun on 5/21/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import UIKit
import SpriteKit
import SnapKit

class GameViewController: UIViewController {

    // MARK: - Dependencies (injected by GameCoordinator)

    var viewModel: GameViewModel!

    // MARK: - UI

    private var pauseView = PauseView()
    private var pauseBtn = UIButton()
    private var tutorialView = TutorialView()
    private var gameoverView = GameoverView()
    private var activityIndicator = UIActivityIndicatorView()

    private var gameScene: GameScene!
    private var skView = SKView()

    private var settings: GameSettings { viewModel.settings }

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentGameScene()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        isModalInPresentation = true

        // Register default audio preferences on first launch
        settings.registerDefaultsIfNeeded()

        // Create the SpriteKit game scene, inject settings
        gameScene = GameScene(size: view.bounds.size)
        gameScene.scaleMode = .resizeFill
        gameScene.gameSceneDelegate = self
        gameScene.settings = settings

        setupPauseView()
        setupGameOverView()
        setupPauseButton()
        setupTutorialView()
        setupActivityIndicator()
        bindViewModel()

        // Show tutorial on first launch
        if !settings.doNotShowTutorial {
            tutorialView.isHidden = false
            gameScene.isUserInteractionEnabled = false
            tutorialView.showCheckbox = true
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pauseButtonDidPressed),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        viewModel.startGame()
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.onScoreChanged = { [weak self] score in
            // GameScene already updates its own label; ViewModel persists highest.
            _ = score
            self?.updateIAPButtonStates()
        }

        viewModel.onShowShare = { [weak self] text, image in
            self?.presentShareSheet(text: text, image: image)
        }

        viewModel.onIAPCompleted = { [weak self] success in
            self?.activityIndicator.stopAnimating()
            if success {
                self?.gameoverView.removeAdsBtn.isEnabled = false
                self?.gameoverView.restoreIAPBtn.isEnabled = false
            } else {
                // User cancelled or no transaction
                self?.gameoverView.removeAdsBtn.isEnabled = true
            }
        }

        viewModel.onIAPError = { [weak self] message in
            self?.activityIndicator.stopAnimating()
            self?.showAlert(title: "Error", message: message)
        }
    }

    // MARK: - Scene Presentation

    private func presentGameScene() {
        guard let v = view as? SKView else { return }
        skView = v
        skView.ignoresSiblingOrder = true
        skView.presentScene(gameScene)
    }

    // MARK: - UI Setup

    private func setupPauseButton() {
        pauseBtn = UIButton(type: .custom)
        let pauseImg = UIImage(named: "button_pause")
        pauseBtn.setBackgroundImage(pauseImg, for: .normal)
        view.addSubview(pauseBtn)
        pauseBtn.addTarget(self, action: #selector(pauseButtonDidPressed), for: .touchUpInside)
        pauseBtn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(30)
            if let w = pauseImg?.size.width {
                make.width.height.equalTo(w)
            } else {
                make.width.height.equalTo(44)
            }
        }
    }

    private func setupPauseView() {
        pauseView = PauseView(frame: view.frame)
        view.addSubview(pauseView)
        pauseView.isHidden = true
        pauseView.delegate = self
    }

    private func setupGameOverView() {
        gameoverView = GameoverView(frame: view.frame)
        view.addSubview(gameoverView)
        gameoverView.isHidden = true
        gameoverView.delegate = self
    }

    private func setupTutorialView() {
        tutorialView = TutorialView(frame: view.frame, settings: settings)
        view.addSubview(tutorialView)
        tutorialView.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDismissTutorialView))
        tutorialView.addGestureRecognizer(tap)
    }

    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc private func pauseButtonDidPressed() {
        guard gameoverView.isHidden else { return }
        settings.resumeSpeed = Float(gameScene.speed)
        gameScene.gamePaused = true
        MusicPlayer.player.pause()
        pauseView.isHidden = false
        pauseView.isSoundOn = settings.isSoundEffectOn
        pauseView.isBackgroundMusicOn = settings.isMusicOn
        gameScene.isUserInteractionEnabled = false
        pauseBtn.isEnabled = false
        viewModel.pause()
    }

    @objc private func tapToDismissTutorialView() {
        tutorialView.isHidden = true
        gameScene.isUserInteractionEnabled = true
    }

    private func resetGame() {
        gameScene.resetGameScene()
        pauseView.isHidden = true
        pauseBtn.isEnabled = true
        viewModel.startGame()
    }

    private func returnToMenu() {
        gameScene.removeAllChildren()
        gameScene.removeFromParent()
        skView.presentScene(nil)
        MusicPlayer.player.stop()
        dismiss(animated: true, completion: nil)
    }

    // MARK: - IAP Helpers

    private func updateIAPButtonStates() {
        let purchased = settings.hasRemovedAds
        gameoverView.removeAdsBtn.isEnabled = !purchased
        gameoverView.restoreIAPBtn.isEnabled = !purchased
    }

    // MARK: - Sharing

    private func presentShareSheet(text: String, image: UIImage?) {
        var items: [Any] = [text]
        if let img = image { items.append(img) }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact,
                                            .copyToPasteboard, .openInIBooks, .postToVimeo,
                                            .saveToCameraRoll, .print]

        if UIDevice.current.userInterfaceIdiom == .pad {
            activityVC.popoverPresentationController?.sourceView = gameoverView.shareBtn
            activityVC.popoverPresentationController?.sourceRect = CGRect(
                x: gameoverView.shareBtn.bounds.width / 2,
                y: gameoverView.shareBtn.bounds.height, width: 0, height: 0)
            activityVC.popoverPresentationController?.permittedArrowDirections = .up
        }
        present(activityVC, animated: true)
    }

    // MARK: - Alerts

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Appearance

    override var shouldAutorotate: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }

    override var prefersStatusBarHidden: Bool { true }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
}

// MARK: - GameSceneDelegate

extension GameViewController: GameSceneDelegate {

    func gameSceneDidEnd() {
        gameoverView.isHidden = false
        pauseBtn.isEnabled = false
        updateIAPButtonStates()
        viewModel.gameOver()
    }

    func gameSceneDidScore(_ newScore: Int) {
        // Scene owns the real-time score during physics; sync it to the ViewModel for persistence
        let delta = newScore - viewModel.score
        if delta > 0 {
            viewModel.incrementScore(by: delta)
        }
    }
}

// MARK: - PauseViewDelegate

extension GameViewController: PauseViewDelegate {

    func pauseViewDidPressHomeButton() {
        returnToMenu()
    }

    func pauseViewDidPressResumeButton() {
        gameScene.speed = CGFloat(settings.resumeSpeed)
        gameScene.gamePaused = false
        if settings.isMusicOn {
            MusicPlayer.resumePlay()
        }
        pauseView.isHidden = true
        pauseBtn.isEnabled = true
        gameScene.isUserInteractionEnabled = true
        viewModel.resume()
    }

    func pauseViewDidPressReplayButton() {
        resetGame()
    }

    func pauseViewDidPressSoundButton() {
        viewModel.toggleSoundEffect()
        pauseView.isSoundOn = settings.isSoundEffectOn
    }

    func pauseViewDidPressMusicButton() {
        viewModel.toggleMusic()
        pauseView.isBackgroundMusicOn = settings.isMusicOn
        // Apply immediately
        settings.isMusicOn ? MusicPlayer.resumePlay() : MusicPlayer.player.pause()
    }

    func pauseViewDidPressTutorialButton() {
        tutorialView.isHidden = false
        tutorialView.showCheckbox = false
        gameScene.isUserInteractionEnabled = false
    }
}

// MARK: - GameoverViewDelegate

extension GameViewController: GameoverViewDelegate {

    func gameoverViewDidPressShareButton() {
        var screenshot: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            screenshot = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        viewModel.share(screenshot: screenshot)
    }

    func gameoverViewDidPressReplayButton() {
        gameoverView.isHidden = true
        resetGame()
    }

    func gameoverViewDidPressHomeButton() {
        returnToMenu()
    }

    func gameoverViewDidPressRemoveAds() {
        activityIndicator.startAnimating()
        Task { await viewModel.buyRemoveAds() }
    }

    func gameoverViewDidPressRestore() {
        activityIndicator.startAnimating()
        Task { await viewModel.restorePurchases() }
    }
}

