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

enum Key: String {
    case recoveryStatus
    case firstUse
    case addPhotoCounter
    case galleryFoldersPath
    case videoFoldersPath
}

var userDefaults = UserDefaults.standard
var protectionModeKey = "Mode"

struct UserDefaultService {
    // MARK: - Protection Type
    func getTypeProtection() -> ProtectionMode {
        let protectionMode = userDefaults.string(forKey: protectionModeKey)
        return ProtectionMode(rawValue: protectionMode ?? ProtectionMode.noProtection.rawValue) ?? .noProtection
    }

    func setTypeProtection(protectionMode: ProtectionMode) {
        UserDefaults.standard.set(protectionMode.rawValue, forKey: protectionModeKey)
    }

    // MARK: - Recovery Status
    func getRecoveryStatus() -> Bool {
        return userDefaults.bool(forKey: Key.recoveryStatus.rawValue)
    }

    func setRecoveryStatus(status: Bool) {
        UserDefaults.standard.set(status, forKey: Key.recoveryStatus.rawValue)
    }

    // MARK: - FirstUse Status
    func getFirstUseStatus() -> Bool {
        return userDefaults.bool(forKey: Key.firstUse.rawValue)
    }

    func setFirstUseStatus(status: Bool) {
        UserDefaults.standard.set(status, forKey: Key.firstUse.rawValue)
    }
    
    // MARK: - FirstUse Status
    func getAddPhotoCounter() -> Int {
        return userDefaults.integer(forKey: Key.addPhotoCounter.rawValue)
    }

    func setAddPhotoCounter(status: Int) {
        UserDefaults.standard.set(status, forKey: Key.addPhotoCounter.rawValue)
    }
}
