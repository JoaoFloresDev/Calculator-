import UIKit

struct CloudDeletionManager {
    private static let userDefaults = UserDefaults.standard
    private static let namesKey = "ImagesToDelete"
    
    static func addName(_ name: String) {
        var savedNames = getNames()
        savedNames.append(name)
        userDefaults.set(savedNames, forKey: namesKey)
    }
    
    static func deleteName(_ name: String) {
        var savedNames = getNames()
        if let index = savedNames.firstIndex(of: name) {
            savedNames.remove(at: index)
            userDefaults.set(savedNames, forKey: namesKey)
        }
    }
    
    static func getNames() -> [String] {
        return userDefaults.array(forKey: namesKey) as? [String] ?? []
    }
}

struct CloudInsertionManager {
    private static let userDefaults = UserDefaults.standard
    private static let namesKey = "ImagesToUpload"
    
    static func addName(_ name: String) {
        var savedNames = getNames()
        savedNames.append(name)
        userDefaults.set(savedNames, forKey: namesKey)
    }
    
    static func deleteName(_ name: String) {
        var savedNames = getNames()
        if let index = savedNames.firstIndex(of: name) {
            savedNames.remove(at: index)
            userDefaults.set(savedNames, forKey: namesKey)
        }
    }
    
    static func getNames() -> [String] {
        return userDefaults.array(forKey: namesKey) as? [String] ?? []
    }
}

struct PasswordInsertionManager {
    private static let userDefaults = UserDefaults.standard
    private static let namesKey = "PasswordToUpload"
    
    static func addName(_ name: String) {
        var savedNames = getNames()
        savedNames.append(name)
        userDefaults.set(savedNames, forKey: namesKey)
    }
    
    static func deleteName(_ name: String) {
        var savedNames = getNames()
        if let index = savedNames.firstIndex(of: name) {
            savedNames.remove(at: index)
            userDefaults.set(savedNames, forKey: namesKey)
        }
    }
    
    static func getNames() -> [String] {
        return userDefaults.array(forKey: namesKey) as? [String] ?? []
    }
}
