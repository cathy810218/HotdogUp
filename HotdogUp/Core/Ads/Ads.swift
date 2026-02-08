//
//  Untitled.swift
//  HotdogUp
//
//  Created by Cathy Oun on 9/18/25.
//  Copyright © 2025 Cathy Oun. All rights reserved.
//

import UIKit


protocol Ads {
    func preloadInterstitial()
    func showInterstitial(from viewController: UIViewController)
}


final class NoopAdsService: Ads {
    func preloadInterstitial() {}
    func showInterstitial(from: UIViewController) {}
}
