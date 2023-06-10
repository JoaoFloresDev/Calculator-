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

class VideoCollectionViewController: BasicCollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GADBannerViewDelegate {
    
    //    MARK: - Variables
    var modelData = VideoModelController().fetchImageObjectsInit()
    var modelDataVideo = VideoModelController().fetchPathVideosObjectsInit()
    
    var modelController = VideoModelController()
    var bannerView: GADBannerView!
    
    //    Video adaptation
    var imagePickerController = UIImagePickerController()
    var videoURL : NSURL?
    
    //    MARK: - IBOutlet
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //    MARK: - IBAction
    @IBAction func saveItem(_ sender: Any) {
        guard let selectedCells = collectionView?.indexPathsForSelectedItems,
              !selectedCells.isEmpty else {
            return
        }
        
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            let fileURLs = selectedCells.compactMap { indexPath -> URL? in
                let itemIndex = indexPath.item
                
                guard itemIndex < modelDataVideo.count else {
                    return nil
                }
                
                let fileName = modelDataVideo[itemIndex]
                let fileURL = documentsURL.appendingPathComponent(fileName)
                
                return fileURL
            }
            
            let activityController = UIActivityViewController(activityItems: fileURLs, applicationActivities: nil)
            activityController.popoverPresentationController?.sourceView = view
            activityController.popoverPresentationController?.sourceRect = view.frame
            
            present(activityController, animated: true, completion: nil)
        } catch {
            showGenericError()
        }
    }

    
    @IBAction func deleteItem(_ sender: Any) {
        ConfirmationReset()
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        if RazeFaceProducts.store.isProductPurchased("NoAds.Calc") ||
            UserDefaults.standard.object(forKey: "NoAds.Calc") != nil {
            presentPickerController()
        } else {
            let alert = UIAlertController(title: Text.premiumToolTitle.rawValue.localized(),
                                          message: Text.premiumToolMessage.rawValue.localized(),
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func presentPickerController() {
        self.imagePickerController.sourceType = .savedPhotosAlbum
        self.imagePickerController.delegate = self
        self.imagePickerController.mediaTypes = [kUTTypeMovie as String]
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    //    MARK: - Life cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        self.navigationController?.setup()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let screenWidth = self.view.frame.size.width - 100
        layout.itemSize = CGSize(width: screenWidth/4, height: screenWidth/4)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        collectionView?.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(RazeFaceProducts.store.isProductPurchased("NoAds.Calc") || (UserDefaults.standard.object(forKey: "NoAds.Calc") != nil)) {
            placeholderImage.setImage(.placeholderVideo)
        }
    }
    
    //    MARK: - Collection View
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        deleteButton.isEnabled = editing
        saveButton.isEnabled = editing
        
        collectionView?.allowsMultipleSelection = editing
        
        collectionView?.visibleCells.forEach { cell in
            guard let collectionViewCell = cell as? CollectionViewCell else {
                return
            }
            collectionViewCell.isInEditingMode = editing
        }
    }

    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if modelData.count == 0 {
            placeholderImage.isHidden = false
        } else {
            placeholderImage.isHidden = true
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
            return UICollectionViewCell()
        }
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
            do {
                let path = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let newPath = path.appendingPathComponent(modelDataVideo[indexPath.item])
                
                let player = AVPlayer(url: newPath)
                let playerController = AVPlayerViewController()
                playerController.player = player
                present(playerController, animated: true) {
                    player.play()
                }
            } catch {
                showGenericError()
            }
        }
    }
    
    func ConfirmationReset() {
        let refreshAlert = UIAlertController(title: "Delete files?", message: nil, preferredStyle: .alert)
        
        refreshAlert.modalPresentationStyle = .popover
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            if let selectedCells = self.collectionView?.indexPathsForSelectedItems {
                let items = selectedCells.map { $0.item }.sorted().reversed()
                for item in items {
                    if item < self.modelData.count {
                        self.modelData.remove(at: item)
                        self.modelController.deleteImageObject(imageIndex: item)
                    }
                }
                self.collectionView?.deleteItems(at: selectedCells)
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
    
    //    MARK: - imagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let videoURL = info[UIImagePickerControllerMediaURL] as? URL else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        guard let videoData = try? Data(contentsOf: videoURL) else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.dismiss(animated: true, completion: nil)
        
        self.getThumbnailImageFromVideoUrl(url: videoURL) { thumbImage in
            guard let image = thumbImage else { return }
            
            let indexPath = IndexPath(row: self.modelData.count - 1, section: 0)
            self.collectionView?.insertItems(at: [indexPath])
            
            if let pathVideo = self.modelController.saveImageObject(image: image, video: videoData) {
                self.modelData.append(image)
                self.modelDataVideo.append(pathVideo)
            }
        }
    }
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?) -> Void)) {
        DispatchQueue.global().async { // 1
            let asset = AVURLAsset(url: url) // 2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) // 3
            avAssetImageGenerator.appliesPreferredTrackTransform = true // 4
            let thumbnailTime = CMTimeMake(2, 1) // 5
            
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil) // 6
                let thumbImage = UIImage(cgImage: cgThumbImage) // 7
                
                DispatchQueue.main.async { // 8
                    completion(thumbImage) // 9
                }
            } catch {
                print(error.localizedDescription) // 10
                
                DispatchQueue.main.async {
                    completion(nil) // 11
                }
            }
        }
    }

}

//    MARK: - Extension CollectionView Input Image
extension VideoCollectionViewController: AssetsPickerViewControllerDelegate {
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
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
        
        guard let cgimage = image.cgImage else {
            return image
        }
        
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
