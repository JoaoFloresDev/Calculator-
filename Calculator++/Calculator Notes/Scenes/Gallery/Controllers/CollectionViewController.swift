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

class CollectionViewController: UICollectionViewController, UINavigationControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate {

    let reuseIdentifier = "Cell"
    let folderReuseIdentifier = "FolderCell"
    let adsService = AdsService()
    var foldersService = FoldersService()
    public var basePath = "@"
    let defaults = UserDefaults.standard

    // MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var modelData: [UIImage] = []
    var image: UIImage!
    var modelController = ModelController()

    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var galleryService = GalleryService()
    var folders: [String] = []
    var editLeftBarButtonItem: EditLeftBarButtonItem?
    var additionsRightBarButtonItem: AdditionsRightBarButtonItem?
    
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
        setupNavigationItems()
        setupUserDefaults()
        setupAds()
        setupFirstUse()
        setupCollectionViewLayout()
        loadModelData()
    }

    private func setupNavigationItems() {
        self.navigationController?.setup()
        self.tabBarController?.setup()
        additionsRightBarButtonItem = AdditionsRightBarButtonItem(delegate: self)
        navigationItem.rightBarButtonItem = additionsRightBarButtonItem
        
        editLeftBarButtonItem = EditLeftBarButtonItem(basePath: basePath, delegate: self)
        navigationItem.leftBarButtonItem = editLeftBarButtonItem
    }

    private func setupUserDefaults() {
        folders = foldersService.getFolders(basePath: basePath)
        self.collectionView?.reloadSections(IndexSet(integer: .zero))
        UserDefaults.standard.set(true, forKey: "InGallery")
    }

    private func setupAds() {
        interstitial = adsService.createAndLoadInterstitial(delegate: self)
        adsService.setupAds(controller: self,
                            interstitial: &interstitial,
                            bannerDelegate: self,
                            interstitialDelegate: self)
    }

    private func setupFirstUse() {
        let firstUseService = UserDefaultService()
        if !firstUseService.getFirstUseStatus() {
            firstUseService.setFirstUseStatus(status: true)
            performSegue(withIdentifier: Segue.setupCalc.rawValue, sender: nil)
        }
        firstUseService.setFirstUseStatus(status: true)
        self.setText(.gallery)

        let controllers = self.tabBarController?.viewControllers
        controllers?[2].setText(.notes)
        controllers?[3].setText(.settings)

        let getAddPhotoCounter = UserDefaultService().getAddPhotoCounter()
        UserDefaultService().setAddPhotoCounter(status: getAddPhotoCounter + 1)
    }

    private func setupCollectionViewLayout() {
        let screenWidth = self.view.frame.size.width - 100
        collectionView?.collectionViewLayout = FlowLayout(screenWidth: screenWidth)
    }

    private func loadModelData() {
        modelData = modelController.fetchImageObjectsInit(basePath: basePath)
    }
}

////    MARK: - Extension CollectionView Input Image
extension CollectionViewController: AssetsPickerViewControllerDelegate {
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        for asset in assets {
            if(asset.mediaType.rawValue != 2) {
                image = galleryService.getAssetThumbnail(asset: asset)
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
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
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
