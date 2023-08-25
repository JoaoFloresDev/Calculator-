import UIKit

struct CloudDeletionManager {
    static func addName(_ name: String) {
        var savedNames = getNames()
        savedNames.append(name)
        Defaults.setStringArray(.imagesToDelete, savedNames)
    }
    
    static func deleteName(_ name: String) {
        var savedNames = getNames()
        if let index = savedNames.firstIndex(of: name) {
            savedNames.remove(at: index)
            Defaults.setStringArray(.imagesToDelete, savedNames)
        }
    }
    
    static func getNames() -> [String] {
        return Defaults.getStringArray(.imagesToDelete) ?? []
    }
}

struct CloudInsertionManager {
    static func addName(_ name: String) {
        var savedNames = getNames()
        savedNames.append(name)
        Defaults.setStringArray(.imagesToUpload, savedNames)
    }
    
    static func deleteName(_ name: String) {
        var savedNames = getNames()
        if let index = savedNames.firstIndex(of: name) {
            savedNames.remove(at: index)
            Defaults.setStringArray(.imagesToUpload, savedNames)
        }
    }
    
    static func getNames() -> [String] {
        Defaults.getStringArray(.imagesToUpload) ?? []
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
