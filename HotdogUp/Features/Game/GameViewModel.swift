//
//  GameViewModel.swift
//  HotdogUp
//
//  Created by Cathy Oun on 9/18/25.
//  Copyright © 2025 Cathy Oun. All rights reserved.
//

import Foundation
import StoreKit

final class GameViewModel {
    private let analytics: Analytics
    private let ads: Ads
    private let iap: IAP
    private let persistence: Persistence


    private(set) var score: Int = 0 {
        didSet { onScoreChanged?(score) }
    }


    var onScoreChanged: ((Int) -> Void)?
    var onShowShare: ((String) -> Void)?


    init(analytics: Analytics, ads: Ads, iap: IAP, persistence: Persistence) {
        self.analytics = analytics
        self.ads = ads
        self.iap = iap
        self.persistence = persistence
    }


    func startGame() {
        score = 0
        analytics.log(.gameStarted)
        ads.preloadInterstitial()
    }


    func incrementScore(by delta: Int = 1) {
        score += delta
    }


    func gameOver() {
        analytics.log(.gameOver(score: score))
    }


    func share() {
        let text = """
        🌭 I just hit \(score) on HotdogUp! Beat it! 🌭
        """
        onShowShare?(text)
    }


    func buyRemoveAds() async {
        _ = try? await iap.purchaseRemoveAds()
    }
}
