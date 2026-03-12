//
//  Persistence.swift
//  HotdogUp
//
//  Created by Cathy Oun on 9/18/25.
//  Copyright © 2025 Cathy Oun. All rights reserved.
//

import Foundation

// MARK: - Centralized UserDefaults Keys

enum UserDefaultsKey {
    static let highestScore = "UserDefaultsHighestScoreKey"
    static let selectedCharacter = "UserDefaultsSelectCharacterKey"
    static let isMusicOn = "UserDefaultsIsMusicOnKey"
    static let isSoundEffectOn = "UserDefaultsIsSoundEffectOnKey"
    static let doNotShowTutorial = "UserDefaultsDoNotShowTutorialKey"
    static let purchased = "UserDefaultsPurchaseKey"
    static let resumeSpeed = "UserDefaultsResumeSpeedKey"
}

// MARK: - Persistence Protocol

protocol Persistence {
    func set(_ value: Any?, forKey key: String)
    func int(forKey key: String) -> Int
    func bool(forKey key: String) -> Bool
    func float(forKey key: String) -> Float
    func object(forKey key: String) -> Any?
}


final class UserDefaultsPersistence: Persistence {
    private let defaults = UserDefaults.standard
    func set(_ value: Any?, forKey key: String) { defaults.set(value, forKey: key) }
    func int(forKey key: String) -> Int { defaults.integer(forKey: key) }
    func bool(forKey key: String) -> Bool { defaults.bool(forKey: key) }
    func float(forKey key: String) -> Float { defaults.float(forKey: key) }
    func object(forKey key: String) -> Any? { defaults.object(forKey: key) }
}
