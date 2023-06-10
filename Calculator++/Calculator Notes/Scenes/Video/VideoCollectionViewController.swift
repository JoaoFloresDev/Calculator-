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

class VideoCollectionViewController: BasicCollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //    MARK: - Variables
    var modelData = VideoModelController().fetchImageObjectsInit()
    var modelDataVideo = VideoModelController().fetchPathVideosObjectsInit()
    
    var modelController = VideoModelController()
    
    //    Video adaptation
    var imagePickerController = UIImagePickerController()
    var videoURL : NSURL?
    
    var isPremium: Bool {
        (RazeFaceProducts.store.isProductPurchased("NoAds.Calc") || (UserDefaults.standard.object(forKey: "NoAds.Calc") != nil))
    }
    
    var isEditMode = false {
        didSet {
            setEditionMode(isEditMode, animated: true)
        }
    }
    
    //    MARK: - IBOutlet
    @IBOutlet weak var placeholderImage: UIImageView!
    
    //    MARK: - IBAction
    private func presentPickerController() {
        self.imagePickerController.sourceType = .savedPhotosAlbum
        self.imagePickerController.delegate = self
        self.imagePickerController.mediaTypes = [kUTTypeMovie as String]
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    //    MARK: - Life cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewLayout()
        setupNavigationItems(delegate: self)
        foldersService = FoldersService(type: .video)
        self.setText(.video)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isPremium {
            placeholderImage.setImage(.placeholderVideo)
        }
    }
    
    //    MARK: - Collection View
    func setEditionMode(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        editLeftBarButtonItem?.setEditing(editing)
        
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
            cell.isInEditingMode = isEditMode
            if indexPath.indices.contains(1),
               modelData.indices.contains(indexPath[1]) {
                let image = modelData[indexPath[1]]
                cell.imageCell.image = UI().cropToBounds(image: image, width: 200, height: 200)
                
            }
            cell.applyshadowWithCorner()
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditMode {
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
    
    func confirmationDelete() {
        showConfirmationDelete {
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

extension VideoCollectionViewController: EditLeftBarButtonItemDelegate {
    func selectImagesButtonTapped() {
        isEditMode.toggle()
    }
    
    func shareImageButtonTapped() {
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
    
    func deleteButtonTapped() {
        confirmationDelete()
    }
}

extension VideoCollectionViewController: AdditionsRightBarButtonItemDelegate {
    func addPhotoButtonTapped() {
        if isPremium {
            presentPickerController()
        } else {
            showBePremiumToUse()
        }
    }

    func addFolderButtonTapped() {
        addFolder()
    }
}
