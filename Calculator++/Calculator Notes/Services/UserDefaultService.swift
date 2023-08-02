//
//  UserDefaultService.swift
//  Calculator Notes
//
//  Created by Joao Flores on 09/07/21.
//  Copyright © 2021 MakeSchool. All rights reserved.
//

import Foundation

enum ProtectionMode: String {
    case calculator
    case noProtection
    case bank
}

var userDefaults = UserDefaults.standard
var protectionModeKey = "Mode"

public enum Key: String {
    case recoveryStatus
    case firstUse
    case addPhotoCounter
    case galleryFoldersPath
    case videoFoldersPath
    case disableRecoveryButtonCounter
    
    func setBoolean(_ bool: Bool) {
        userDefaults.set(bool, forKey: self.rawValue)
    }
    
    func getBoolean() -> Bool {
        return userDefaults.bool(forKey: self.rawValue)
    }
}

struct UserDefaultService {
    // MARK: - Protection Type
    func getTypeProtection() -> ProtectionMode {
        let protectionMode = userDefaults.string(forKey: protectionModeKey)
        return ProtectionMode(rawValue: protectionMode ?? ProtectionMode.noProtection.rawValue) ?? .noProtection
    }

    func setTypeProtection(protectionMode: ProtectionMode) {
        UserDefaults.standard.set(protectionMode.rawValue, forKey: protectionModeKey)
    }
    
    // MARK: - FirstUse Status
    func getAddPhotoCounter() -> Int {
        return userDefaults.integer(forKey: Key.addPhotoCounter.rawValue)
    }

    func setAddPhotoCounter(status: Int) {
        UserDefaults.standard.set(status, forKey: Key.addPhotoCounter.rawValue)
    }
    
    // MARK: - FirstUse Status
    func getDisableRecoveryButtonCounter() -> Int {
        return userDefaults.integer(forKey: Key.disableRecoveryButtonCounter.rawValue)
    }

    func setDisableRecoveryButtonCounter(status: Int) {
        UserDefaults.standard.set(status, forKey: Key.disableRecoveryButtonCounter.rawValue)
    }
}
