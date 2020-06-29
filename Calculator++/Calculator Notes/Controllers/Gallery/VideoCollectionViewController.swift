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

import AVKit
import MobileCoreServices
import Photos
import CoreData

private let reuseIdentifier = "Cell"

class VideoCollectionViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GADBannerViewDelegate {
    
    //    MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var modelData = VideoModelController().fetchImageObjectsInit()
    var image: UIImage!
    var modelController = VideoModelController()
    var bannerView: GADBannerView!
    
//    Video adaptation
    var imagePickerController = UIImagePickerController()
    var videoURL : NSURL?
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    //    MARK: - IBOutlet
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
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
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //    MARK: - Life cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.backgroundColor = UIColor.black
        navigationItem.leftBarButtonItem =  editButtonItem
        
        setupAds()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupAds()
    }
    
    //    MARK: - Ads
    func setupAds() {
        if(RazeFaceProducts.store.isProductPurchased("NoAds.Calc") || (UserDefaults.standard.object(forKey: "NoAds.Calc") != nil)) {
            if let banner = bannerView {
                banner.removeFromSuperview()
            }
        }
        else {
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["bc9b21ec199465e69782ace1e97f5b79"]
            
            bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
            addBannerViewToView(bannerView)
            
            bannerView.adUnitID = "ca-app-pub-8858389345934911/5265350806"
            bannerView.rootViewController = self
            
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }
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
        
        collectionView!.allowsMultipleSelection = editing
        let indexPaths = collectionView!.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell = collectionView!.cellForItem(at: indexPath) as! CollectionViewCell
            cell.isInEditingMode = editing
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        cell.isInEditingMode = isEditing
        
        cell.imageCell.image = cropToBounds(image: modelData[indexPath[1]], width: 200, height: 200)
        applyshadowWithCorner(containerView : cell)
        
        return cell
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
            self.presentImageGallery(GalleryViewController(startIndex: indexPath[1], itemsDataSource: self))
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

    }
    
    func ConfirmationReset() {
        let refreshAlert = UIAlertController(title: "Delete files?", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.modalPresentationStyle = .popover
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action: UIAlertAction!) in
            print("Cancel pressed")
        }))
        
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

//    MARK: - StoreKit
    func rateApp() {
        if #available(iOS 10.3, *) {

            SKStoreReviewController.requestReview()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            let videoData = NSData(contentsOf: videoURL as URL)
        
            let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
            let newPath = path.appendingPathComponent("/videoFileName.mp4")
            do {
                try videoData?.write(to: newPath)
            } catch {
                print(error)
            }
            self.dismiss(animated: true, completion: nil)
        
        let player = AVPlayer(url: newPath)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true) {
            player.play()
        }
        
        self.getThumbnailImageFromVideoUrl(url: videoURL as URL) { (thumbImage) in
            let image = thumbImage
            
            self.modelData.append(image!)
            
            let indexPath = IndexPath(row: self.modelData.count - 1, section: 0)
            self.collectionView!.insertItems(at: [indexPath])
            self.modelController.saveImageObject(image: image!)
        }
    }
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(2, 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
}

//    MARK: - Extension CollectionView Input Image
extension VideoCollectionViewController: AssetsPickerViewControllerDelegate {
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
//        for asset in assets {
//            if(asset.mediaType.rawValue != 2) {
//                image = getAssetThumbnail(asset: asset)
//                modelData.append(image)
//
//                let indexPath = IndexPath(row: modelData.count - 1, section: 0)
//                collectionView!.insertItems(at: [indexPath])
//                modelController.saveImageObject(image: image)
//            }
//        }
    }
    
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 1500, height: 1500), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
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
        
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
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
extension VideoCollectionViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return modelData.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        let imageView = UIImageView(image: modelData[index])
        let galleryItem = GalleryItem.image { $0(imageView.image) }
        
        print("vai mostrar agora ----")
        return galleryItem
    }
}
