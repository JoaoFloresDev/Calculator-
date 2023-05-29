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
import UIKit
import SceneKit
import ARKit
import simd
import Photos
import StoreKit
import Foundation
import AVFoundation
import AVKit

class CollectionViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate {
    
    //    MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var modelData = ModelController().fetchImageObjectsInit()
    var image: UIImage!
    var modelController = ModelController()
    
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var galleryService = GalleryService()
    
    var folders = [
        Folder(name: "name1", path: "path"),
        Folder(name: "name2", path: "path")
    ]
    
    struct Folder {
        var name: String
        var path: String
    }
    
    //    MARK: - IBOutlet
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeHolderImage: UIImageView!
    
    //    MARK: - IBAction
    @IBAction func saveItem(_ sender: Any) {
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
    
    @IBAction func deleteItem(_ sender: Any) {
        deleteConfirmation()
    }
    
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
                self.folders.append(Folder(name: input, path: "path"))
                self.collectionView?.reloadData()
            }
        })
    }
    
    //    MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setup()
        self.tabBarController?.setup()
        
        UserDefaults.standard.set(true, forKey:"InGallery")
        navigationItem.leftBarButtonItem =  editButtonItem
        
        setupAds()
        
        if !UserDefaultService().getFirstUseStatus() {
            UserDefaultService().setFirstUseStatus(status: true)
            performSegue(withIdentifier: Segue.setupCalc.rawValue, sender: nil)
        }
        UserDefaultService().setFirstUseStatus(status: true)
        self.setText(.gallery)
        
        let controllers = self.tabBarController?.viewControllers
        controllers?[2].setText(.notes)
        controllers?[3].setText(.settings)
        
        let getAddPhotoCounter =  UserDefaultService().getAddPhotoCounter()
        UserDefaultService().setAddPhotoCounter(status: getAddPhotoCounter + 1)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let screenWidth = self.view.frame.size.width - 100
        layout.itemSize = CGSize(width: screenWidth/4, height: screenWidth/4)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        collectionView?.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkPurchase()
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
                modelController.saveImageObject(image: image)
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


extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String?,
                         cancelTitle:String?,
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: cancelHandler))
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
