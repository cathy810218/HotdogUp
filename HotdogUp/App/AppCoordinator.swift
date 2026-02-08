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


private var gameCoordinator: GameCoordinator?


init(window: UIWindow, container: Container = .shared) {
self.window = window
self.container = container
}


func start() {
let nav = UINavigationController()
window.rootViewController = nav
window.makeKeyAndVisible()


let gameCoordinator = GameCoordinator(navigation: nav, container: container)
self.gameCoordinator = gameCoordinator
gameCoordinator.start()
}
}
