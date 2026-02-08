//
//  Analytics.swift
//  HotdogUp
//
//  Created by Cathy Oun on 9/18/25.
//  Copyright © 2025 Cathy Oun. All rights reserved.
//

protocol Analytics {
    func log(_ event: AnalyticsEvent)
}


enum AnalyticsEvent {
    case appLaunched
    case gameStarted
    case gameOver(score: Int)
    case iapPurchased(productID: String)
}


final class NoopAnalyticsService: Analytics {
    func log(_ event: AnalyticsEvent) { /* no‑op */ }
}
