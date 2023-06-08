import UIKit
import ImageViewer
import Photos

extension CollectionViewController {
    func setEditionMode(_ editing: Bool, animated: Bool) {
//        deleteButton.isEnabled = editing
//        deleteButton.tintColor = editing ? .systemBlue : .darkGray
//
//        shareImageButton.isEnabled = editing
//        shareImageButton.tintColor = editing ? .systemBlue : .darkGray
        
//        setEditing(_ editing: Bool)
        galleryBarButtonItem?.setEditing(editing)
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
