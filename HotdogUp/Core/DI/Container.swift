//
//  Container.swift
//  HotdogUp
//
//  Created by Cathy Oun on 9/18/25.
//  Copyright © 2025 Cathy Oun. All rights reserved.
//

import Foundation

final class Container {
    static let shared = Container()


    let analytics: Analytics
    let ads: Ads
    let iap: IAP
//    let networking: Networking
    let persistence: Persistence


    init(analytics: Analytics? = nil, ads: Ads? = nil, iap: IAP? = nil, persistence: Persistence? = nil) {
        self.analytics = analytics ?? NoopAnalyticsService()
        self.ads = ads ?? NoopAdsService()
        self.iap = iap ?? StoreKit2Service()
//        self.networking = networking ?? URLSessionNetwork()
        self.persistence = persistence ?? UserDefaultsPersistence()
    }
}
