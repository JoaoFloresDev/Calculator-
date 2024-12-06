//
//  UserDefaultService.swift
//  Calculator Notes
//
//  Created by Joao Flores on 09/07/21.
//  Copyright © 2021 MakeSchool. All rights reserved.
//

import Foundation

var userDefaults = UserDefaults.standard

enum BoolKey: String {
    case recoveryStatus
    case notFirstUse = "firstUse"
    case premiumPurchased = "NoAds.Calc"
    case monthlyPurchased = "Calc.noads.mensal"
    case yearlyPurchased = "calcanual"
    case needSavePasswordInCloud
    case iCloudEnabled
    case recurrentBackupUpdate
    
    func set(_ value: Bool) {
        userDefaults.set(value, forKey: rawValue)
    }
    
    func get() -> Bool {
        return userDefaults.bool(forKey: rawValue)
    }
}

enum IntKey: String {
    case launchCounter
    case disableRecoveryButtonCounter
    case numberOfNonSincronizatedPhotos
    
    func set(_ value: Int) {
        userDefaults.set(value, forKey: rawValue)
    }
    
    func get() -> Int {
        return userDefaults.integer(forKey: rawValue)
    }
}

enum StringKey: String {
    case password = "Key"
    case fakePass
    case recoverEmail
    case lastBackupUpdate
    
    func set(_ value: String) {
        userDefaults.set(value, forKey: rawValue)
    }
    
    func get() -> String {
        return userDefaults.string(forKey: rawValue) ?? String()
    }
}

enum StringArrayKey: String {
    case galleryFoldersPath
    case videoFoldersPath
    
    case imagesToUpload
    case imagesToDelete
    
    case videoToUpload
    case videoToDelete
    
    case secretLinks
    
    func set(_ value: [String]) {
        userDefaults.set(value, forKey: rawValue)
    }
    
    func get() -> [String]? {
        return userDefaults.stringArray(forKey: rawValue)
    }
}

class Defaults {
    static func setBool(_ key: BoolKey, _ value: Bool) {
        key.set(value)
    }
    
    static func getBool(_ key: BoolKey) -> Bool {
        return key.get()
    }
    
    static func setInt(_ key: IntKey, _ value: Int) {
        key.set(value)
    }
    
    static func incrementInt(_ key: IntKey) {
        key.set(key.get() + 1)
    }
    
    static func getInt(_ key: IntKey) -> Int {
        return key.get()
    }
    
    static func setString(_ key: StringKey, _ value: String) {
        key.set(value)
    }
    
    static func getString(_ key: StringKey) -> String {
        return key.get()
    }
    
    static func setStringArray(_ key: StringArrayKey, _ value: [String]) {
        key.set(value)
    }
    
    static func getStringArray(_ key: StringArrayKey) -> [String]? {
        return key.get()
    }
}

enum ProtectionMode: String {
    case calculator
    case noProtection
    case bank
    case vault
    case newCalc
    case newCalc2
}

struct UserDefaultService {
    var protectionModeKey = "Mode"
    
    // MARK: - Protection Type
    func getTypeProtection() -> ProtectionMode {
        let protectionMode = userDefaults.string(forKey: protectionModeKey)
        return ProtectionMode(rawValue: protectionMode ?? ProtectionMode.noProtection.rawValue) ?? .noProtection
    }

    func setTypeProtection(protectionMode: ProtectionMode) {
        UserDefaults.standard.set(protectionMode.rawValue, forKey: protectionModeKey)
    }
}

struct FeatureFlags {
    static let iCloudEnabled  = true
    static func simpleMode() -> Bool {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.year = 2024
        dateComponents.month = 12
        dateComponents.day = 16
        if let limitDate = Calendar.current.date(from: dateComponents) {
            return currentDate < limitDate
        }
        return false
    }

}

class Counter {
    private let userDefaultsKey = "counterKey"
    
    var count: Int {
        get {
            return UserDefaults.standard.integer(forKey: userDefaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
        }
    }
    
    func increment() {
        count += 1
    }
}

