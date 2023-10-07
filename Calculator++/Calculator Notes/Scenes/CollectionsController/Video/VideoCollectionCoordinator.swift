//
//  VideoCollectionCoordinator.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 30/08/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import Photos
import CoreData
import os.log
import SnapKit

protocol VideoCollectionCoordinatorProtocol {
    func presentPurshes()
    func navigateToVideoCollectionViewController(
        for indexPath: IndexPath,
        folders: [Folder],
        basePath: String
    )
    func playVideo(
        videoPaths: [String],
        indexPath: IndexPath
    )
    func presentPickerController()
}

class VideoCollectionCoordinator: VideoCollectionCoordinatorProtocol {
    typealias Controller = UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate & PurchaseViewControllerDelegate
    weak var viewController: Controller?
    
    init(viewController: Controller) {
        self.viewController = viewController
    }
    
    func presentPurshes() {
        let storyboard = UIStoryboard(name: "Purchase",bundle: nil)
        let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "Purchase")
        if let changePasswordCalcMode = changePasswordCalcMode as? PurchaseViewController {
            changePasswordCalcMode.delegate = viewController
        }
        viewController?.present(changePasswordCalcMode, animated: true)
    }
    
    func navigateToVideoCollectionViewController(
        for indexPath: IndexPath,
        folders: [Folder],
        basePath: String
    ) {
        let storyboard = UIStoryboard(name: "VideoPlayer", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "VideoCollectionViewController") as? VideoCollectionViewController,
              indexPath.row < folders.count else { return }
        
        controller.basePath = basePath + folders[indexPath.row].name + Constants.deepSeparatorPath
        controller.navigationTitle = folders[indexPath.row].name.components(separatedBy: Constants.deepSeparatorPath).last
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    func playVideo(
        videoPaths: [String],
                   indexPath: IndexPath
    ) {
        guard let viewController = viewController else {
            return
        }
        guard let videoURL = videoPaths[safe: indexPath.item],
              let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(videoURL) else {
            os_log("Failed to retrieve video URL", log: .default, type: .error)
            Alerts.showGenericError(controller: viewController)
            return
        }
        
        let player = AVPlayer(url: path)
        let playerController = AVPlayerViewController()
        playerController.player = player
        viewController.present(playerController, animated: true) {
            player.play()
        }
    }
    
    func presentPickerController() {
        guard let viewController = viewController else {
            return
        }
        guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
            Alerts.showGenericError(controller: viewController)
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.delegate = viewController
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        viewController.present(imagePickerController, animated: true, completion: nil)
    }
}
