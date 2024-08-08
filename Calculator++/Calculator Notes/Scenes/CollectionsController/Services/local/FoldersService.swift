import UIKit
import Photos
import AssetsPickerViewController
import DTPhotoViewerController
import CoreData
import NYTPhotoViewer
import ImageViewer
import StoreKit
import GoogleMobileAds
import SceneKit
import ARKit
import simd
import AVFoundation
import AVKit

// MARK: - FoldersService

struct FoldersService {
    enum AssetType {
        case video
        case image
    }
    
    private var folders: [String] = []
    private var type: AssetType
    
    var key: StringArrayKey {
        switch type {
        case .video:
            return .videoFoldersPath
        case .image:
            return .galleryFoldersPath
        }
    }
    
    init(type: AssetType) {
        self.type = type
        self.folders = Defaults.getStringArray(key) ?? []
    }
    
    // MARK: - Public Methods
    
    mutating func getFolders(basePath: String) -> [String] {
        updateFolders()
        return folders.filter { folder in
            folder.contains(basePath) && folder.filter({ $0 == "@" }).count == basePath.filter({ $0 == "@" }).count
        }
    }
    
    func checkAlreadyExist(folder: String, basePath: String) -> Bool {
        return folders.contains("\(basePath)\(folder)")
    }

    @discardableResult
    mutating func add(folder: String, basePath: String) -> [String] {
        folders.append("\(basePath)\(folder)")
        saveFolders()
        return getFolders(basePath: basePath)
    }
    
    mutating func delete(folder: String, basePath: String) -> [String] {
        folders.removeAll { $0.contains(folder) }
        saveFolders()
        return getFolders(basePath: basePath)
    }
    
    // MARK: - Private Methods
    
    private mutating func updateFolders() {
        folders = Defaults.getStringArray(key) ?? []
    }
    
    private func saveFolders() {
        Defaults.setStringArray(key, folders)
    }
}
