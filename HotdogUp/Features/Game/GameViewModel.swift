//
//  GameViewModel.swift
//  HotdogUp
//
//  Created by Cathy Oun on 9/18/25.
//  Copyright © 2025 Cathy Oun. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - Game State

enum PlayState {
    case idle       // before first game
    case playing
    case paused
    case gameOver
}

// MARK: - GameViewModel

final class GameViewModel {
    private let analytics: Analytics
    private let ads: Ads
    let iap: IAP
    let settings: GameSettings

    // MARK: - Observable state

    private(set) var playState: PlayState = .idle {
        didSet { onPlayStateChanged?(playState) }
    }

    private(set) var score: Int = 0 {
        didSet {
            onScoreChanged?(score)
            // Persist highest score
            if score > settings.highestScore {
                settings.highestScore = score
            }
        }
    }

    // MARK: - Ad frequency

    private let adInterval = 5  // show ad every N deaths

    // MARK: - Callbacks (view binding)

    var onPlayStateChanged: ((PlayState) -> Void)?
    var onScoreChanged: ((Int) -> Void)?
    var onShowShare: ((String, UIImage?) -> Void)?
    var onShowAd: (() -> Void)?
    var onIAPCompleted: ((Bool) -> Void)?
    var onIAPError: ((String) -> Void)?

    // MARK: - Init

    init(analytics: Analytics, ads: Ads, iap: IAP, settings: GameSettings) {
        self.analytics = analytics
        self.ads = ads
        self.iap = iap
        self.settings = settings
    }

    // MARK: - Game Lifecycle

    func startGame() {
        score = 0
        playState = .playing
        analytics.log(.gameStarted)
        ads.preloadInterstitial()
    }

    func incrementScore(by delta: Int = 1) {
        score += delta
    }

    func gameOver() {
        playState = .gameOver
        analytics.log(.gameOver(score: score))

        // TODO: Re-enable when Google AdMob is integrated
        // Track deaths and show ad every N deaths (unless ads removed)
        // settings.deathCount += 1
        // if !settings.hasRemovedAds && settings.deathCount % adInterval == 0 {
        //     onShowAd?()
        // }
    }

    func pause() {
        guard playState == .playing else { return }
        playState = .paused
    }

    func resume() {
        guard playState == .paused else { return }
        playState = .playing
    }

    // MARK: - Audio Toggles

    func toggleMusic() {
        settings.isMusicOn.toggle()
    }

    func toggleSoundEffect() {
        settings.isSoundEffectOn.toggle()
    }

    // MARK: - Share

    func share(screenshot: UIImage?) {
        let text = "🌭 I just hit \(score) on HotdogUp! Beat it! 🌭"
        onShowShare?(text, screenshot)
    }

    // MARK: - IAP (async, using StoreKit 2 via Container)

    func buyRemoveAds() async {
        do {
            let txn = try await iap.purchaseRemoveAds()
            if txn != nil {
                settings.hasRemovedAds = true
                await MainActor.run { onIAPCompleted?(true) }
            } else {
                await MainActor.run { onIAPCompleted?(false) }
            }
        } catch {
            await MainActor.run { onIAPError?(error.localizedDescription) }
        }
    }

    func restorePurchases() async {
        let purchased = await iap.hasPurchasedRemoveAds()
        if purchased {
            settings.hasRemovedAds = true
        }
        await MainActor.run { onIAPCompleted?(purchased) }
    }
}

import UIKit   // for UIImage in share callback
