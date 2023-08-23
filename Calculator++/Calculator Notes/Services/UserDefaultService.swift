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
    case launchCounter
    case galleryFoldersPath
    case videoFoldersPath
    case disableRecoveryButtonCounter
    case password = "Key"
    case needSavePasswordInCloud
    case premiumVersionEnabled = "NoAds.Calc"
    case iCloudPurchased
    case iCloudEnabled
    
    
    func setBoolean(_ bool: Bool) {
        userDefaults.set(bool, forKey: self.rawValue)
    }
    
    func getBoolean() -> Bool {
        return userDefaults.bool(forKey: self.rawValue)
    }
    
    func setInt(_ int: Int) {
        userDefaults.set(int, forKey: self.rawValue)
    }
    
    func getInt() -> Int {
        return userDefaults.integer(forKey: self.rawValue)
    }
    
    func setString(_ string: String) {
        userDefaults.set(string, forKey: self.rawValue)
    }
    
    func getString() -> String? {
        return userDefaults.string(forKey: self.rawValue)
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
}
