import Network
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
import simd
import Photos
import StoreKit
import Foundation
import AVFoundation
import AVKit
import CloudKit

class CollectionViewController: BasicCollectionViewController, UINavigationControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate {
    // MARK: - Variables
    var modelData: [Photo] = []
    var folders: [Folder] = []
    var loadingAlert = LoadingAlert()
    
    var isEditMode = false {
        didSet {
            editLeftBarButtonItem?.setEditing(isEditMode)
        }
    }
    
    // MARK: - IBOutlet
    @IBOutlet weak var placeHolderImage: UIImageView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        
        if let navigationTitle = navigationTitle {
            self.title = navigationTitle
        } else {
            self.setText(.gallery)
        }
        
        setupAds()
        setupFirstUse()
        setupTabBars()
        
        if basePath == deepSeparatorPath {
            let getAddPhotoCounter = UserDefaultService().getAddPhotoCounter()
            UserDefaultService().setAddPhotoCounter(status: getAddPhotoCounter + 1)
        }
        
        isConnectedToWiFi { isConnected in
            if isConnected {
                BackupService.updateBackup()
                if Key.needSavePasswordInCloud.getBoolean() == true {
                    if let password = Key.password.getString() {
                        CloudKitPasswordService.updatePassword(newPassword: password) { success, error in
                            if success && error == nil {
                                Key.needSavePasswordInCloud.setBoolean(false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func setupFolders() {
        folders = foldersService.getFolders(basePath: basePath).map { folderName in
            return Folder(name: folderName, isSelected: false)
        }
        if folders.isEmpty {
            filesIsExpanded = true
        } else {
            self.collectionView?.reloadSections(IndexSet(integer: .zero))
        }
    }
    
    private func setupData() {
        modelData = ModelController.listPhotosOf(basePath: basePath)
        commonViewDidLoad()
        setupNavigationItems(delegate: self)
        setupFolders()
    }
    
    private func setupTabBars() {
        let controllers = self.tabBarController?.viewControllers
        controllers?[2].setText(.notes)
        controllers?[3].setText(.settings)
    }
    
    func deselectAllFoldersObjects() {
        for index in 0 ..< folders.count {
            folders[index].isSelected = false
        }
    }
    
    func deselectAllFileObjects() {
        for index in 0 ..< modelData.count {
            modelData[index].isSelected = false
        }
    }
    
    func isConnectedToWiFi(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied && path.usesInterfaceType(.wifi) {
                completion(true)
            } else {
                completion(false)
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}

extension CollectionViewController: EditLeftBarButtonItemDelegate {
    func selectImagesButtonTapped() {
        self.deselectAllFoldersObjects()
        self.deselectAllFileObjects()
        if isEditMode {
            collectionView?.reloadData()
        }
        isEditMode.toggle()
    }
    
    func shareImageButtonTapped() {
        var photoArray = [UIImage]()
        for photo in modelData where photo.isSelected == true {
            photoArray.append(photo.image)
        }
        
        if !photoArray.isEmpty {
            let activityVC = UIActivityViewController(activityItems: photoArray, applicationActivities: nil)
            self.present(activityVC, animated: true)
        }
    }
    
    func deleteButtonTapped() {
        Alerts.showConfirmationDelete(controller: self) {
            for folder in self.folders where folder.isSelected == true {
                self.folders = self.foldersService.delete(folder: folder.name, basePath: self.basePath).map { folderName in
                    return Folder(name: folderName, isSelected: false)
                }
            }
            if self.folders.isEmpty {
                self.filesIsExpanded = true
            }
            self.deselectAllFoldersObjects()
            self.collectionView?.reloadSections(IndexSet(integer: 0))
            
            for photo in self.modelData where photo.isSelected == true {
                ModelController.deleteImageObject(name: photo.name, basePath: self.basePath)
                if let index = self.modelData.firstIndex(where: { $0.name == photo.name }) {
                    self.modelData.remove(at: index)
                }
            }
            self.deselectAllFileObjects()
            self.collectionView?.reloadSections(IndexSet(integer: 1))
        }
    }
}

extension CollectionViewController: AdditionsRightBarButtonItemDelegate {
    func addPhotoButtonTapped() {
        let picker = AssetsPickerViewController()
        picker.pickerConfig = AssetsPickerConfig()
        picker.pickerDelegate = self
        present(picker, animated: true) {
            self.filesIsExpanded = true
        }
    }
    
    func addFolderButtonTapped() {
        addFolder()
    }
    
    func addFolder() {
        Alerts.showInputDialog(title: Text.folderTitle.localized(),
                               controller: self, actionTitle: Text.createActionTitle.localized(),
                               cancelTitle: Text.cancelTitle.rawValue.localized(),
                               inputPlaceholder: Text.inputPlaceholder.localized(),
                               actionHandler: { (input: String?) in
            if let input = input {
                if !self.foldersService.checkAlreadyExist(folder: input, basePath: self.basePath) {
                    self.folders = self.foldersService.add(folder: input, basePath: self.basePath).map { folderName in
                        return Folder(name: folderName, isSelected: false)
                    }
                    self.collectionView?.reloadSections(IndexSet(integer: .zero))
                } else {
                    Alerts.showError(title: Text.folderNameAlreadyUsedTitle.localized(),
                                     text: Text.folderNameAlreadyUsedText.localized(),
                                     controller: self,
                                     completion: {
                        self.addFolder()
                    })
                }
            }
        })
    }
    
}

extension CollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let presentPlaceHolderImage = modelData.isEmpty && folders.isEmpty
        placeHolderImage.isHidden = !presentPlaceHolderImage
        switch section {
        case 0:
            return folders.count
        default:
            if filesIsExpanded {
                return modelData.count
            } else {
                return 0
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: folderReuseIdentifier, for: indexPath) as? FolderCollectionViewCell {
                if let folderName = folders[indexPath.row].name.components(separatedBy: deepSeparatorPath).last {
                    cell.setup(name: folderName)
                    cell.isSelectedCell = folders[indexPath.row].isSelected
                }
                return cell
            }
        default:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell {
                if indexPath.item < modelData.count {
                    let image = modelData[indexPath.item]
                    cell.imageCell.image = UI.cropToBounds(image: image.image, width: 200, height: 200)
                    cell.isSelectedCell = modelData[indexPath.item].isSelected
                }
                cell.applyshadowWithCorner()
                
                return cell
            }
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditMode {
            switch indexPath.section {
            case .zero:
                let storyboard = UIStoryboard(name: "Gallery", bundle: nil)
                if let controller = storyboard.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController {
                    if indexPath.row < folders.count {
                        controller.basePath = basePath + folders[indexPath.row].name + deepSeparatorPath
                        controller.navigationTitle = folders[indexPath.row].name.components(separatedBy: deepSeparatorPath).last
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            default:
                if indexPath.item < modelData.count {
                    self.presentImageGallery(GalleryViewController(startIndex: indexPath.item, itemsDataSource: self))
                }
            }
        } else {
            updateSelectedPhotos(indexPath: indexPath)
        }
    }
    
    func updateSelectedPhotos(indexPath: IndexPath) {
        if indexPath.section == .zero {
            folders[indexPath.row].isSelected.toggle()
        } else {
            modelData[indexPath.row].isSelected.toggle()
        }
        self.collectionView?.reloadItems(at: [indexPath])
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            // Dequeue and configure the header view
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
                return UICollectionReusableView()
            }
            if indexPath.section == .zero {
                headerView.messageLabel.text = String()
                headerView.activityIndicatorView.isHidden = true
                headerView.gradientView?.isHidden = false
                headerView.isUserInteractionEnabled = false
            } else if indexPath.section == 1 {
                if !modelData.isEmpty {
                    if filesIsExpanded {
                        headerView.messageLabel.text = Text.hideAllPhotos.localized()
                    } else {
                        headerView.messageLabel.text = Text.showAllPhotos.localized()
                    }
                } else {
                    headerView.messageLabel.text = String()
                }
                headerView.isUserInteractionEnabled = true
                headerView.activityIndicatorView.isHidden = true
                headerView.gradientView?.isHidden = true
                headerView.delegate = self
            }
            return headerView
        } else if kind == UICollectionElementKindSectionFooter {
            // Dequeue and configure the footer view
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView", for: indexPath) as? FooterView else {
                return UICollectionReusableView()
            }
            
            return footerView
        }
        
        // Return an empty view for other supplementary elements
        return UICollectionReusableView()
    }
}


// MARK: - Extension CollectionView Input Image
extension CollectionViewController: AssetsPickerViewControllerDelegate {
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        for asset in assets {
            if(asset.mediaType.rawValue != 2) {
                image = getAssetThumbnail(asset: asset)
                guard let image = image else {
                    return
                }
                if let photo = ModelController.saveImageObject(image: image,
                                                               basePath: basePath) {
                    modelData.append(photo)
                    collectionView?.reloadSections(IndexSet(integer: 1))
                }
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
    
    func assetsPicker(controller: AssetsPickerViewController, shouldSelect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        return true
    }
    
    func assetsPicker(controller: AssetsPickerViewController, shouldDeselect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - Extension Viewer Image
extension CollectionViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return modelData.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        let imageView = UIImageView(image: modelData[index].image)
        let galleryItem = GalleryItem.image { $0(imageView.image) }
        
        return galleryItem
    }
}

extension CollectionViewController {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        adsHandler.interstitialDidReceiveAd(ad)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        adsHandler.interstitialDidDismissScreen(delegate: self)
    }
    
    private func setupAds() {
        adsHandler.setupAds(controller: self,
                            bannerDelegate: self,
                            interstitialDelegate: self)
    }
}

// MARK: - First use
extension CollectionViewController {
    private func setupFirstUse() {
        if !Key.firstUse.getBoolean() {
            Key.firstUse.setBoolean(true)
            performFirstUseSetup()
        }
    }
    
    private func performFirstUseSetup() {
        loadingAlert.startLoading(in: self)
        CloudKitPasswordService.fetchAllPasswords { password, error in
            guard let password = password,
                  error == nil else {
                self.loadingAlert.stopLoading {
                    self.showSetProtectionOrNavigateToSettings()
                }
                return
            }
            self.loadingAlert.stopLoading {
                Alerts.askUserToRestoreBackup(on: self) { restoreBackup in
                    if restoreBackup {
                        Alerts.insertPassword(controller: self, completion: { insertedPassword
                            in
                            guard let insertedPassword = insertedPassword else {
                                return
                            }
                            if password.contains(insertedPassword) {
                                self.loadingAlert.startLoading(in: self)
                                BackupService.hasDataInCloudKit { hasData, _, items  in
                                    self.loadingAlert.stopLoading {
                                        guard let items = items,
                                              !items.isEmpty,
                                              hasData else {
                                            self.showSetProtectionOrNavigateToSettings()
                                            return
                                        }
                                        self.restoreBackupAndReloadData(photos: items)
                                    }
                                }
                            }
                        })
                    } else {
                        self.showSetProtectionOrNavigateToSettings()
                    }
                }
            }
        }
    }
    
    private func restoreBackupAndReloadData(photos: [(String, UIImage)]) {
        loadingAlert.startLoading(in: self)
        BackupService.restoreBackup(photos: photos) { success, _ in
            self.loadingAlert.stopLoading {
                if success {
                    self.setupData()
                    self.collectionView?.reloadData()
                    self.showSetProtectionOrNavigateToSettings()
                } else {
                    Alerts.showBackupError(controller: self)
                }
            }
        }
    }
    
    private func showSetProtectionOrNavigateToSettings() {
        Alerts.showSetProtectionAsk(controller: self) { createProtection in
            if createProtection {
                self.presentChangePasswordCalcMode()
            } else {
                self.navigateToSettingsTab()
            }
        }
    }
    
    private func presentChangePasswordCalcMode() {
        let storyboard = UIStoryboard(name: "CalculatorMode", bundle: nil)
        let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "ChangePasswordCalcMode")
        self.present(changePasswordCalcMode, animated: true)
    }
    
    private func navigateToSettingsTab() {
        if let tabBarController = self.tabBarController {
            let desiredTabIndex = 3
            if desiredTabIndex < tabBarController.viewControllers?.count ?? 0 {
                tabBarController.selectedIndex = desiredTabIndex
            }
        }
    }
}
