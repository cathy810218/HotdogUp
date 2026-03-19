//
//  MenuViewController.swift
//  HotdogUp
//
//  Created by Cathy Oun on 5/21/17.
//  Copyright © 2017 Cathy Oun. All rights reserved.
//

import UIKit
import StoreKit

class MenuViewController: UIViewController {
    var gameVC: GameViewController?
    var characterVC: StoreViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Container.shared.settings.registerDefaultsIfNeeded()
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        gameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameViewController") as? GameViewController
        guard let gameVC else { return }

        // Inject ViewModel via Container
        let container = Container.shared
        gameVC.viewModel = GameViewModel(
            analytics: container.analytics,
            ads: container.ads,
            iap: container.iap,
            settings: container.settings
        )
        gameVC.modalPresentationStyle = .fullScreen
        gameVC.isModalInPresentation = true
        present(gameVC, animated: true, completion: nil)
    }
    @IBAction func helpButtonPressed(_ sender: UIButton) {
        characterVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CharacterViewController") as? StoreViewController
        guard let characterVC else { return }
        characterVC.modalPresentationStyle = .fullScreen
        characterVC.isModalInPresentation = true
        present(characterVC, animated: true, completion: nil)
    }
    
    @IBAction func rateButtonPressed(_ sender: UIButton) {
        if let windowScene = view.window?.windowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1) {
        let trimmed = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: trimmed).scanHexInt64(&rgb)
        self.init(
            red:   CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb &   0xFF00) >>  8) / 255.0,
            blue:  CGFloat((rgb &     0xFF)      ) / 255.0,
            alpha: alpha)
    }
}
