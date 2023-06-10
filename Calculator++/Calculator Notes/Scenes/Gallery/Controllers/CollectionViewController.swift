//
//  CollectionViewCell.swift
//  Calculator Notes
//
//  Created by Joao Flores on 08/04/20.
//  Copyright © 2020 Joao Flores. All rights reserved.
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
import SceneKit
import ARKit
import simd
import Photos
import StoreKit
import Foundation
import AVFoundation
import AVKit
import UIKit
import ImageViewer
import Photos

class BasicCollectionViewController: UICollectionViewController {
    let reuseIdentifier = "Cell"
    let folderReuseIdentifier = "FolderCell"
    var adsHandler: AdsHandler = AdsHandler()
    let defaults = UserDefaults.standard
    public var basePath = "@"
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var image: UIImage?
    var editLeftBarButtonItem: EditLeftBarButtonItem?
    var additionsRightBarButtonItem: AdditionsRightBarButtonItem?
    
    typealias BarButtonItemDelegate = AdditionsRightBarButtonItemDelegate & EditLeftBarButtonItemDelegate
    
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupCollectionViewLayout() {
        let screenWidth = self.view.frame.size.width - 100
        collectionView?.collectionViewLayout = FlowLayout(screenWidth: screenWidth)
    }
    
    func setupNavigationItems(delegate: BarButtonItemDelegate) {
        self.navigationController?.setup()
        self.tabBarController?.setup()
        additionsRightBarButtonItem = AdditionsRightBarButtonItem(delegate: delegate)
        navigationItem.rightBarButtonItem = additionsRightBarButtonItem
        editLeftBarButtonItem = EditLeftBarButtonItem(basePath: basePath, delegate: delegate)
        navigationItem.leftBarButtonItem = editLeftBarButtonItem
    }
}

class CollectionViewController: BasicCollectionViewController, UINavigationControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate {
    var foldersService = FoldersService(type: .image)
    
    // MARK: - Variables
    var modelData: [UIImage] = []
    var folders: [String] = []
    var modelController = ModelController()
    var galleryService = GalleryService()
    
    var isEditMode = false {
        didSet {
            setEditionMode(isEditMode, animated: true)
        }
    }
    
    // MARK: - IBOutlet
    @IBOutlet weak var placeHolderImage: UIImageView!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems(delegate: self)
        setupFolders()
        setupAds()
        setupFirstUse()
        setupCollectionViewLayout()
        loadModelData()
        self.setText(.gallery)
    }

    private func setupFolders() {
        folders = foldersService.getFolders(basePath: basePath)
        self.collectionView?.reloadSections(IndexSet(integer: .zero))
    }

    private func setupAds() {
        adsHandler.setupAds(controller: self,
                            bannerDelegate: self,
                            interstitialDelegate: self)
    }

    private func setupFirstUse() {
        let firstUseService = UserDefaultService()
        
        if !firstUseService.getFirstUseStatus() {
            firstUseService.setFirstUseStatus(status: true)
            performSegue(withIdentifier: Segue.setupCalc.rawValue, sender: nil)
        }
        
        UserDefaults.standard.set(true, forKey: "InGallery")
        firstUseService.setFirstUseStatus(status: true)

        let controllers = self.tabBarController?.viewControllers
        controllers?[2].setText(.notes)
        controllers?[3].setText(.settings)

        let getAddPhotoCounter = UserDefaultService().getAddPhotoCounter()
        UserDefaultService().setAddPhotoCounter(status: getAddPhotoCounter + 1)
    }

    private func loadModelData() {
        modelData = modelController.fetchImageObjectsInit(basePath: basePath)
    }
}

//   MARK: - Extension CollectionView Input Image
extension CollectionViewController: AssetsPickerViewControllerDelegate {
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        for asset in assets {
            if(asset.mediaType.rawValue != 2) {
                image = galleryService.getAssetThumbnail(asset: asset)
                guard let image = image else {
                    return
                }
                modelData.append(image)
                let indexPath = IndexPath(row: modelData.count - 1, section: 1)
                collectionView!.insertItems(at: [indexPath])
                modelController.saveImageObject(image: image,
                                                basePath: basePath)
            }
        }
    }

    func assetsPicker(controller: AssetsPickerViewController, shouldSelect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        return true
    }

    func assetsPicker(controller: AssetsPickerViewController, shouldDeselect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        return true
    }
}

//    MARK: - Extension Viewer Image
extension CollectionViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return modelData.count
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        let imageView = UIImageView(image: modelData[index])
        let galleryItem = GalleryItem.image { $0(imageView.image) }

        return galleryItem
    }
}

extension CollectionViewController: EditLeftBarButtonItemDelegate {
    func selectImagesButtonTapped() {
        isEditMode.toggle()
    }
    
