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

struct GalleryService {
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 1500, height: 1500), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result ?? UIImage()
        })
        return thumbnail
    }
}

struct FoldersService {
    let defaults = UserDefaults.standard
    var folders: [String] = []

    func getFolders() -> [String] {
        
        return folders
    }

    func add(folder: String) {

    }
}
