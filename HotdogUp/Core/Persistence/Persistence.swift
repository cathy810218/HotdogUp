//
//  Persistence.swift
//  HotdogUp
//
//  Created by Cathy Oun on 9/18/25.
//  Copyright © 2025 Cathy Oun. All rights reserved.
//

import Foundation

protocol Persistence {
    func set(_ value: Any?, forKey key: String)
    func int(forKey key: String) -> Int
}


final class UserDefaultsPersistence: Persistence {
    private let defaults = UserDefaults.standard
    func set(_ value: Any?, forKey key: String) { defaults.set(value, forKey: key) }
    func int(forKey key: String) -> Int { defaults.integer(forKey: key) }
}