    func shareImageButtonTapped() {
        if let selectedCells = collectionView?.indexPathsForSelectedItems {
            let items = selectedCells.map { $0.item }.sorted().reversed()

            var vetImgs = [UIImage]()

            for item in items {
                let image = modelData[item]
                vetImgs.append(image)
            }

            if !vetImgs.isEmpty {
                let activityVC = UIActivityViewController(activityItems: vetImgs, applicationActivities: nil)
                self.present(activityVC, animated: true)
            }
        }
    }
    
    func deleteButtonTapped() {
        deleteConfirmation()
    }
}

extension CollectionViewController: AdditionsRightBarButtonItemDelegate {
    func addPhotoButtonTapped() {
        let picker = AssetsPickerViewController()
        picker.pickerConfig = AssetsPickerConfig()
        picker.pickerDelegate = self
        present(picker, animated: true, completion: nil)
    }

    func addFolderButtonTapped() {
        addFolder()
    }

    func addFolder() {
        showInputDialog(title: "Nome da pasta",
                        actionTitle: "Criar",
                        cancelTitle: "Cancelar",
                        inputPlaceholder: "Digite o nome da nova pasta",
                        actionHandler:
                            { (input: String?) in
            if let input = input {
                if !self.foldersService.checkAlreadyExist(folder: input, basePath: self.basePath) {
                    self.folders = self.foldersService.add(folder: input, basePath: self.basePath)
                    self.collectionView?.reloadSections(IndexSet(integer: .zero))
                } else {
                    self.showError(title: "Nome já utilizado", text: "Escolha outro nome para pasta", completion: {
                        self.addFolder()
                    })
                }

            }
        })
    }
}

extension CollectionViewController {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        adsHandler.interstitialDidReceiveAd(ad)
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        adsHandler.interstitialDidDismissScreen(delegate: self)
    }
}

extension CollectionViewController {
    func setEditionMode(_ editing: Bool, animated: Bool) {
        editLeftBarButtonItem?.setEditing(editing)
        collectionView?.allowsMultipleSelection = editing
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = collectionView?.cellForItem(at: indexPath) as? CollectionViewCell {
                    cell.isInEditingMode = editing
                }
                if let cell = collectionView?.cellForItem(at: indexPath) as? FolderCollectionViewCell {
                    cell.isInEditingMode = editing
                }
            }
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let presentPlaceHolderImage = !modelData.isEmpty
        placeHolderImage.isHidden = presentPlaceHolderImage
        switch section {
        case 0:
            return folders.count
        default:
            return modelData.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: folderReuseIdentifier, for: indexPath) as? FolderCollectionViewCell {
                if let folderName = folders[indexPath.row].components(separatedBy: "@").last {
                    cell.setup(name: folderName)
                }
                return cell
            }
        default:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell {
                cell.isInEditingMode = isEditMode
                if indexPath.item < modelData.count {
                    let image = modelData[indexPath.item]
                    cell.imageCell.image = UI().cropToBounds(image: image, width: 200, height: 200)
                }
                cell.applyshadowWithCorner()
                
                return cell
            }
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if !isEditMode {
                let storyboard = UIStoryboard(name: "Gallery", bundle: nil)
                if let controller = storyboard.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController {
                    if indexPath.row < folders.count {
                        controller.basePath = basePath + folders[indexPath.row] + "@"
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
        default:
            if !isEditMode {
                if indexPath.item < modelData.count {
                    self.presentImageGallery(GalleryViewController(startIndex: indexPath.item, itemsDataSource: self))
                }
            }
        }
    }
    
    func deleteConfirmation() {
        let refreshAlert = UIAlertController(title: Text.deleteFiles.rawValue.localized(),
                                             message: nil,
                                             preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.modalPresentationStyle = .popover
        
        refreshAlert.addAction(UIAlertAction(title: Text.cancel.rawValue.localized(),
                                             style: .destructive, handler: nil))
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            if let selectedCells = self.collectionView?.indexPathsForSelectedItems {
                for cell in selectedCells {
                    if cell.section == 0 {
                        if cell.row < self.folders.count {
                            // self.folders.remove(at: cell.row)
                            // let defaults = UserDefaults.standard
                            // defaults.set(self.folders, forKey: Key.foldersPath.rawValue)
                            self.folders = self.foldersService.delete(folder: self.folders[cell.row], basePath: self.basePath)
                        }
                    } else {
                        if cell.row < self.modelData.count {
                            self.modelData.remove(at: cell.row)
                            self.modelController.deleteImageObject(imageIndex: cell.row)
                        }
                    }
                }
                self.collectionView?.deleteItems(at: selectedCells)
            }
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
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
