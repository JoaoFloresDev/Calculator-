//
//  UserDefaultService.swift
//  Calculator Notes
//
//  Created by Joao Flores on 09/07/21.
//  Copyright © 2021 MakeSchool. All rights reserved.
//

import Foundation

enum ProtectionMode: String {
    case calculator = "calculator"
    case noProtection  = "noProtection"
    case bank  = "bank"
}

enum Key: String {
    case recoveryStatus
    case firstUse
}

var userDefaults = UserDefaults.standard
var protectionModeKey = "Mode"

struct UserDefaultService {
    // MARK: - Protection Type
    func getTypeProtection() -> ProtectionMode {
        let protectionMode = userDefaults.string(forKey: protectionModeKey)
        switch protectionMode {
        case ProtectionMode.calculator.rawValue:
            return .calculator

        case ProtectionMode.noProtection.rawValue:
            return .noProtection

        case ProtectionMode.bank.rawValue:
            return .bank

        default:
            return .noProtection
        }
    }

    func setTypeProtection(protectionMode: ProtectionMode) {
        switch protectionMode {
        case .calculator:
            UserDefaults.standard.set(ProtectionMode.calculator.rawValue, forKey: protectionModeKey)

        case .noProtection:
            UserDefaults.standard.set(ProtectionMode.noProtection.rawValue, forKey: protectionModeKey)

        default:
            UserDefaults.standard.set(ProtectionMode.bank.rawValue, forKey: protectionModeKey)
        }
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
}