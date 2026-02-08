//
//  GameCoordinator.swift
//  HotdogUp
//
//  Created by Cathy Oun on 9/18/25.
//  Copyright © 2025 Cathy Oun. All rights reserved.
//

import UIKit

final class GameCoordinator {
    private let navigation: UINavigationController
    private let container: Container

    init(navigation: UINavigationController, container: Container) {
        self.navigation = navigation
        self.container = container
    }


    func start() {
        // GameViewController currently uses its own setup; instantiate directly.
        let vc = GameViewController()
        navigation.setViewControllers([vc], animated: false)
    }
}
