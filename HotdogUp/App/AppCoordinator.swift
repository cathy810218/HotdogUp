//
//  AppCoordinator.swift
//  HotdogUp
//
//  Created by Cathy Oun on 9/18/25.
//  Copyright © 2025 Cathy Oun. All rights reserved.
//

import UIKit


final class AppCoordinator {
private let window: UIWindow
private let container: Container


init(window: UIWindow, container: Container = .shared) {
self.window = window
self.container = container
}


func start() {
let storyboard = UIStoryboard(name: "Main", bundle: nil)
let menuVC = storyboard.instantiateInitialViewController()!
window.rootViewController = menuVC
window.makeKeyAndVisible()
}
}
