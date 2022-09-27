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

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate {
    
    //    MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var modelData = ModelController().fetchImageObjectsInit()
    var image: UIImage!
    var modelController = ModelController()
    
    var bannerView: GADBannerView!
    
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
        ConfirmationReset()
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        
        let pickerConfig = AssetsPickerConfig()
        
        let picker = AssetsPickerViewController()
        picker.pickerConfig = pickerConfig
        picker.pickerDelegate = self
        present(picker, animated: true, completion: nil)
    }
    
    //    MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setup()
        if #available(iOS 15, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
            
            appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
            tabBarController?.tabBar.standardAppearance = appearance
            tabBarController?.tabBar.scrollEdgeAppearance = appearance
        }
        
        if #available(iOS 13, *) {
            let appearance = UITabBarAppearance()
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .white
            
            appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
            appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
            
            tabBarController?.tabBar.standardAppearance = appearance
        }
        
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
    
    var interstitial: GADInterstitial!
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        let getAddPhotoCounter = UserDefaultService().getAddPhotoCounter()
        if getAddPhotoCounter > 5 {
            interstitial.present(fromRootViewController: self)
            UserDefaultService().setAddPhotoCounter(status: 0)
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
      let interstitial = GADInterstitial(adUnitID: "ca-app-pub-8858389345934911/8516660323")
      interstitial.delegate = self
      interstitial.load(GADRequest())
      return interstitial
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      interstitial = createAndLoadInterstitial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkPurchase()
    }
    
    //    MARK: - Ads
    func checkPurchase() {
        if(RazeFaceProducts.store.isProductPurchased("NoAds.Calc") || (UserDefaults.standard.object(forKey: "NoAds.Calc") != nil)) {
            bannerView?.removeFromSuperview()
        } else {
            let getAddPhotoCounter = UserDefaultService().getAddPhotoCounter()
            if getAddPhotoCounter > 5 {
                let request = GADRequest()
                interstitial = createAndLoadInterstitial()
                interstitial.load(request)
                interstitial.delegate = self
            }
        }
    }
    
    func setupAds() {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["bc9b21ec199465e69782ace1e97f5b79"]
        
        bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-8858389345934911/5265350806"
        bannerView.rootViewController = self
        
        bannerView.load(GADRequest())
        bannerView.delegate = self
        checkPurchase()
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    //    MARK: - Collection View
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if(editing) {
            deleteButton.isEnabled = true
            saveButton.isEnabled = true
        } else {
            deleteButton.isEnabled = false
            saveButton.isEnabled = false
            self.rateApp()
        }
        
        collectionView?.allowsMultipleSelection = editing
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                let cell = collectionView?.cellForItem(at: indexPath) as? CollectionViewCell
                cell?.isInEditingMode = editing
            }
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(modelData.isEmpty) {
            placeHolderImage.isHidden = false
        }
        else {
            placeHolderImage.isHidden = true
        }
        return modelData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell {
            cell.isInEditingMode = isEditing
            if indexPath.indices.contains(1),
               modelData.indices.contains(indexPath[1]) {
            cell.imageCell.image = cropToBounds(image: modelData[indexPath[1]], width: 200, height: 200)
            }
            applyshadowWithCorner(containerView : cell)
            
            return cell
        } else {
            return CollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: 0)
    }
    
    func applyshadowWithCorner(containerView : UIView){
        containerView.clipsToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing {
            if indexPath.indices.contains(1),
               modelData.indices.contains(indexPath[1]) {
                self.presentImageGallery(GalleryViewController(startIndex: indexPath[1], itemsDataSource: self))
            }
        }
    }
    
    func ConfirmationReset() {
        let refreshAlert = UIAlertController(title: Text.deleteFiles.rawValue.localized(),
                                             message: nil,
                                             preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.modalPresentationStyle = .popover
        
        refreshAlert.addAction(UIAlertAction(title: Text.cancel.rawValue.localized(),
                                             style: .destructive, handler: nil))
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            if let selectedCells = self.collectionView?.indexPathsForSelectedItems {
                let items = selectedCells.map { $0.item }.sorted().reversed()
                for item in items {
                    self.modelData.remove(at: item)
                    self.modelController.deleteImageObject(imageIndex: item)
                }
                self.collectionView!.deleteItems(at: selectedCells)
            }
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    @IBAction func teste(_ sender: Any) {
        openGalery()
    }
    
    func openGalery() {
        
    }
    
    //    MARK: - StoreKit
    func rateApp() {
        if #available(iOS 10.3, *) {
            
            //            SKStoreReviewController.requestReview()
        }
    }
}

//    MARK: - Extension CollectionView Input Image
extension CollectionViewController: AssetsPickerViewControllerDelegate {
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        for asset in assets {
            if(asset.mediaType.rawValue != 2) {
                image = getAssetThumbnail(asset: asset)
                modelData.append(image)
                let indexPath = IndexPath(row: modelData.count - 1, section: 0)
                collectionView!.insertItems(at: [indexPath])
                modelController.saveImageObject(image: image)
            }
        }
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
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        guard let cgimage = image.cgImage else { return image }
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        guard let imageRef: CGImage = cgimage.cropping(to: rect) else { return image }
        
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
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
