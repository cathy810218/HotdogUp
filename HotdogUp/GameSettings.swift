//
//  GameSettings.swift
//  HotdogUp
//
//  Centralizes all user preferences (music, sound, tutorial, character, etc.)
//  through the Persistence abstraction instead of scattering UserDefaults
//  calls throughout the codebase.
//

import Foundation

final class GameSettings {
    private let persistence: Persistence

    init(persistence: Persistence) {
        self.persistence = persistence
    }

    // MARK: - Audio

    var isMusicOn: Bool {
        get { persistence.bool(forKey: UserDefaultsKey.isMusicOn) }
        set { persistence.set(newValue, forKey: UserDefaultsKey.isMusicOn) }
    }

    var isSoundEffectOn: Bool {
        get { persistence.bool(forKey: UserDefaultsKey.isSoundEffectOn) }
        set { persistence.set(newValue, forKey: UserDefaultsKey.isSoundEffectOn) }
    }

    /// Ensures music & sound keys exist with `true` defaults on first launch.
    func registerDefaultsIfNeeded() {
        if persistence.object(forKey: UserDefaultsKey.isMusicOn) == nil {
            persistence.set(true, forKey: UserDefaultsKey.isMusicOn)
        }
        if persistence.object(forKey: UserDefaultsKey.isSoundEffectOn) == nil {
            persistence.set(true, forKey: UserDefaultsKey.isSoundEffectOn)
        }
    }

    // MARK: - Character Selection

    var selectedCharacterRaw: Int {
        get { persistence.int(forKey: UserDefaultsKey.selectedCharacter) }
        set { persistence.set(newValue, forKey: UserDefaultsKey.selectedCharacter) }
    }

    var selectedHotdogType: Hotdog.HotdogType {
        Hotdog.HotdogType(rawValue: selectedCharacterRaw) ?? .mrjj
    }

    // MARK: - Score

    var highestScore: Int {
        get { persistence.int(forKey: UserDefaultsKey.highestScore) }
        set { persistence.set(newValue, forKey: UserDefaultsKey.highestScore) }
    }

    // MARK: - Tutorial

    var doNotShowTutorial: Bool {
        get { persistence.bool(forKey: UserDefaultsKey.doNotShowTutorial) }
        set { persistence.set(newValue, forKey: UserDefaultsKey.doNotShowTutorial) }
    }

    // MARK: - IAP

    var hasRemovedAds: Bool {
        get { persistence.bool(forKey: UserDefaultsKey.purchased) }
        set { persistence.set(newValue, forKey: UserDefaultsKey.purchased) }
    }

    // MARK: - Resume Speed (transient game state persisted across pause)

    var resumeSpeed: Float {
        get { persistence.float(forKey: UserDefaultsKey.resumeSpeed) }
        set { persistence.set(newValue, forKey: UserDefaultsKey.resumeSpeed) }
    }
}
