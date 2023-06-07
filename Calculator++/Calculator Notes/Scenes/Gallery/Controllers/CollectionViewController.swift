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
    
    public let reuseIdentifier = "Cell"
    public let folderReuseIdentifier = "FolderCell"
    public let adsService = AdsService()
    public var basePath = "@"
    let defaults = UserDefaults.standard
    
    //    MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var modelData: [UIImage] = []
    var image: UIImage!
    var modelController = ModelController()
    
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var galleryService = GalleryService()
    
    var folders: [String] = []
    
    //    MARK: - IBOutlet
    @IBOutlet weak var placeHolderImage: UIImageView!
    
    //    MARK: - IBAction
    
    @IBAction func addPhoto(_ sender: Any) {
        let picker = AssetsPickerViewController()
        picker.pickerConfig = AssetsPickerConfig()
        picker.pickerDelegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func addFolder(_ sender: Any) {
        showInputDialog(title: "Nome da pasta",
                        actionTitle: "Criar",
                        cancelTitle: "Cancelar",
                        inputPlaceholder: "Digite o nome da nova pasta",
                        actionHandler:
                            { (input:String?) in
            if let input = input {
                self.folders.append(input)
                let defaults = UserDefaults.standard
                defaults.set(self.folders, forKey: Key.foldersPath.rawValue)
                self.collectionView?.reloadSections(IndexSet(integer: .zero))
            }
        })
    }
    
    //    MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        setupUserDefaults()
        setupAds()
        setupFirstUse()
        setupCollectionViewLayout()
        loadModelData()
    }

    let shareImageButton = UIButton()
    let deleteButton = UIButton()
    
    private func setupNavigationItems() {
        self.navigationController?.setup()
        self.tabBarController?.setup()
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "leftarrow"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        let selectImagesButton = UIButton()
        if #available(iOS 13.0, *) {
            selectImagesButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        } else {
            selectImagesButton.setTitle("Edit", for: .normal)
        }
        selectImagesButton.addTarget(self, action: #selector(selectImagesButtonTapped), for: .touchUpInside)
        
        if #available(iOS 13.0, *) {
            shareImageButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        } else {
            shareImageButton.setTitle("Share", for: .normal)
        }
        shareImageButton.addTarget(self, action: #selector(shareImageButtonTapped), for: .touchUpInside)
        
        if #available(iOS 13.0, *) {
            deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        } else {
            deleteButton.setTitle("Delete", for: .normal)
        }
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        let stackItens = basePath == "@" ?
            [selectImagesButton, shareImageButton, deleteButton] :
            [backButton, selectImagesButton, shareImageButton, deleteButton]
        
        let stackView = UIStackView(arrangedSubviews: stackItens)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        
        let customView = UIView()
        customView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
        
        let customBarButtonItem = UIBarButtonItem(customView: customView)
        
        navigationItem.leftBarButtonItems = [customBarButtonItem]
    }

    private func setupUserDefaults() {
        folders = defaults.stringArray(forKey: Key.foldersPath.rawValue) ?? [String]()
        self.collectionView?.reloadSections(IndexSet(integer: .zero))
        UserDefaults.standard.set(true, forKey: "InGallery")
    }

    private func setupAds() {
        interstitial = AdsService().createAndLoadInterstitial(delegate: self)
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
        modelData = ModelController().fetchImageObjectsInit(basePath: basePath)
    }

    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func selectImagesButtonTapped() {
        self.isEditing.toggle()
    }
    
    @objc func shareImageButtonTapped() {
        if let selectedCells = collectionView?.indexPathsForSelectedItems {
            let items = selectedCells.map { $0.item }.sorted().reversed()
            
            var vetImgs = [UIImage] ()
            
            for item in items {
                let image = modelData[item]
                vetImgs.append(image)
            }
            
            if(vetImgs != []) {
                let activityVC = UIActivityViewController(activityItems: vetImgs, applicationActivities: nil)
                self.present(activityVC, animated: true)
            }
        }
    }
    
    @objc func deleteButtonTapped() {
        deleteConfirmation()
    }
    
    //    MARK: - StoreKit
    func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}

//    MARK: - Extension CollectionView Input Image
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
