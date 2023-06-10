//
//  GalleryService.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 02/12/22.
//  Copyright © 2022 MakeSchool. All rights reserved.
//

import UIKit
import Photos
import AssetsPickerViewController
import DTPhotoViewerController
import CoreData
import NYTPhotoViewer
import ImageViewer
import StoreKit
import GoogleMobileAds
import UIKit
import SceneKit
import ARKit
import simd
import Photos
import StoreKit
import Foundation
import AVFoundation
import AVKit

struct FoldersService {
    enum AssetType {
        case video
        case image
    }
    
    let defaults = UserDefaults.standard
    var folders: [String] = []
    
    init(type: AssetType) {
        folders = defaults.stringArray(forKey: Key.foldersPath.rawValue) ?? [String]()
    }
    
    func getFolders(basePath: String) -> [String] {
        var folderInPath: [String] = []
        for folder in folders {
            if folder.contains(basePath)
                && folder.filter({ $0 == "@" }).count ==
                basePath.filter({ $0 == "@" }).count {
                folderInPath.append(folder)
            }
        }
        return folderInPath
    }
    
    func checkAlreadyExist(folder: String, basePath: String) -> Bool {
        return folders.contains("\(basePath)\(folder)")
    }

    mutating func add(folder: String, basePath: String) -> [String] {
        self.folders.append("\(basePath)\(folder)")
        defaults.set(self.folders, forKey: Key.foldersPath.rawValue)
        return getFolders(basePath: basePath)
    }
    
    mutating func delete(folder: String, basePath: String)  -> [String] {
        folders.removeAll { string in
            return string.contains(folder)
        }
        defaults.set(self.folders, forKey: Key.foldersPath.rawValue)
        return getFolders(basePath: basePath)
    }
}
